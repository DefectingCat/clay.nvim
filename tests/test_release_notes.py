import sys
from pathlib import Path
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from release_notes import extract_notes


class ReleaseNotesTests(unittest.TestCase):
    def test_extracts_only_requested_version_and_preserves_markdown(self):
        changelog = """# Changelog
## [Unreleased]
- Future changes.
## [v0.2.0] - 2026-10-16

### Breaking changes
- Use `clay` instead of `claude`.

## [v0.1.0] - 2026-10-15
- Initial release.
"""
        self.assertEqual(
            extract_notes(changelog, "v0.2.0"),
            "### Breaking changes\n- Use `clay` instead of `claude`.\n",
        )

    def test_missing_duplicate_and_empty_sections_fail(self):
        header = "## [v0.2.0] - 2026-10-16\n"
        for changelog in ("## [Unreleased]\n", header, header + "### Fixes\n", (header + "- Fix.\n") * 2):
            with self.subTest(changelog=changelog), self.assertRaises(ValueError):
                extract_notes(changelog, "v0.2.0")

    def test_rejects_invalid_tags_and_dates(self):
        for tag in ("v0.2", "0.2.0", "v01.2.0", "v0.2.0-rc.1", "v0.2.0; echo bad"):
            with self.subTest(tag=tag), self.assertRaises(ValueError):
                extract_notes("", tag)
        for heading in ("## [v0.2.0]", "## [v0.2.0] - 2026-02-30"):
            with self.subTest(heading=heading), self.assertRaises(ValueError):
                extract_notes(heading + "\n- Fix.", "v0.2.0")

    def test_headings_in_code_fences_are_not_section_boundaries(self):
        for fence in ("```", "~~~"):
            body = f"Example:\n{fence}markdown\n## [v0.2.0]\n{fence}\n- Done.\n"
            changelog = f"## [v0.2.0] - 2026-10-16\n{body}\n## [v0.1.0] - 2026-10-15\n- Old."
            self.assertEqual(extract_notes(changelog, "v0.2.0"), body)

    def test_current_release_matches_changelog(self):
        root = Path(__file__).resolve().parents[1]
        notes = extract_notes((root / "CHANGELOG.md").read_text(), "v0.2.0")
        self.assertIn('require("clay")', notes)
        self.assertNotIn("首次版本化发布", notes)


if __name__ == "__main__":
    unittest.main()
