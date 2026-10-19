"""Fetch the pinned public checkouts used by CI into a separate directory."""

import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import re
import subprocess


def checkout(item, destination):
    name, dependency = item
    repository = dependency["repository"]
    revision = dependency["revision"]
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository):
        raise ValueError(f"Invalid GitHub repository: {repository}")
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise ValueError(f"Expected a full commit SHA for {name}")
    if name != repository.split("/")[1]:
        raise ValueError(f"Checkout name must match repository: {name}")
    path = destination / name
    path.mkdir(parents=True)  # Never replace an existing checkout.

    def git(*args):
        return subprocess.check_output(
            ["git", "-C", str(path), *args], text=True, timeout=120
        ).strip()

    git("init", "--quiet")
    git("remote", "add", "origin", f"https://github.com/{repository}.git")
    git("fetch", "--quiet", "--depth=1", "origin", revision)
    git("checkout", "--quiet", "--detach", "FETCH_HEAD")
    if git("rev-parse", "HEAD") != revision:
        raise RuntimeError(f"Wrong revision checked out for {name}")
    print(f"{name}: {revision}", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("group", choices=["plugins", "treesitter"])
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    manifest = Path(__file__).resolve().parents[1] / ".github/ci-dependencies.json"
    dependencies = json.loads(manifest.read_text())[args.group]
    with ThreadPoolExecutor(max_workers=4) as workers:
        list(workers.map(lambda item: checkout(item, args.destination), dependencies.items()))


if __name__ == "__main__":
    main()
