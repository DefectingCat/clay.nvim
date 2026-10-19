"""Extract a stable release's dated CHANGELOG section for GitHub Release."""

import argparse
from datetime import date
from pathlib import Path
import re
import sys


def extract_notes(changelog, tag):
    number = r"(?:0|[1-9][0-9]*)"
    if not re.fullmatch(rf"v{number}\.{number}\.{number}", tag):
        raise ValueError("Release tag must be vMAJOR.MINOR.PATCH")

    sections = []
    current = None
    fence = None
    for line in changelog.splitlines():
        marker = re.match(r"^ {0,3}(`{3,}|~{3,})", line)
        if marker:
            token = marker[1]
            if fence is None:
                fence = token
            elif token[0] == fence[0] and len(token) >= len(fence):
                fence = None
        if fence is None and line.startswith("## "):
            current = None
            if re.match(rf"^## \[{re.escape(tag)}\](?:\s|$)", line):
                heading = re.fullmatch(r"## \[([^]]+)\] - (\d{4}-\d{2}-\d{2})\s*", line)
                if heading is None:
                    raise ValueError(f"{tag} needs a YYYY-MM-DD release date")
                date.fromisoformat(heading[2])
                current = []
                sections.append(current)
        elif current is not None:
            current.append(line)

    if len(sections) != 1:
        raise ValueError(f"Expected exactly one CHANGELOG section for {tag}")
    body = "\n".join(sections[0]).strip()
    if not any(line.strip() and not line.lstrip().startswith("#") for line in body.splitlines()):
        raise ValueError(f"CHANGELOG section for {tag} is empty")
    return body + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tag")
    parser.add_argument("--changelog", type=Path, default=Path("CHANGELOG.md"))
    args = parser.parse_args()
    try:
        notes = extract_notes(args.changelog.read_text(encoding="utf-8"), args.tag)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    sys.stdout.write(notes)


if __name__ == "__main__":
    main()
