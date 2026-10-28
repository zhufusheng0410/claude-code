"""normalize_params 回归测试（单遍替换重写后的语义等价性）

★ 2026-10-26：`normalize_params` 由 5 遍正则合并为 1 遍（性能：大脚本 O(n²)→O(n)）。
  合并时最易出错的是**lookbehind 的位置**：
    · 单引号形态的 lookbehind 必须放在**开引号之前**（检查引号前一个字符），
      放进引号内会永远成立 ⇒ `x'PI_DATE'` 被误替换；
    · 裸词形态的 lookbehind 必须**同时排除引号**（`'` 与 `"`），
      否则未闭合引号后的裸词会被误替换。
  本文件锁住这两类边界，防止后人再次踩坑。
"""

import unittest

from tools.generator.base import normalize_params


class TestNormalizeParamsBrace(unittest.TestCase):
    """形态①：`${...}` —— 只替换白名单内的旧变量名。"""

    def test_legacy_brace_replaced(self):
        for s in ("${PI_DATE}", "${PI_DT}", "${P_BATCH_DT}", "${p_batch_dt}"):
            self.assertEqual(normalize_params(s), "${p_end_dt}")

    def test_illegal_brace_with_space_replaced(self):
        """变量名带空格（shell 必挂）也要归一。"""
        self.assertEqual(normalize_params("${p_end dt}"), "${p_end_dt}")
        self.assertEqual(normalize_params("${p_end_ dt}"), "${p_end_dt}")

    def test_env_vars_untouched(self):
        """★ 踩坑记录：beeline 的 ${hive_jdbc} 等环境变量绝不能被误伤。"""
        for s in ("${hive_jdbc}", "${hive_username}", "${hive_password}"):
            self.assertEqual(normalize_params(s), s)

    def test_already_normalized_untouched(self):
        for s in ("${p_start_dt}", "${p_end_dt}", "${p_end_dt_1}"):
            self.assertEqual(normalize_params(s), s)


class TestNormalizeParamsQuoted(unittest.TestCase):
    """形态②：`'旧名'` 单引号包裹。"""

    def test_quoted_legacy_replaced(self):
        self.assertEqual(normalize_params("'PI_DATE'"), "'${p_end_dt}'")

    def test_quoted_in_condition(self):
        self.assertEqual(normalize_params("T1.P_DT = 'PI_DATE'"),
                         "T1.P_DT = '${p_end_dt}'")

    def test_lookbehind_blocks_identifier_prefix(self):
        """★ 回归：`x'PI_DATE'`（引号前紧贴标识符字符）不得替换。

        旧实现 lookbehind 在开引号前；合并版若误放进引号内会变成永远成立。
        """
        self.assertEqual(normalize_params("x'PI_DATE'"), "x'PI_DATE'")
        self.assertEqual(normalize_params("a'PI_DATE'b"), "a'PI_DATE'b")


class TestNormalizeParamsBareDollar(unittest.TestCase):
    """形态③：`$旧名`（无花括号）。"""

    def test_bare_dollar_legacy_replaced(self):
        self.assertEqual(normalize_params("$PI_DATE"), "${p_end_dt}")

    def test_bare_dollar_env_untouched(self):
        self.assertEqual(normalize_params("$hive_jdbc"), "$hive_jdbc")


class TestNormalizeParamsBareWord(unittest.TestCase):
    """形态④：裸词（JOIN 条件里 `= PI_DATE`）。"""

    def test_bare_legacy_replaced(self):
        self.assertEqual(normalize_params("AND T2.P_DT = PI_DATE"),
                         "AND T2.P_DT = '${p_end_dt}'")

    def test_qualified_column_untouched(self):
        """`T1.PI_DATE` 是带别名的列引用，不能当裸变量替换。"""
        self.assertEqual(normalize_params("T1.PI_DATE"), "T1.PI_DATE")

    def test_longer_identifier_untouched(self):
        """`PI_DATE_VALUE` 是更长的标识符，不能被前缀误匹配。"""
        self.assertEqual(normalize_params("PI_DATE_VALUE"), "PI_DATE_VALUE")

    def test_lookbehind_blocks_unterminated_quote(self):
        """★ 回归：未闭合引号后的裸词不得替换（lookbehind 需排除引号）。"""
        self.assertEqual(normalize_params("'PI_DATE"), "'PI_DATE")
        self.assertEqual(normalize_params('"PI_DATE'), '"PI_DATE')


class TestNormalizeParamsMixed(unittest.TestCase):
    """混合场景：多种形态同时出现。"""

    def test_mixed_forms(self):
        src = "WHERE D = ${p_end_dt} AND x = 'P_BATCH_DT' AND T2.P_DT = PI_DATE"
        self.assertEqual(
            normalize_params(src),
            "WHERE D = ${p_end_dt} AND x = '${p_end_dt}' AND T2.P_DT = '${p_end_dt}'")


if __name__ == "__main__":
    unittest.main()
