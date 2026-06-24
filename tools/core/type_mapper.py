import re

def oracle_to_hive(oracle_type: str, field_cn: str = "") -> str:
    """Oracle→Hive 类型映射，严格参照参考脚本格式。
    保留 Oracle 原始精度:
      NUMBER(p,s) s>0 → DECIMAL(p,s) 保留原始精度
      NUMBER(p,0) / NUMBER(p) → DECIMAL(p,0) 保留原始精度
      VARCHAR2(n) → STRING
      DATE/TIMESTAMP → STRING
    """
    if not oracle_type:
        return "STRING"
    t = str(oracle_type).upper().strip()

    if any(t.startswith(x) for x in ("VARCHAR2", "VARCHAR", "CHAR", "NVARCHAR2", "NCHAR")):
        return "STRING"
    if t.startswith("CLOB") or t.startswith("LONG"):
        return "STRING"
    if t.startswith("NUMBER"):
        m = re.match(r"NUMBER\((\d+),(\d+)\)", t)
        if m:
            p, s = int(m.group(1)), int(m.group(2))
            if s > 0:
                # 保留原始精度，参考脚本用 DECIMAL(18,2) 等
                return f"DECIMAL({p},{s})"
            else:
                # 整数类型: 保留原始精度
                return f"DECIMAL({p},0)" if not _is_code_field(field_cn) else "STRING"
        m = re.match(r"NUMBER\((\d+)\)", t)
        if m:
            p = int(m.group(1))
            return f"DECIMAL({p},0)" if not _is_code_field(field_cn) else "STRING"
        # 无精度定义的 NUMBER，使用默认
        return "DECIMAL(18,2)"
    if t.startswith(("FLOAT", "BINARY_FLOAT", "BINARY_DOUBLE")):
        return "DECIMAL(18,2)"
    if any(t.startswith(x) for x in ("DATE", "TIMESTAMP", "DATETIME")):
        return "STRING"
    if t.startswith("INTEGER") or t.startswith("INT"):
        return "DECIMAL(8,0)"
    if any(t.startswith(x) for x in ("RAW", "BLOB")):
        return "STRING"
    return "STRING"

def _is_code_field(field_cn: str) -> bool:
    if not field_cn:
        return False
    code_keywords = ("代码", "编码", "编号", "标志", "标识", "类型", "分类", "方向")
    return any(kw in field_cn for kw in code_keywords)
