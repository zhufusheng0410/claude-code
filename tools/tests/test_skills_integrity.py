# -*- coding: utf-8 -*-
"""自定义 Skills（.agents/skills/）完整性与内嵌测试桥接。

1. 校验每个自定义 skill 的 SKILL.md frontmatter（name 与目录名一致、description 非空）及引用的仓内路径存在；
2. 将 dw-field-translate 的单元测试纳入全仓 unittest 与 CI 门禁，防止词根库或翻译脚本静默损坏。
"""
import importlib.util
import re
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SKILLS_DIR = ROOT / ".agents" / "skills"
TRANSLATE_SCRIPTS_DIR = SKILLS_DIR / "dw-field-translate" / "scripts"


def _load_translate_tests():
    added = False
    if str(TRANSLATE_SCRIPTS_DIR) not in sys.path:
        sys.path.insert(0, str(TRANSLATE_SCRIPTS_DIR))
        added = True
    try:
        spec = importlib.util.spec_from_file_location(
            "_skill_test_translate", TRANSLATE_SCRIPTS_DIR / "test_translate.py"
        )
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        return mod
    finally:
        if added and str(TRANSLATE_SCRIPTS_DIR) in sys.path:
            sys.path.remove(str(TRANSLATE_SCRIPTS_DIR))


_TRANSLATE_TEST_MOD = _load_translate_tests()


class BridgedTranslateAlgorithmTest(_TRANSLATE_TEST_MOD.TranslateAlgorithmTest):
    """桥接 dw-field-translate 算法单测。"""


class BridgedGlossaryTest(_TRANSLATE_TEST_MOD.GlossaryTest):
    """桥接 dw-field-translate 词根快照单测。"""


class TestCustomSkillsIntegrity(unittest.TestCase):
    EXPECTED_SKILLS = {
        "dw-code",
        "dw-field-translate",
        "dw-generate",
        "dw-schedule",
        "dw-sync",
    }

    def test_all_expected_skills_present_with_valid_frontmatter(self):
        found = {p.name for p in SKILLS_DIR.iterdir() if p.is_dir() and not p.name.startswith(".")}
        self.assertEqual(found, self.EXPECTED_SKILLS)

        for name in sorted(found):
            skill_md = SKILLS_DIR / name / "SKILL.md"
            self.assertTrue(skill_md.is_file(), f"缺少 {skill_md}")
            text = skill_md.read_text(encoding="utf-8")
            self.assertTrue(text.startswith("---\n"), f"{name}/SKILL.md 缺少 YAML frontmatter 起始")
            end = text.find("\n---\n", 4)
            self.assertGreater(end, 0, f"{name}/SKILL.md 缺少 YAML frontmatter 结束")
            fm = text[4:end]
            m_name = re.search(r"^name:\s*(\S+)\s*$", fm, re.M)
            self.assertIsNotNone(m_name, f"{name}/SKILL.md 缺少 name 字段")
            self.assertEqual(m_name.group(1), name)
            self.assertRegex(fm, r"(?m)^description:\s*\S+")

    def test_referenced_repo_paths_exist(self):
        path_re = re.compile(
            r"(?:`|\s)((?:tools|\.agents)/[A-Za-z0-9_.\-/]+(?:\.py|\.json|\.md|/))"
        )
        for skill_md in sorted(SKILLS_DIR.glob("*/SKILL.md")):
            text = skill_md.read_text(encoding="utf-8")
            for m in path_re.finditer(text):
                rel = m.group(1)
                if any(ch in rel for ch in ("*", "<", "{", "|")):
                    continue
                target = ROOT / rel.rstrip("/")
                self.assertTrue(
                    target.exists(),
                    f"{skill_md.relative_to(ROOT)} 引用了不存在的路径: {rel}",
                )

    def test_skill_guardrails_not_regressed(self):
        gen_text = (SKILLS_DIR / "dw-generate" / "SKILL.md").read_text(encoding="utf-8")
        self.assertNotIn("不把口径抄回 `AGENTS.md`", gen_text)
        self.assertIn("CLAUDE.md", gen_text)

        sched_text = (SKILLS_DIR / "dw-schedule" / "SKILL.md").read_text(encoding="utf-8")
        self.assertIn("ds-inspect.py running", sched_text)


if __name__ == "__main__":
    unittest.main()
