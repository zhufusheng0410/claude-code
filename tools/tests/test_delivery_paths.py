# -*- coding: utf-8 -*-
"""tools.core.delivery_paths 的单元测试。"""
import os
import unittest
from pathlib import Path
from unittest.mock import patch

from tools.core.delivery_paths import (
    _DELIVERY_SENTINEL,
    _MASTER_DIR,
    _MASTER_SYSNAME,
    _PROJECT_REL,
    detect_d_base,
    dwd_ddl_dir,
    dwd_ddl_main,
    dwd_etl_dir,
    dws_etl_dir,
    resolve_delivery,
)


class TestDetectDBase(unittest.TestCase):
    def test_env_override(self):
        with patch.dict(os.environ, {"DW_D_BASE": "/custom/base"}):
            self.assertEqual(detect_d_base(), "/custom/base")

    def test_detection_fallback(self):
        with patch.dict(os.environ, {}, clear=True):
            os.environ.pop("DW_D_BASE", None)
            with patch("os.path.isdir", return_value=False):
                res = detect_d_base()
                expected_default = "D:/" if os.name == "nt" else "/mnt/d"
                self.assertEqual(res, expected_default)

    def test_candidate_hit(self):
        with patch.dict(os.environ, {}, clear=True):
            os.environ.pop("DW_D_BASE", None)

            def fake_isdir(p):
                return "/data" in str(p) or "E:/" in str(p)

            with patch("os.path.isdir", side_effect=fake_isdir):
                res = detect_d_base()
                self.assertIn(res, ("E:/", "/data"))


class TestResolveDelivery(unittest.TestCase):
    def test_env_delivery_hit(self):
        fake_path = Path("/my/delivery")
        with patch.dict(os.environ, {"DW_DELIVERY": str(fake_path)}):
            with patch.object(Path, "is_dir", autospec=True,
                               side_effect=lambda self: getattr(self, "name", "") == _DELIVERY_SENTINEL):
                p = resolve_delivery()
                self.assertEqual(p, fake_path)

    def test_fallback_candidate(self):
        with patch.dict(os.environ, {}, clear=True):
            os.environ.pop("DW_DELIVERY", None)
            with patch.object(Path, "is_dir", return_value=False):
                p = resolve_delivery()
                # When no candidate has sentinel, returns the last candidate
                self.assertEqual(p, Path(r"D:\项目\信达澳亚数仓\信达澳亚投研数据集市交付文档"))


class TestDirectoryBuilders(unittest.TestCase):
    def setUp(self):
        self.scripts = Path("/mock/scripts")

    def test_dwd_paths_normal_sys(self):
        etl = dwd_etl_dir(self.scripts, "O32")
        ddl = dwd_ddl_dir(self.scripts, "O32")
        main_ddl = dwd_ddl_main(self.scripts, "O32")

        self.assertEqual(etl, self.scripts / "O32" / "dwd" / "02_etl")
        self.assertEqual(ddl, self.scripts / "O32" / "dwd" / "ddl")
        self.assertEqual(main_ddl, self.scripts / "O32" / "dwd" / "01_ddl.sql")

    def test_dwd_paths_master_sys(self):
        etl = dwd_etl_dir(self.scripts, _MASTER_SYSNAME)
        ddl = dwd_ddl_dir(self.scripts, _MASTER_SYSNAME)
        main_ddl = dwd_ddl_main(self.scripts, _MASTER_SYSNAME)

        self.assertEqual(etl, self.scripts / _MASTER_DIR / "dwd" / "02_etl")
        self.assertEqual(ddl, self.scripts / _MASTER_DIR / "dwd" / "ddl")
        self.assertEqual(main_ddl, self.scripts / _MASTER_DIR / "dwd" / "01_ddl.sql")

    def test_dws_etl_dir(self):
        dws_dir = dws_etl_dir(self.scripts, "HSFA")
        self.assertEqual(dws_dir, self.scripts / "HSFA" / "dws/02_etl")

    def test_invalid_sysname_raises_value_error(self):
        with self.assertRaises(ValueError):
            dwd_etl_dir(self.scripts, "../evil")

        with self.assertRaises(ValueError):
            dws_etl_dir(self.scripts, "foo/bar")


if __name__ == "__main__":
    unittest.main()
