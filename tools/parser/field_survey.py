import pandas as pd
import tempfile
import shutil
import os
import re
import zipfile
from ..core.ir import FieldMeta
from ..core.type_mapper import oracle_to_hive
from tools.utils.pandas_helpers import safe_str, safe_float
from tools.utils.logging_setup import get_logger

logger = get_logger(__name__)


def parse_field_survey(filepath: str) -> dict:
    """
    解析字段级调研Excel, 返回 {表英文名: [FieldMeta]}

    Excel结构: Sheet1, header=row 0, 数据从 row 1 开始.
    列名: 源系统英文名(0), 表英文名(1), 表中文名(2), 字段序号(3),
    字段英文名(4), 字段中文名(5), 中文字段名备注(6), 字段类型(7),
    转换后字段类型(8), 是否允许为空(9), 是否技术主键(10), 是否业务主键(11),
    是否外键(12), 默认值(13), 是否入ODS(14), 调研结果及备注(15),
    样例数据(16), 空值率(17), 是否为代码字段(18), 码值(19),
    码值来源(20), 是否保留建模(21), ...
    """
    df = _read_excel_safely(filepath)
    result = _parse_fields_from_df(df)
    total_fields = sum(len(v) for v in result.values())
    logger.debug(f"  字段级调研解析完成: {len(result)} 张表, 共 {total_fields} 个字段 ({filepath})")
    return result


def _read_excel_safely(filepath: str) -> pd.DataFrame:
    """安全读取Excel，自动处理autoFilter问题"""
    # 尝试直接读取
    try:
        xls = pd.ExcelFile(filepath, engine='openpyxl')
        sheet_name = xls.sheet_names[0]
        df = pd.read_excel(xls, sheet_name=sheet_name, dtype=str)
        return df
    except Exception:
        pass  # 进入修复逻辑

    logger.warning(f"  直接读取失败，尝试修复 autoFilter: {filepath}")
    tmp_dir = tempfile.mkdtemp()
    fixed_zip = None
    try:
        with zipfile.ZipFile(filepath, 'r') as zf:
            zf.extractall(tmp_dir)

        # 修改所有 worksheet XML，移除 autoFilter 元素
        xl_dir = os.path.join(tmp_dir, 'xl')
        if os.path.exists(xl_dir):
            ws_dir = os.path.join(xl_dir, 'worksheets')
            if os.path.exists(ws_dir):
                for fname in os.listdir(ws_dir):
                    if fname.endswith('.xml'):
                        fpath = os.path.join(ws_dir, fname)
                        with open(fpath, 'r', encoding='utf-8') as f:
                            content = f.read()
                        if '<autoFilter' in content:
                            content = re.sub(r'<autoFilter[^>]*>.*?</autoFilter>', '', content, flags=re.DOTALL)
                            with open(fpath, 'w', encoding='utf-8') as f:
                                f.write(content)

        # 重新打包为临时 Excel 文件
        fixed_zip = filepath + '.fixed.xlsx'
        with zipfile.ZipFile(fixed_zip, 'w', zipfile.ZIP_DEFLATED) as zf:
            for root, dirs, files in os.walk(tmp_dir):
                for file in files:
                    full_path = os.path.join(root, file)
                    arc_name = os.path.relpath(full_path, tmp_dir)
                    zf.write(full_path, arc_name)

        # 读取修复后的文件
        xls = pd.ExcelFile(fixed_zip, engine='openpyxl')
        sheet_name = xls.sheet_names[0]
        df = pd.read_excel(xls, sheet_name=sheet_name, dtype=str)

        # 清理临时文件
        shutil.rmtree(tmp_dir, ignore_errors=True)
        if os.path.exists(fixed_zip):
            os.unlink(fixed_zip)

        logger.debug(f"  autoFilter 修复成功")
        return df

    except Exception as e:
        # 清理临时文件
        shutil.rmtree(tmp_dir, ignore_errors=True)
        if fixed_zip is not None:
            if os.path.exists(fixed_zip):
                os.unlink(fixed_zip)
        raise RuntimeError(f"无法读取Excel文件 {filepath}: {e}")


def _parse_fields_from_df(df: pd.DataFrame) -> dict:
    """从DataFrame解析字段信息"""
    fields_by_table = {}
    for i in range(1, len(df)):
        row = df.iloc[i]
        tbl_name = safe_str(row, '表英文名')
        field_name = safe_str(row, '字段英文名')
        if not tbl_name or not field_name:
            continue

        src_type = safe_str(row, '字段类型')
        hive_type = safe_str(row, '转换后字段类型')
        if not hive_type:
            hive_type = oracle_to_hive(src_type, safe_str(row, '字段中文名'))

        fm = FieldMeta(
            ordinal=safe_float(row, '字段序号'),
            src_name=field_name,
            src_name_cn=safe_str(row, '字段中文名'),
            src_name_cn_note=safe_str(row, '中文字段名备注'),
            src_type=src_type,
            hive_type=hive_type,
            is_nullable=safe_str(row, '是否允许为空[N/Y]'),
            is_pk=safe_str(row, '是否技术主键或唯一索引'),
            is_biz_pk=safe_str(row, '是否业务主键'),
            is_fk=safe_str(row, '是否外键'),
            default_val=safe_str(row, '默认值'),
            is_ods=safe_str(row, '是否入ODS[是/否]'),
            is_reserved=safe_str(row, '是否保留建模'),
            sample_data=safe_str(row, '样例数据、范围'),
            null_rate=safe_str(row, '空值率'),
            is_code_field=safe_str(row, '是否为代码字段[是/否]'),
            code_val=safe_str(row, '码值'),
        )
        fields_by_table.setdefault(tbl_name, []).append(fm)

    return fields_by_table


