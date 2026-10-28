import functools
import hashlib
import json
import os
import re
import pandas as pd
from ..core import ir as _ir
from ..core import sql_tables as _sql_tables
from ..core.ir import MappingSheet, MappingRule
from ..core.sql_tables import (extract_tables_from_subquery, is_subquery,
                                validate_table_ref)
from tools.utils import excel_reader as _excel_reader
from tools.utils import pandas_helpers as _pandas_helpers
from tools.utils.excel_reader import read_workbook_sheets
from tools.utils.pandas_helpers import safe_str, safe_float_str
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)

# ★ 2026-10-18：读盘统一走 tools/utils/excel_reader.py —— calamine 快路径（MAPPING
#   全量冷读 60.6s → 9.0s，~6.7x）+ openpyxl 自动回退；语义等价性见该模块注释。

# 跳过非数据sheet（目录、变更记录等）
# ★ 2026-10-04 补 '文档说明'：该 sheet 里有一行是「目标表英文名称 | 装数的表英文名称」这种
#   字段说明表格，会被 _parse_sheet_df 当成真实元数据解析出一个假目标表
#   （日志里那两条 `Skipping table '装数的表英文名称'` 就是它），纯噪音。
_SKIP_SHEETS = ('目录', '变更记录', '修改记录', '数据测试', '文档说明')

# 已知的列头描述行（出现在数据区域中但只是列名说明，不是真正的注释行）
_KNOWN_COLUMN_HEADERS = frozenset({
    '目标字段中文名', '目标字段类型', '序号', '主键', '组别',
    'JOIN方式', '关联条件', '关联条件说明', '源表别名', '源表英文名',
    '源表中文名', '源字段英文名', '源字段中文名', '源字段类型',
    '映射规则', '映射规则注释', '备注', '数据质量检查或约束条件',
    '过滤条件', '过滤条件说明',
})

# 元数据关键词集合（模块级常量，避免每次调用_parse_sheet_df 都重新创建）
_METADATA_KEYWORDS = frozenset({
    "目标表中文名称", "目标表英文名称", "功能描述", "分区字段",
    "参数", "频度", "目标表类型", "加载类型", "增量逻辑", "目标字段英文名",
})


def _sanitize_identifier(name: str) -> str:
    """
    清理标识符，确保只包含字母、数字和下划线

    将空格、连字符、点等非法字符替换为下划线，并合并连续下划线

    Args:
        name: 原始标识符

    Returns:
        清理后的安全标识符
    """
    if not name:
        return name
    # 记录原始名称（用于日志）
    original = name
    # 替换所有非字母数字下划线的字符为下划线
    name = re.sub(r'[^A-Za-z0-9_]', '_', name)
    # 合并连续的下划线
    name = re.sub(r'_+', '_', name)
    # 去除开头和结尾的下划线
    name = name.strip('_')
    if name != original:
        logger.debug(f"Sanitized identifier: '{original}' -> '{name}'")
    return name


def _has_chinese(text: str) -> bool:
    """检测字符串是否包含中文 CJK 统一表意文字"""
    return bool(text) and any('一' <= ch <= '鿿' for ch in text)


def parse_mapping_sheet(filepath: str, sheet_name: str) -> MappingSheet:
    """解析单个 MAPPING sheet：按名读取后委派 _parse_sheet_df。"""
    sheets = read_workbook_sheets(filepath)
    if sheets is not None and sheet_name in sheets:
        return _parse_sheet_df(sheets[sheet_name], sheet_name)
    df = pd.read_excel(filepath, sheet_name=sheet_name, header=None)
    return _parse_sheet_df(df, sheet_name)


def _parse_sheet_df(df: pd.DataFrame, sheet_name: str = "") -> MappingSheet:
    """
    解析单个 MAPPING sheet 的 DataFrame（header=None 读取）。

    MAPPING Excel 的通用结构:
    - Row 0: 工作区说明 或 源表声明
    - Row 1: 源表声明 或 目标表中文名称
    - Row 2-9: 元数据(目标表名, 功能描述, 分区字段, 参数, 频度, 表类型, 加载类型, 增量逻辑)
    - 列头行: 包含 "目标字段英文名" 的行, 后面是字段数据

    列头格式因系统不同而异:
    O32: col 0=目标字段英文名, col 1=目标字段中文名, col 2=目标字段类型,
         col 3=序号, col 4=主键, col 5=组别, col 6=JOIN方式,
         col 7=关联条件, col 8=关联条件说明, col 9=源表别名,
         col 10=源表英文名, col 11=源表中文名, col 12=源字段英文名, ...
    HSFA: 类似但 col 6=组别, col 7=源表别名, col 8=源表英文名, ...

    策略: 动态扫描列头行, 按 "目标字段英文名" 定位, 再按列名映射。
    """
    # 一次扫描 col 0 找所有关键词行，避免 N 次重复遍历
    _KEYWORDS = _METADATA_KEYWORDS
    keyword_rows: dict[str, int] = {}
    for i in range(len(df)):
        v = df.iloc[i, 0]
        if pd.notna(v):
            s = str(v)
            for kw in _KEYWORDS - keyword_rows.keys():
                if kw in s:
                    keyword_rows[kw] = i
        # 提前终止：已找到所有关键词
        if len(keyword_rows) == len(_KEYWORDS):
            break

    def cell(row_idx: int, col_idx: int) -> str:
        if row_idx < 0 or row_idx >= len(df) or col_idx < 0 or col_idx >= len(df.columns):
            return ""
        return safe_str(df.iloc[row_idx], col_idx)

    def meta(keyword: str, default: str = "") -> str:
        row = keyword_rows.get(keyword, -1)
        return cell(row, 1) if row >= 0 else default

    header_row = keyword_rows.get("目标字段英文名", -1)

    sheet = MappingSheet(
        tgt_table_cn=meta("目标表中文名称"),
        tgt_table=meta("目标表英文名称"),
        func_desc=meta("功能描述"),
        partition_col=meta("分区字段", "p_dt"),
        param=meta("参数", "p_batch_dt"),
        frequency=meta("频度", "D"),
        tgt_table_type=meta("目标表类型"),
        load_type=meta("加载类型"),
        incr_logic=meta("增量逻辑"),
    )

    if header_row < 0:
        return sheet

    # 构建列名映射
    col_map = {cell(header_row, j): j for j in range(len(df.columns)) if cell(header_row, j)}

    # 解析字段映射
    for i in range(header_row + 1, len(df)):
        tgt_name = cell(i, col_map.get("目标字段英文名", 0))
        if not tgt_name:
            continue
        # 跳过注释行：目标字段英文名包含中文的行（如"初始化。第1组插入交易日历史数据"等ETL逻辑说明）
        if _has_chinese(tgt_name):
            if tgt_name not in _KNOWN_COLUMN_HEADERS:
                logger.info("  SKIP comment row %d: '%s'", i, tgt_name[:80])
            continue

        tgt_type = cell(i, col_map.get("目标字段类型", 2))
        tgt_name_cn = cell(i, col_map.get("目标字段中文名", 1))
        tgt_ordinal = safe_float_str(cell(i, col_map.get("序号", 3)), default=0.0)
        is_pk = cell(i, col_map.get("主键", 4))
        group_no = cell(i, col_map.get("组别", 5))

        # JOIN方式 - 在 O32 的 col 6, HSFA 可能不同
        join_type_raw = cell(i, col_map.get("JOIN方式", -1)) or ""

        # 源表别名
        src_table_alias = cell(i, col_map.get("源表别名", -1))

        # 关联条件
        join_cond = cell(i, col_map.get("关联条件", -1))

        # 源字段英文名 (用于构建映射)
        src_field_name = cell(i, col_map.get("源字段英文名", -1))
        src_field_cn = cell(i, col_map.get("源字段中文名", -1))
        src_table_name = cell(i, col_map.get("源表英文名", -1))
        # 源字段类型（J-29：UNION 多组时按它判断要不要 CAST 到目标类型）
        src_field_type = cell(i, col_map.get("源字段类型", -1))

        # 映射规则 - 有的格式有专门的"映射规则"列
        src_field_alias = cell(i, col_map.get("映射规则", -1))

        # 如果没有映射规则列, 从源字段英文名+别名构建
        if not src_field_alias and src_field_name and src_table_alias:
            src_field_alias = f"{src_table_alias}.{src_field_name}"

        # 清理目标字段名，确保符合 SQL 标识符规则（只允许字母、数字、下划线）
        tgt_name = _sanitize_identifier(tgt_name)

        # 过滤条件
        filter_cond = cell(i, col_map.get("过滤条件", -1))

        mr = MappingRule(
            tgt_name=tgt_name,
            tgt_name_cn=tgt_name_cn,
            tgt_type=tgt_type,
            tgt_ordinal=tgt_ordinal,
            is_pk=is_pk,
            group_no=group_no,
            src_field_alias=src_field_alias,
            src_table_alias=src_table_alias,
            src_table_name=src_table_name,
            src_table_cn=cell(i, col_map.get("源表中文名", -1)),
            src_field_name=src_field_name,
            src_field_cn=src_field_cn,
            src_field_type=src_field_type,
            join_type=join_type_raw,
            join_cond=join_cond,
            filter_cond=_extract_filter(filter_cond),
            note=cell(i, col_map.get("备注", -1)),
        )
        sheet.mappings.append(mr)

    # 自动收集源表列表（从字段映射的"源表英文名"列），严格按照 Excel 给的值
    # ★★★ 2026-10-10：**去掉 sorted** —— 用户要求「SRC_TAB 只填 Excel 里面的文本」。
    #   原实现 `sorted({...})` 会把 Excel 的行序打乱成字母序（实测 110 个 DWD 脚本里
    #   63 个的 SRC_TAB 与 Excel 行序不一致）⇒ 改为**按首次出现顺序**去重。
    # ★★★ 2026-10-12：**子查询展开** —— 甲方在「源表英文名」列直接贴整段子查询时，
    #   旧实现把整段文本当一个"表名" ⇒ SRC_TAB / 依赖声明块写成一大段 SELECT，
    #   真实上游表（ODS_HSFA_TZQXX_PFD 等）全部丢失。现在识别到子查询就展开成
    #   其内部 FROM/JOIN 的真实表名（保序去重），与 SQL 里包括号后的引用保持一致。
    _seen_src = []
    for mr_idx, mr in enumerate(sheet.mappings):
        _v = (mr.src_table_name or "").strip()
        if not _v:
            continue
        _tables = ([t for t, _cn in extract_tables_from_subquery(_v)]
                   if is_subquery(_v) else [_v])
        for _t in _tables:
            if not _t or _t in _seen_src:
                continue
            # ★ 2026-10-22（评审 MEDIUM-4）：源表名来自甲方 MAPPING Excel，
            #   是**外部输入**。此前普通表名原样收入 source_tables，最终会流进
            #   SQL 构建与依赖配置 —— 一个含分号/引号的表名即可污染产物。
            #   子查询路径已由 extract_tables_from_subquery 的字符集天然受限，
            #   这里补齐普通表名的校验。
            #   策略：不合格的**跳过并告警**，不抛异常 ——
            #   一个脏表名不应中断整批 MAPPING 解析。
            try:
                validate_table_ref(_t)
            except ValueError as e:
                logger.warning(
                    "  ⚠ MAPPING 源表名非法，已跳过：%r（%s） (%s:row~%d)", _t, e, sheet_name, mr_idx)
                continue
            _seen_src.append(_t)
    sheet.source_tables = _seen_src

    return sheet


# ★★★ 2026-10-18：单文件解析结果磁盘缓存（重跑提速）。
#
#   实测动机：MAPPING sheet 被 Excel 撑到 16384 列宽（样式空单元格），openpyxl 每张
#   sheet 要啃 ~11.6MB XML（约 3~4s/张）——ZTA 一个目录 27 张 sheet 全量解析 ~36s。
#   （★ 2026-10-18 补充：读盘已加 calamine 快路径，冷读 ~6x，见上方注释；
#     本缓存仍负责「改了哪张 Excel 只重解析哪张」与多进程零重复解析。）
#   而「改一列 Excel 就重跑生成器」是高频动作 ⇒ 按 **文件级** 落缓存：
#     · 失效键 = (fingerprint, mtime_ns, size)：改哪张 Excel（mtime 变）只重解析哪张；
#     · fingerprint = 本模块 + sql_tables + ir 源码哈希 + pandas 版本 + 缓存格式版本，
#       解析逻辑一变缓存整体失效，防止「修了解析器却吃到旧结果」的静默事故；
#     · DW_MAPPING_CACHE_DIR 覆盖缓存目录（测试用），DW_NO_MAPPING_CACHE=1 一键禁用；
#     · 缓存读写失败/损坏一律静默回退直读 —— 缓存只负责提速，绝不参与正确性。
_CACHE_FMT = 1


def _cache_disabled() -> bool:
    return os.environ.get("DW_NO_MAPPING_CACHE", "").strip().lower() not in (
        "", "0", "false", "no")


@functools.lru_cache(maxsize=1)
def _cache_fingerprint() -> str:
    """缓存指纹：任一**影响解析结果**的模块变了，指纹就变 → 缓存自动失效。

    ★ 2026-10-22 修 bug（评审 HIGH-2）：原实现只哈希 mapping.py / sql_tables.py /
      ir.py 三个模块。但本模块的解析结果还直接依赖：
        · tools/utils/excel_reader.py —— norm_cell()：数字归一化（int 化）、
          'NULL'/'N/A' → NaN
        · tools/utils/pandas_helpers.py —— safe_str()：单元格取值的兜底转换
      这两个文件改动后，指纹不变 ⇒ Excel 的 mtime/size 若也不变 ⇒ **持续命中
      旧缓存**，返回逻辑已变的旧解析结果。与本函数注释宣称的
      「解析逻辑一变缓存整体失效」相矛盾，且极难排查（典型症状：改了代码
      却吃旧结果）。
      ⇒ 补进哈希输入。
    """
    h = hashlib.sha1()
    for mod_file in (__file__, _sql_tables.__file__, _ir.__file__,
                     _excel_reader.__file__, _pandas_helpers.__file__):
        with open(mod_file, "rb") as fh:
            h.update(fh.read())
    h.update(pd.__version__.encode("utf-8"))
    h.update(str(_CACHE_FMT).encode("ascii"))
    return h.hexdigest()[:16]


def _cache_file_path(filepath: str) -> str:
    base = os.environ.get("DW_MAPPING_CACHE_DIR") or os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        ".dx-tmp", "mapping-cache")
    key = hashlib.sha1(os.path.abspath(filepath).encode(
        "utf-8", "surrogateescape")).hexdigest()[:16]
    return os.path.join(base, key + ".json")


# ---------- 缓存序列化（JSON 而非 pickle） ----------
#
# ★ 2026-10-22 修 bug（评审 MEDIUM-3）：原用 pickle 存缓存 ⇒ **反序列化时
#   会执行任意可裁量代码**。缓存目录在仓库内（tools/.dx-tmp/mapping-cache），
#   多用户共享工作空间 / CI 场景下，若该目录可被他人写入，植入的恶意 .pkl
#   会在下次解析时被加载执行 ⇒ 本地代码执行面。
#   ⇒ 改用 JSON：MappingSheet / MappingRule 全是纯数据（标量 + list），
#     用 dataclasses.asdict 即可无损转换；反序列化只还原数据，不执行代码。

def _sheets_to_json(sheets: list) -> list:
    """dataclass 列表 → 可 JSON 序列化的纯 dict 列表。"""
    import dataclasses
    return [dataclasses.asdict(s) for s in sheets]


def _sheets_from_json(rows: list) -> list:
    """纯 dict 列表 → dataclass 列表（忽略未知字段，容忍版本差异）。"""
    import dataclasses
    out = []
    for row in rows:
        if not isinstance(row, dict):
            continue
        kwargs = {f.name: row[f.name] for f in dataclasses.fields(MappingSheet)
                  if f.name in row}
        sheet = MappingSheet(**kwargs)
        rules = []
        for mr in (kwargs.get("mappings") or []):
            if not isinstance(mr, dict):
                continue
            rkw = {f.name: mr.get(f.name) for f in dataclasses.fields(MappingRule)
                   if f.name in mr}
            rules.append(MappingRule(**rkw))
        sheet.mappings = rules
        out.append(sheet)
    return out


def _try_load_cached_sheets(filepath: str):
    """命中返回 [MappingSheet]；禁用/未命中/缓存损坏返回 None。任何异常不外抛。"""
    if _cache_disabled():
        return None
    try:
        st = os.stat(filepath)
        with open(_cache_file_path(filepath), "r", encoding="utf-8") as fh:
            payload = json.load(fh)
        if (payload.get("fingerprint") == _cache_fingerprint()
                and payload.get("mtime_ns") == st.st_mtime_ns
                and payload.get("size") == st.st_size):
            logger.debug("mapping cache hit: %s", os.path.basename(filepath))
            return _sheets_from_json(payload["sheets"])
    except Exception:
        return None
    return None


def _try_save_cached_sheets(filepath: str, sheets: list) -> None:
    """尽力落缓存（临时文件 + os.replace 原子替换）；失败只记 debug，不影响本次解析。"""
    if _cache_disabled():
        return
    try:
        st = os.stat(filepath)
        cache_path = _cache_file_path(filepath)
        os.makedirs(os.path.dirname(cache_path), exist_ok=True)
        tmp = "%s.tmp%d" % (cache_path, os.getpid())
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump({
                "fingerprint": _cache_fingerprint(),
                "mtime_ns": st.st_mtime_ns,
                "size": st.st_size,
                "sheets": _sheets_to_json(sheets),
            }, fh, ensure_ascii=False)
        os.replace(tmp, cache_path)
    except Exception as e:
        logger.debug("mapping cache save skipped: %s", e)


def _parse_xlsx_sheets(filepath: str) -> list:
    """从单个 Excel 文件解析所有非跳过 sheet，返回 [MappingSheet]（优先命中磁盘缓存）。

    ★ 2026-10-18：缓存命中即免去 openpyxl 全量解析（见上方缓存注释）；未命中才走
      _parse_xlsx_sheets_uncached 并尽力落缓存。
    """
    cached = _try_load_cached_sheets(filepath)
    if cached is not None:
        return cached
    results = _parse_xlsx_sheets_uncached(filepath)
    _try_save_cached_sheets(filepath, results)
    return results


def _parse_xlsx_sheets_uncached(filepath: str) -> list:
    """从单个 Excel 文件解析所有非跳过 sheet，返回 [MappingSheet]。

    读盘优先 python-calamine（tools/utils/excel_reader.py）；不可用时走 openpyxl，
    并复用单个 pd.ExcelFile 对象逐 sheet 读取
    （多 sheet 的 DWS 文件若逐个 read_excel 会重复解析整个工作簿）。
    """
    fname = os.path.basename(filepath)
    results = []
    sheets = read_workbook_sheets(filepath)
    if sheets is not None:
        for sn, df in sheets.items():
            if sn in _SKIP_SHEETS:
                continue
            try:
                results.append(_parse_sheet_df(df, sn))
            except Exception as e:
                logger.warning(f"  WARN: skip {fname}/{sn}: {e}")
        return results
    with pd.ExcelFile(filepath) as xls:
        for sn in xls.sheet_names:
            if sn in _SKIP_SHEETS:
                continue
            try:
                df = pd.read_excel(xls, sheet_name=sn, header=None)
                results.append(_parse_sheet_df(df, sn))
            except Exception as e:
                logger.warning(f"  WARN: skip {fname}/{sn}: {e}")
    return results


def parse_mapping_dir(mapping_dir: str) -> list:
    """遍历目录下所有 MAPPING Excel, 解析所有 sheet

    ★ 2026-10-12：跳过 `*_备份-*.xlsx` 留档文件。

      实测事故：修 Excel 时生成的备份（如 `HSFA-主题模型mapping-事件V1.0_
      备份-LFUNDID2LZTBH-20261012-145935.xlsx`）与原文件同目录 ⇒ 本函数
      `sorted(os.listdir)` 会**重复解析**同一张表两次（原文件 + 备份），
      生成器按表名落盘、后解析的覆盖先解析的 ⇒ 旧值静默覆盖新值
      （HSFA 事件表修好的 `A1.L_ZTBH=A10.SFAC_INCD` 被备份里的旧
      `A1.L_FUNDID=...` 顶掉）。备份是留档、不是有效输入，一律跳过。
    """
    results = []
    for fname in sorted(os.listdir(mapping_dir)):
        if fname.startswith('~$') or not fname.endswith('.xlsx'):
            continue
        if '_备份' in fname:
            logger.info(f"  skip 备份留档: {fname}")
            continue
        results.extend(_parse_xlsx_sheets(os.path.join(mapping_dir, fname)))
    return results


def parse_dws_mapping(filepath: str) -> list:
    """解析 DWS MAPPING 文件(单文件多sheet)"""
    return _parse_xlsx_sheets(filepath)




def _extract_filter(val: str) -> str:
    """提取过滤条件, 去掉 WHERE/AND 前缀"""
    if not val:
        return ""
    val = val.strip()
    if val.startswith("WHERE "):
        return val[6:]
    if val.startswith("AND "):
        return val[4:]
    return val


