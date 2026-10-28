"""Excel 快速读盘（★ 2026-10-18）。

python-calamine（Rust）可选加速，语义严格对齐 pandas(openpyxl)：
- read_workbook_sheets：整本读回 {sheet名: DataFrame(header=None 原始网格)}，不可用返回 None；
- apply_header_row0 / frame_to_str：模拟 read_excel(header=0, dtype=str) 的列名与取值语义。

实测提速（MAPPING 全量 21 个交付 Excel / 308 sheet）：openpyxl 60.6s → calamine 9.0s；
单目录 ZTA（8 文件）51.3s → 4.6s（~11x）。openpyxl 瓶颈是 16384 列宽的样式空 XML
（~11.6MB/sheet）；calamine 只解析真实使用区域，快一个数量级。

回退策略：未安装 / DW_NO_CALAMINE=1 / 打开抛异常 → 返回 None，调用方走 openpyxl，
行为不变。等价性：全量 A/B（解析结果 repr 逐字节 0 差异 + dataclass 相等）验证两引擎
输出完全一致；语义差异全部收口在 norm_cell（数字 int 化、pandas 默认 NA 文本转 NaN），
新增调研/映射文件后请重跑 A/B（tools/.dx-tmp/_ab_calamine.py、_ab_survey.py）。
"""

import os

import pandas as pd

from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)

try:
    from python_calamine import CalamineWorkbook
except ImportError:  # pragma: no cover - 取决于环境是否安装可选依赖
    CalamineWorkbook = None

# pandas read_excel 默认 keep_default_na 会把以下字符串转成 NaN（与 pandas 2.x 默认集合一致）；
# calamine 原样返回。为保持两引擎逐字段一致（实测：映射规则列的文本 'NULL'），同样转 NaN。
_PANDAS_NA_STRINGS = frozenset({
    '', '#N/A', '#N/A N/A', '#NA', '-1.#IND', '-1.#QNAN', '-NaN', '-nan',
    '1.#IND', '1.#QNAN', '<NA>', 'N/A', 'NA', 'NULL', 'NaN', 'None',
    'n/a', 'nan', 'null',
})


def calamine_available() -> bool:
    """calamine 可用性 = 已安装 且 未设置 DW_NO_CALAMINE=1（A/B 对比与救急开关）。"""
    if CalamineWorkbook is None:
        return False
    return os.environ.get("DW_NO_CALAMINE", "").strip().lower() in ("", "0", "false", "no")


def norm_cell(v):
    """把 calamine 单元格值归一成与 pandas(openpyxl) 路径一致的语义：

    1. 数字：calamine 一律给 float（1.0），openpyxl 对无小数点的数字给 int（1）——
       整数值 float 归一成 int（实测影响：组别列 '1' vs '1.0'，会进 UNION 分组键与数据字典）；
    2. 字符串：命中 pandas 默认 NA 集合的文本（如 'NULL'）转 NaN。
    """
    if isinstance(v, float):
        if v.is_integer() and -2**53 < v < 2**53:
            return int(v)
        return v
    if isinstance(v, str) and v in _PANDAS_NA_STRINGS:
        return float("nan")
    return v


def read_workbook_sheets(filepath: str):
    """用 python-calamine 快速读整个工作簿，返回 {sheet名: DataFrame}。

    仅在以下情况返回 None（调用方回退 openpyxl）：
      · 未安装 python-calamine 或 DW_NO_CALAMINE=1；
      · 打开/解析抛异常。
    空单元格语义：calamine 给 ''，经 norm_cell 与 openpyxl 的 NaN 归一为同一结果。
    行/列对齐：calamine 的 to_python() 会裁掉前导空区，而 pandas(openpyxl) 按文件
    dimension 保留（dimension 几乎总是 A1 起）——★ 用 sheet.start 补回前导空行/列，
    否则「夹具首行为空」这类文件会整体偏移（table_survey 固定从第 3 行起读会读到空）。
    """
    if not calamine_available():
        return None
    try:
        wb = CalamineWorkbook.from_path(filepath)
        sheets = {}
        for sn in wb.sheet_names:
            sh = wb.get_sheet_by_name(sn)
            rows = [[norm_cell(v) for v in row] for row in sh.to_python()]
            if rows:
                start_row, start_col = sh.start
                if start_row or start_col:
                    nan = float("nan")
                    width = start_col + max(len(r) for r in rows)
                    rows = ([[nan] * width for _ in range(start_row)]
                            + [[nan] * start_col + r for r in rows])
            sheets[sn] = pd.DataFrame(rows) if rows else pd.DataFrame()
        return sheets
    except Exception as e:
        logger.debug("calamine 读取失败，回退 openpyxl: %s", e)
        return None


def apply_header_row0(df: pd.DataFrame) -> pd.DataFrame:
    """模拟 pd.read_excel(header=0)：第 0 行作列名，返回数据区（索引重置）。

    空表头 → 'Unnamed: {列号}'；重名 → 追加 '.1'/'.2'（仅覆盖实际会用到的两种情形）。
    """
    if len(df) == 0:
        return df
    header = list(df.iloc[0])
    data = df.iloc[1:].reset_index(drop=True)
    cols, seen = [], []
    for i, name in enumerate(header):
        if pd.isna(name):
            name = f"Unnamed: {i}"
        label, k = name, 1
        while label in seen:
            label = f"{name}.{k}"
            k += 1
        cols.append(label)
        seen.append(label)
    data.columns = cols
    return data


def frame_to_str(df: pd.DataFrame) -> pd.DataFrame:
    """模拟 pd.read_excel(dtype=str)：非空值统一 str()，缺失值保持 NaN。"""
    if len(df) == 0:
        return df
    return df.apply(lambda col: col.map(lambda v: v if pd.isna(v) else str(v)))
