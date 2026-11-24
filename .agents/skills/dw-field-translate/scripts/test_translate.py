"""词根翻译对照。先锁住宏的最长匹配，再锁住信达词库里容易猜错的词。"""

import json
import unittest
from pathlib import Path

import translate


ROOTS_PATH = Path(__file__).resolve().parents[1] / "data" / "roots.json"

TINY = {
    "业务": translate.Root("业务", "BUSIN", "BUSIN", "恒生TA"),
    "日期": translate.Root("日期", "DATE", "DATE", "恒生TA"),
    "编码": translate.Root("编码", "NUM", "CODE", "恒生TA"),
    "码": translate.Root("码", "CODE", "CODE", "恒生TA"),
    "产品": translate.Root("产品", "PROD", "PRODUCT", "恒生TA"),
}


class TranslateAlgorithmTest(unittest.TestCase):
    def test_splits_when_compound_is_absent(self):
        result = translate.translate_name("业务日期", TINY)
        self.assertEqual(result.split_zh, "业务_日期")
        self.assertEqual(result.en, "busin_date")
        self.assertEqual(result.en_upper, "BUSIN_DATE")

    def test_longest_match_beats_shorter_root(self):
        result = translate.translate_name("产品编码", TINY)
        self.assertEqual(result.en, "prod_num")
        self.assertEqual([segment.zh for segment in result.segments], ["产品", "编码"])

    def test_unmatched_fragment_is_marked_not_invented(self):
        result = translate.translate_name("业务甲日期", TINY)
        self.assertEqual(result.split_zh, "业务_?甲?_日期")
        self.assertEqual(result.en, "busin_??_date")
        self.assertTrue(result.has_gap)

    def test_outer_whitespace_is_stripped_internal_space_is_a_gap(self):
        result = translate.translate_name("  业务日期  ", TINY)
        self.assertEqual(result.en, "busin_date")
        gapped = translate.translate_name("业务 日期", TINY)
        self.assertIn("??", gapped.en)

    def test_digit_maps_to_itself(self):
        result = translate.translate_name("业务1", translate.with_digits(TINY))
        self.assertEqual(result.en, "busin_1")

    def test_old_root_is_reported_but_not_used(self):
        result = translate.translate_name("产品编码", TINY)
        diffs = {item.zh: item.old for item in result.old_diffs}
        self.assertEqual(result.en, "prod_num")
        self.assertEqual(diffs["编码"], "CODE")
        self.assertEqual(diffs["产品"], "PRODUCT")

    def test_first_roots_tolerates_short_and_duplicate_rows(self):
        rows = [
            (),
            ("空英文",),
            ("编码", "NUM"),
            ("编码", "CODE", "OLD", "后行同名应忽略"),
            ("日期", "DATE", "DT", "恒生TA", "多余列应忽略"),
        ]
        parsed = {item.zh: item for item in translate._first_roots(rows)}
        self.assertEqual(set(parsed), {"编码", "日期"})
        self.assertEqual(parsed["编码"].en, "NUM")
        self.assertEqual(parsed["编码"].old, "")
        self.assertEqual(parsed["日期"].old, "DT")


class GlossaryTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.roots = translate.load_roots(ROOTS_PATH)

    def test_known_names_from_the_workbook(self):
        expected = {
            "业务日期": "busin_date",
            "指令序号": "istct_serialno",
            "指令修改序号": "istct_modify_serialno",
            "指令证券序号": "istct_scr_serialno",
            "产品编码": "prod_num",
        }
        for name, en in expected.items():
            with self.subTest(name=name):
                self.assertEqual(translate.translate_name(name, self.roots).en, en)

    def test_glossary_uses_current_not_old_for_tricky_roots(self):
        self.assertEqual(self.roots["编码"].en, "NUM")
        self.assertEqual(self.roots["编码"].old, "CODE")
        self.assertEqual(self.roots["指令"].en, "ISTCT")
        self.assertEqual(self.roots["证券"].en, "SCR")

    def test_snapshot_is_loadable_json(self):
        payload = json.loads(ROOTS_PATH.read_text(encoding="utf-8"))
        self.assertGreater(payload["count"], 1900)
        self.assertIn("信达", payload["source"])


if __name__ == "__main__":
    unittest.main()
