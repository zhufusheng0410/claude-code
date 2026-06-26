import os
import re
from collections import defaultdict
from ..core.ir import MappingSheet
from ..config import DWD_SCHEMA, SYS_FIELDS_DWD
from tools.utils.validation import validate_db_identifier
from tools.utils.logging_setup import get_logger
from tools.utils.table_utils import write_file

logger = get_logger(__name__)

# 列名最大宽度, 用于对齐（参照参考脚本格式）
# 首字段前缀7空格，后续字段前缀"     , "(7字符)
_AS_POS = 80        # " AS 别名" 起始列
_COMMENT_POS = 120  # "--注释" 起始列
_DEP_TBL_WIDTH = 55  # 依赖声明中表名列宽

# 系统字段默认表达式
_TIMESTAMP_EXPR = "FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')"

# 参照脚本固定的 Hive 运行参数（写入每个 ETL 脚本头部）
_HIVE_SETTINGS = [
    "set hive.exec.dynamic.partition=true;",
    "set hive.exec.dynamic.partition.mode=nonstrict;",
    "set hive.exec.max.dynamic.partitions.pernode=10000;",
    "set hive.exec.max.dynamic.partitions=10000;",
    "set hive.exec.max.created.files=10000;",
    "set mapred.max.split.size=256000000;",
    "set mapred.min.split.size.per.node=100000000;",
    "set mapred.min.split.size.per.rack=100000000;",
    "set hive.merge.mapredfiles=true;",
    "set hive.merge.mapfiles=true;",
    "set hive.merge.smallfiles.avgsize=16000000;",
    "set hive.merge.size.per.task=256000000;",
    "set hive.exec.reducers.bytes.per.reducer=10240000000;",
    "set mapreduce.job.reduces=2;",
]


def _split_table_name(tbl_full: str) -> str:
    """从 'SCHEMA.TABLE' 或 'TABLE' 中取出表名部分"""
    if '.' in tbl_full:
        return tbl_full.rsplit('.', 1)[1]
    return tbl_full


def _extract_sys_from_table(table_name: str) -> str:
    """从表名提取源系统简称, 如 ODS_XDAY_HSFTA.xxx -> HSFTA"""
    if not table_name:
        return ""
    m = re.search(r'ODS_XDAY_(\w+)', table_name)
    return m.group(1) if m else ""


def _resolve_group_sys(mappings: list, fallback: str) -> str:
    """从该组映射的主表名提取源系统，跨系统多组时各组输出对应的 SSYS"""
    for mr in mappings:
        if mr.join_type == "MAIN TABLE" and mr.src_table_name:
            extracted = _extract_sys_from_table(mr.src_table_name)
            if extracted:
                return extracted
    return fallback


class BaseGenerator:
    def __init__(self, schema, sys_fields, has_src_fields):
        self.schema = schema
        self.sys_fields = sys_fields
        self.has_src_fields = has_src_fields

    def generate_ddl(self, sheet: MappingSheet) -> str:
        """从 MappingSheet 生成建表 DDL"""
        tbl = _split_table_name(sheet.tgt_table)

        # 验证表名安全性，防止 SQL 注入
        validate_db_identifier(tbl, "table name")

        seen = set()
        unique_fields = []
        for mr in sheet.mappings:
            if mr.tgt_name and mr.tgt_name not in seen:
                seen.add(mr.tgt_name)
                unique_fields.append(mr)

        field_defs = []
        for mr in unique_fields:
            # 验证字段名安全性
            validate_db_identifier(mr.tgt_name, "field name")
            ftype = mr.tgt_type if mr.tgt_type else "STRING"
            comment = mr.tgt_name_cn.replace("'", "''") if mr.tgt_name_cn else ""
            field_defs.append(f"   {mr.tgt_name}  {ftype} DEFAULT NULL COMMENT '{comment}'")

        sys_field_names = {mr.tgt_name for mr in unique_fields}
        for sf_name, sf_type, sf_cn in self.sys_fields:
            if sf_name not in sys_field_names:
                # 系统字段也需验证，但通常可信，为性能可跳过。此处为安全起见验证
                validate_db_identifier(sf_name, "system field name")
                field_defs.append(f"   {sf_name}  {sf_type} DEFAULT NULL COMMENT '{sf_cn}'")

        lines = [
            f"DROP TABLE IF EXISTS {self.schema}.{tbl};",
            f"CREATE TABLE {self.schema}.{tbl} (",
            ",\n".join(field_defs),
            ")",
            f"COMMENT '{sheet.tgt_table_cn}'",
            "PARTITIONED BY ( P_DT  STRING)",
            "ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\t' NULL DEFINED AS '' ;",
        ]
        return "\n".join(lines)

    def generate_all_ddl(self, sheets: list) -> str:
        """生成所有建表 DDL（合并为一个 SQL 文件）"""
        parts = [
            f"-- {self.schema} 层建表语句",
            f"-- Schema: {self.schema}\n",
        ]
        for sheet in sheets:
            if not sheet.tgt_table:
                continue
            try:
                parts.append(f"-- {sheet.tgt_table_cn}")
                parts.append(self.generate_ddl(sheet))
                parts.append("")
            except ValueError as e:
                # 验证失败或其他错误，记录并跳过此表
                logger.error(f"  ERROR: Skipping table '{sheet.tgt_table}': {e}")
                continue
        return "\n".join(parts)

    def _write_file_safe(self, filepath: str, content: str, table_name: str, file_type: str):
        """安全写入文件，处理 ValueError（验证失败）和 IOError（IO错误）"""
        try:
            write_file(filepath, content)
        except ValueError as e:
            logger.error(f"  ERROR: Skipping table '{table_name}': {e}")
            return False
        except IOError as e:
            logger.error(f"  ERROR: Failed to write {file_type} file {filepath}: {e}")
            raise
        return True

    def generate_all_ddl_files(self, sheets: list, output_dir: str, sys_name: str = "O32"):
        """按表生成独立的 DDL SQL 文件"""
        ddl_dir = os.path.join(output_dir, "ddl")
        os.makedirs(ddl_dir, exist_ok=True)
        for sheet in sheets:
            if not sheet.tgt_table or not sheet.mappings:
                continue
            tbl = _split_table_name(sheet.tgt_table)
            filepath = os.path.join(ddl_dir, tbl + ".sql")
            ddl_sql = self.generate_ddl(sheet)
            self._write_file_safe(filepath, ddl_sql, sheet.tgt_table, "DDL")

    def _collect_aliases(self, mappings: list) -> dict:
        """收集所有表的别名信息"""
        aliases = {}
        for mr in mappings:
            alias = mr.src_table_alias
            if not alias:
                continue
            if alias not in aliases:
                aliases[alias] = {
                    "join_type": "",
                    "join_cond": "",
                    "filter_cond": [],
                    "src_table": mr.src_table_name or alias,
                    "src_table_cn": mr.src_table_cn or "",
                }
            info = aliases[alias]
            # 更新非空值（首次设置的优先保留，但 src_table 优先用非别名值）
            if mr.src_table_name and info["src_table"] == alias:
                info["src_table"] = mr.src_table_name
            info["src_table_cn"] = info["src_table_cn"] or mr.src_table_cn
            info["join_type"] = info["join_type"] or mr.join_type
            if mr.join_cond:
                cond = mr.join_cond.strip()
                info["join_cond"] = info["join_cond"] or (cond[3:] if cond.startswith("ON ") else cond)
            if mr.filter_cond and mr.filter_cond not in info["filter_cond"]:
                info["filter_cond"].append(mr.filter_cond)
        return aliases

    def _build_from_join(self, aliases: dict) -> str:
        """构建 FROM/JOIN 子句"""
        main_aliases = [a for a, info in aliases.items() if info["join_type"] == "MAIN TABLE"]
        other_aliases = [a for a, info in aliases.items() if info["join_type"] != "MAIN TABLE"]

        if not aliases:
            return "FROM source_table --主表"

        lines = []
        for alias in main_aliases:
            info = aliases[alias]
            cn = " --" + info["src_table_cn"] if info["src_table_cn"] else ""
            lines.append("  FROM " + info["src_table"] + " " + alias + cn)

        for alias in other_aliases:
            info = aliases[alias]
            cond = info["join_cond"] or "1=1"
            jt = info["join_type"] or "LEFT JOIN"
            cn = " --" + info["src_table_cn"] if info["src_table_cn"] else ""
            lines.append("  " + jt + " " + info["src_table"] + " " + alias + cn)
            # 解析 ON 条件: 第一个条件跟在 ON 后面, 后续 AND 换行缩进3空格
            self._append_on_conditions(lines, cond)

        return "\n".join(lines)

    def _append_on_conditions(self, lines, cond):
        """解析 ON 条件：ON 前面4空格，AND 前面3空格，让条件部分右对齐"""
        # 先按换行符分割，再按 AND 分割，处理注释
        # 清理 cond：去掉 ON 前缀，统一 AND 格式
        cond = cond.strip()
        if cond.upper().startswith('ON '):
            cond = cond[3:].strip()

        # 用正则分割，支持 AND 前后有换行符或空格
        parts = re.split(r'\s+AND\s+', cond, flags=re.IGNORECASE)

        if not parts:
            lines.append("    ON 1=1")
            return

        # 处理第一个条件（可能带注释）
        first = parts[0].strip()
        lines.append("    ON " + first)

        # 处理后续条件
        for part in parts[1:]:
            part = part.strip()
            if part:
                lines.append("   AND " + part)

    def _build_where(self, aliases: dict) -> list:
        """构建 WHERE 子句"""
        conds = []
        for alias, info in aliases.items():
            for fc in info.get("filter_cond", []):
                if fc and fc not in conds:
                    fc_clean = fc.strip()
                    if fc_clean.startswith("WHERE "):
                        fc_clean = fc_clean[6:]
                    conds.append(fc_clean)
        return conds

    def _resolve_expr(self, raw: str) -> str:
        if not raw:
            return "''"
        raw = str(raw).strip()
        if raw in ('nan', 'NaN'):
            return "''"
        return raw

    def _format_case_expr(self, expr, tgt_name, comment, prefix):
        """
        格式化 CASE 表达式为参考脚本格式：
         , CASE WHEN T1.C_CUSTTYPE IS NOT NULL
                THEN COALESCE(T3.STD_DICT_CLS_CD_VAL,CONCAT('@',T1.C_CUSTTYPE))
            END                                                                          AS CUST_TYPE_CODE                          --客户类型代码
        """

        # 按换行分割 CASE 表达式
        if "\n" in expr:
            lines = [line.rstrip() for line in expr.split("\n") if line.strip()]
        else:
            case_clean = expr.strip()
            if case_clean.upper().startswith("CASE") and "END" in case_clean.upper():
                # 在 THEN 和 END 前插入换行
                formatted = re.sub(r"(THEN\s+)", r"\n\1", case_clean, flags=re.IGNORECASE)
                formatted = re.sub(r"(\s+END)", r"\n\1", formatted, flags=re.IGNORECASE)
                lines = [line.strip() for line in formatted.split("\n") if line.strip()]
            else:
                lines = [case_clean]

        if not lines:
            return []

        result = []
        comment = comment or ""

        if len(lines) == 1:
            # 单行 CASE：整个 CASE...END 作为一行
            line_with_alias = (prefix + lines[0]).ljust(_AS_POS) + " AS " + tgt_name
            result.append(line_with_alias.ljust(_COMMENT_POS) + "--" + comment)
        else:
            # 多行 CASE
            # 第一行（CASE...WHEN...THEN...）：没有 AS 和注释
            result.append(prefix + lines[0])

            # 中间行（THEN 部分等，缩进 12 空格）
            for line in lines[1:-1]:
                if line:
                    result.append("            " + line)

            # 最后一行：END（缩进 8 空格）后跟 AS alias 和注释
            if lines[-1].upper().startswith("END"):
                end_line = "        " + lines[-1]  # 8 空格 + END
                end_line_with_alias = end_line.ljust(_AS_POS) + " AS " + tgt_name
                result.append(end_line_with_alias.ljust(_COMMENT_POS) + "--" + comment)

        return result

    def _fmt_select_line(self, prefix, expr, tgt_name, comment) -> str:
        """格式化单行 SELECT 字段：prefix + expr AS tgt_name  --comment"""
        line_with_alias = (prefix + expr).ljust(_AS_POS) + " AS " + tgt_name
        return line_with_alias.ljust(_COMMENT_POS) + "--" + comment

    def _build_select_lines(self, mappings, source_tables, sys_field_names, sys_name, add_src_fields=True):
        """
        构建 SELECT 子句，严格参照参考脚本格式：
           T1.D_CDATE                                                                    AS CNFM_DATE                               --确认日期
         , T1.C_CUSTNO                                                                   AS CUST_INCD                               --客户内码
        """
        sorted_mrs = sorted(mappings, key=lambda m: m.tgt_ordinal)
        seen = set()
        select_lines = []
        first_field = True
        for mr in sorted_mrs:
            if mr.tgt_name in seen:
                continue
            if mr.tgt_name in sys_field_names:
                continue
            seen.add(mr.tgt_name)
            prefix = "       " if first_field else "     , "
            first_field = False
            expr = self._resolve_expr(mr.src_field_alias)
            comment = mr.tgt_name_cn if mr.tgt_name_cn else ""
            if expr.upper().startswith('CASE '):
                select_lines.extend(self._format_case_expr(expr, mr.tgt_name, comment, prefix))
            elif '\n' in expr:
                first_line = expr.split('\n')[0].rstrip()
                select_lines.append(self._fmt_select_line(prefix, first_line, mr.tgt_name, comment))
                for line in expr.split('\n')[1:]:
                    if line.rstrip():
                        select_lines.append("            " + line.rstrip())
            else:
                select_lines.append(self._fmt_select_line(prefix, expr, mr.tgt_name, comment))

        # 追加系统字段
        if add_src_fields:
            if "SSYS" not in seen:
                group_sys = _resolve_group_sys(mappings, sys_name)
                select_lines.append(self._fmt_sys_field("SSYS", f"'{group_sys}'", "源系统"))
            if "SRC_TAB" not in seen and "SOURCE_TAB" not in seen:
                src_tab_str = ",".join(source_tables) if source_tables else ""
                select_lines.append(self._fmt_sys_field("SRC_TAB", f"'{src_tab_str}'", "源表"))
        if "LD_TIME" not in seen:
            select_lines.append(self._fmt_sys_field("LD_TIME", _TIMESTAMP_EXPR, "加载时间"))
        if "MODIFY_TIME" not in seen:
            select_lines.append(self._fmt_sys_field("MODIFY_TIME", _TIMESTAMP_EXPR, "修改时间"))
        return select_lines

    def _fmt_sys_field(self, field_name: str, expr_value: str, comment: str) -> str:
        """格式化系统字段行：     , expr AS field_name  --comment"""
        line_with_alias = ("     , " + expr_value).ljust(_AS_POS) + f" AS {field_name}"
        return line_with_alias.ljust(_COMMENT_POS) + "--" + comment

    def generate_etl(self, sheet: MappingSheet, sys_name: str = "O32") -> str:
        """从 MappingSheet 生成 ETL 加工 shell 脚本"""
        tbl = _split_table_name(sheet.tgt_table)

        # 验证表名安全性，防止 SQL 注入
        validate_db_identifier(tbl, "table name")

        sys_field_names = {sf[0] for sf in self.sys_fields}
        param = sheet.param or "p_end_dt"

        # 按 group_no 分组，支持多组 UNION ALL（Python 3.7+ dict 保序）
        groups = defaultdict(list)
        for mr in sheet.mappings:
            groups[mr.group_no or "1"].append(mr)

        # 预计算每组别名，同时合并为 all_aliases（供 dep_block 用）
        group_data = []
        all_aliases = {}
        for g_key, g_mappings in groups.items():
            g_aliases = self._collect_aliases(g_mappings)
            group_data.append((g_key, g_mappings, g_aliases))
            for alias, info in g_aliases.items():
                if alias not in all_aliases:
                    all_aliases[alias] = info

        # 依赖声明 — 按物理表名去重（用 dict 保持顺序），添加 "源表：" 标题
        unique_srcs = dict.fromkeys(
            (info["src_table"], info["src_table_cn"])
            for info in all_aliases.values()
        )
        dep_lines = ["-- ** 源表："] + [
            "-- **         " + tbl.ljust(_DEP_TBL_WIDTH) + cn
            for tbl, cn in unique_srcs.keys()
        ]

        dep_block = "\n".join(dep_lines)

        lines = [
            "#!/bin/sh",
            "#初始化环境变量：",
            "source ${hadoop_env}",
            "source ${source_path}",
            "inceptor_beeline()",
            "{",
            "    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e \"$1\"",
            "}",
            "",
            "",
            "inceptor_beeline \"",
            "",
            "-- **************************************************************************",
            "-- ** 主题:" + (sheet.tgt_table_cn or ""),
            "-- ** 描述:" + (sheet.func_desc or sheet.tgt_table_cn or ""),
            "-- ** 创建者:auto",
            "-- ** 创建日期:auto",
            "-- ** 修改日志:",
            "-- ** auto，新建",
            "-- ** 目标表：" + self.schema + "." + tbl + "              " + (sheet.tgt_table_cn or ""),
            dep_block,
            "-- **************************************************************************",
            "",
            *_HIVE_SETTINGS,
            "",
            "INSERT OVERWRITE TABLE " + self.schema + "." + tbl + " PARTITION(P_DT = '${" + param + "}')",
        ]

        # 构建 SELECT 块（单组或 UNION ALL 多组）
        for g_idx, (g_key, g_mappings, g_aliases) in enumerate(group_data):
            g_select_lines = self._build_select_lines(
                g_mappings, sheet.source_tables,
                sys_field_names, sys_name, add_src_fields=self.has_src_fields
            )
            g_from_join = self._build_from_join(g_aliases)
            g_where = self._build_where(g_aliases)

            if g_idx == 0:
                lines.append("SELECT")
            else:
                lines.append("UNION ALL")
                lines.append("SELECT")

            lines.append("\n".join(g_select_lines))
            lines.append(g_from_join)
            if g_where:
                lines.append("WHERE " + "\n  AND ".join(g_where))

        lines.append(";\"")
        return "\n".join(lines)

    def generate_all_etl_files(self, sheets: list, output_dir: str, sys_name: str = "O32"):
        """按表生成独立的 ETL shell 脚本"""
        os.makedirs(output_dir, exist_ok=True)
        for sheet in sheets:
            if not sheet.tgt_table or not sheet.mappings:
                continue
            tbl = _split_table_name(sheet.tgt_table)
            filepath = os.path.join(output_dir, tbl + ".sh")
            script = self.generate_etl(sheet, sys_name)
            self._write_file_safe(filepath, script, sheet.tgt_table, "ETL")


def create_generator(layer_name: str) -> BaseGenerator:
    """创建对应层级的生成器实例"""
    from ..config import DWD_SCHEMA, SYS_FIELDS_DWD, DWS_SCHEMA, SYS_FIELDS_DWS

    if layer_name == "DWD":
        return BaseGenerator(DWD_SCHEMA, SYS_FIELDS_DWD, True)
    elif layer_name == "DWS":
        return BaseGenerator(DWS_SCHEMA, SYS_FIELDS_DWS, False)
    else:
        raise ValueError(f"Unknown layer: {layer_name}")
