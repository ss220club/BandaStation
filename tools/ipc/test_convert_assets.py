"""Check that asset conversion rejects local edits before writing output."""
import contextlib
import io
from pathlib import Path
import runpy
import unittest
from unittest.mock import patch


CONVERTER = Path(__file__).with_name("convert_assets.py")
REVISION = "0fffca1f1f29a63aff49d9b56524813eedf82c6d"


class ReachedConversion(Exception):
    pass


class SourceProvenance(unittest.TestCase):
    def test_dirty_source_is_rejected_before_output(self):
        for changes in (" M icons/mob/human_races/robotic.dmi\n", "?? untracked.dm\n", "M  code/modules/robolimbs/robolimbs.dm\n"):
            with self.subTest(changes=changes), patch("sys.argv", [str(CONVERTER), "--source", "."]), patch(
                "subprocess.check_output", side_effect=[REVISION + "\n", changes]
            ) as git, patch.object(Path, "mkdir") as mkdir, contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as rejected:
                    runpy.run_path(str(CONVERTER), run_name="__main__")
                self.assertEqual(rejected.exception.code, 2)
                self.assertEqual(git.call_args.args[0][-3:], ["status", "--porcelain", "--untracked-files=all"])
                mkdir.assert_not_called()

    def test_clean_pinned_source_reaches_conversion(self):
        with patch("sys.argv", [str(CONVERTER), "--source", "."]), patch(
            "subprocess.check_output", side_effect=[REVISION + "\n", ""]
        ), patch.object(Path, "mkdir", side_effect=ReachedConversion):
            with self.assertRaises(ReachedConversion):
                runpy.run_path(str(CONVERTER), run_name="__main__")


if __name__ == "__main__":
    unittest.main()
