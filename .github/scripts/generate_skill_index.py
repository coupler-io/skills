#!/usr/bin/env python3
"""Build skills-index.json from every SKILL.md in the repository."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
DEFAULT_OUTPUT = REPO_ROOT / "skills-index.json"
SKILL_FILENAME = "SKILL.md"
SKIP_DIR_NAMES = {".git", "node_modules", "__pycache__"}


def parse_frontmatter(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        raise ValueError(f"{path} is missing YAML frontmatter")

    parts = text.split("---", 2)
    if len(parts) < 3:
        raise ValueError(f"{path} has incomplete YAML frontmatter")

    data = yaml.safe_load(parts[1]) or {}
    if not isinstance(data, dict):
        raise ValueError(f"{path} frontmatter is not a mapping")
    return data


def normalize_text(value: Any) -> str:
    if value is None:
        return ""
    return " ".join(str(value).split())


def normalize_sources(value: Any, path: Path) -> list[str]:
    if value is None:
        return []
    if isinstance(value, str):
        return [value] if value else []
    if isinstance(value, list):
        return [str(item) for item in value if item is not None and str(item) != ""]
    raise ValueError(f"{path} sources must be a list or string")


def skill_entry(path: Path, repo_root: Path) -> dict[str, Any]:
    data = parse_frontmatter(path)
    metadata = data.get("metadata") or {}
    if not isinstance(metadata, dict):
        metadata = {}

    name = data.get("name")
    if not name:
        raise ValueError(f"{path} is missing name")

    relative_path = path.parent.relative_to(repo_root).as_posix()
    category = metadata.get("category") or data.get("category")

    return {
        "name": str(name),
        "path": relative_path,
        "category": category,
        "sources": normalize_sources(
            metadata.get("sources", data.get("sources")), path
        ),
        "short_description": normalize_text(metadata.get("short_description")),
        "description": normalize_text(data.get("description")),
    }


def collect_skills(repo_root: Path) -> list[dict[str, Any]]:
    skills: list[dict[str, Any]] = []
    for path in sorted(repo_root.rglob(SKILL_FILENAME)):
        if any(part in SKIP_DIR_NAMES for part in path.parts):
            continue
        skills.append(skill_entry(path, repo_root))
    skills.sort(key=lambda skill: skill["path"])
    return skills


NAME_PATTERN = re.compile(r"^[a-z0-9]([a-z0-9_-]*[a-z0-9])?$")

# Claude Desktop stops reading a description after roughly 500 characters, so
# anything past that never reaches the agent deciding whether to load the skill.
DESCRIPTION_MAX_CHARS = 500
SHORT_DESCRIPTION_MAX_CHARS = 200

# Skills whose descriptions predate the cap. Claude Desktop is already ignoring
# their tails, so each entry is a trim waiting to happen: shorten the
# description, then delete its slug here. New skills don't get to join the list,
# and it can only shrink - a slug that no longer needs the exemption fails the
# check until it's removed.
ALLOWLISTED_LONG_DESCRIPTIONS = frozenset(
    {
        "coupler-live-artifact",
        "create-dataflow",
        "ecom-analytics",
        "facebook-ads-settings-audit",
        "finance-analytics",
        "get-started",
        "google-ads-custom-gaql",
        "google-ads-settings-audit",
        "marketing-analytics",
        "ppc-analytics",
        "report-generation",
        "sales-analytics",
    }
)


def find_invalid_skill_names(skills: list[dict[str, Any]]) -> list[dict[str, str]]:
    return [
        {"path": skill["path"], "name": skill["name"]}
        for skill in skills
        if not NAME_PATTERN.fullmatch(skill["name"])
    ]


def find_duplicate_skill_names(skills: list[dict[str, Any]]) -> dict[str, list[str]]:
    by_name: dict[str, list[str]] = {}
    for skill in skills:
        by_name.setdefault(skill["name"], []).append(skill["path"])
    return {name: paths for name, paths in by_name.items() if len(paths) > 1}


def find_too_long(
    skills: list[dict[str, Any]], field: str, limit: int
) -> list[dict[str, Any]]:
    return [
        {"name": skill["name"], "length": len(skill[field])}
        for skill in skills
        if len(skill[field]) > limit
    ]


def find_stale_allowlisting(skills: list[dict[str, Any]]) -> list[str]:
    too_long = {
        skill["name"]
        for skill in find_too_long(skills, "description", DESCRIPTION_MAX_CHARS)
    }
    return sorted(ALLOWLISTED_LONG_DESCRIPTIONS - too_long)


def find_name_directory_mismatches(skills: list[dict[str, Any]]) -> list[dict[str, str]]:
    mismatches = []
    for skill in skills:
        leaf = skill["path"].split("/")[-1]
        if leaf != skill["name"]:
            mismatches.append({"path": skill["path"], "name": skill["name"]})
    return mismatches


INDEX_README = (
    "AUTO-GENERATED. Do not edit this file. Update SKILL.md frontmatter instead, "
    "then run python .github/scripts/generate_skill_index.py "
    "(also regenerated on merge to main)."
)


def render_index(skills: list[dict[str, Any]]) -> str:
    return (
        json.dumps(
            {
                "$comment": INDEX_README,
                "skills": skills,
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n"
    )


def write_index(skills: list[dict[str, Any]], output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render_index(skills), encoding="utf-8")


def print_invalid_names(invalid: list[dict[str, str]]) -> None:
    for skill in invalid:
        print(
            f"Invalid skill name {skill['name']!r}: {skill['path']}",
            file=sys.stderr,
        )

    print(
        "\nA skill's `name` may only contain lowercase ASCII letters, digits, "
        "- and _, and can't start or end with - or _.",
        file=sys.stderr,
    )


def print_duplicate_names(duplicates: dict[str, list[str]]) -> None:
    for slug, paths in duplicates.items():
        print(f"Duplicate skill name {slug!r}:", file=sys.stderr)
        for path in paths:
            print(f"  {path}", file=sys.stderr)

    print(
        "\nEach skill's `name` in SKILL.md frontmatter must be unique across "
        "the repository. Rename one of the skills above (both the `name` "
        "field and its folder) so they no longer collide.",
        file=sys.stderr,
    )


def print_too_long(
    too_long: list[dict[str, Any]], field: str, limit: int, guidance: str
) -> None:
    for skill in too_long:
        print(
            f"{skill['name']}: {field} is too long - {skill['length']} "
            f"characters against a {limit}-character limit",
            file=sys.stderr,
        )

    print(f"\n{guidance}", file=sys.stderr)


DESCRIPTION_GUIDANCE = (
    "Claude Desktop stops reading a skill's `description` after roughly 500 "
    "characters, so any trigger phrase past the limit is invisible to the agent "
    "choosing the skill. Trim the least distinctive triggers rather than the "
    "opening sentence - the first line is what the agent reads first."
)


def print_stale_allowlisting(stale: list[str]) -> None:
    for name in stale:
        print(
            f"{name}: allowlisted description no longer needs the exemption",
            file=sys.stderr,
        )

    print(
        "\nRemove the slug(s) above from ALLOWLISTED_LONG_DESCRIPTIONS in this "
        "script. The list only shrinks: once a description fits the "
        f"{DESCRIPTION_MAX_CHARS}-character limit (or the skill is renamed or "
        "deleted), its exemption has to go with it.",
        file=sys.stderr,
    )

SHORT_DESCRIPTION_GUIDANCE = (
    "A skill's `metadata.short_description` is rendered in the UI, so it has to "
    "stay one readable sentence. Move any detail an agent needs into "
    "`description`, which is the field agents actually read."
)


def print_name_directory_mismatches(mismatches: list[dict[str, str]]) -> None:
    for mismatch in mismatches:
        print(
            f"Skill folder doesn't match its name: {mismatch['path']} "
            f"has name {mismatch['name']!r}",
            file=sys.stderr,
        )

    print(
        "\nEvery skill's file is always named SKILL.md - the FOLDER it "
        "lives in must match its frontmatter `name`. For example:\n"
        "  sales/sales-analytics/SKILL.md with name: sales-analytics  ->  valid\n"
        "  sales/sales-analytics/SKILL.md with name: analytics        ->  invalid",
        file=sys.stderr,
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=REPO_ROOT)
    parser.add_argument("-o", "--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument(
        "--check",
        action="store_true",
        help="Validate without writing; exit 1 on any bad skill name or too-long description",
    )
    args = parser.parse_args(argv)

    root = args.root.resolve()
    output = args.output.resolve()
    skills = collect_skills(root)

    invalid_names = find_invalid_skill_names(skills)
    mismatches = find_name_directory_mismatches(skills)
    duplicate_names = find_duplicate_skill_names(skills)
    long_descriptions = [
        skill
        for skill in find_too_long(skills, "description", DESCRIPTION_MAX_CHARS)
        if skill["name"] not in ALLOWLISTED_LONG_DESCRIPTIONS
    ]
    long_short_descriptions = find_too_long(
        skills, "short_description", SHORT_DESCRIPTION_MAX_CHARS
    )
    stale_allowlisting = find_stale_allowlisting(skills)

    if invalid_names:
        print_invalid_names(invalid_names)
    if mismatches:
        print_name_directory_mismatches(mismatches)
    if duplicate_names:
        print_duplicate_names(duplicate_names)
    if long_descriptions:
        print_too_long(
            long_descriptions,
            "description",
            DESCRIPTION_MAX_CHARS,
            DESCRIPTION_GUIDANCE,
        )
    if long_short_descriptions:
        print_too_long(
            long_short_descriptions,
            "short_description",
            SHORT_DESCRIPTION_MAX_CHARS,
            SHORT_DESCRIPTION_GUIDANCE,
        )
    if stale_allowlisting:
        print_stale_allowlisting(stale_allowlisting)

    if (
        invalid_names
        or mismatches
        or duplicate_names
        or long_descriptions
        or long_short_descriptions
        or stale_allowlisting
    ):
        return 1

    if args.check:
        exempt = len(ALLOWLISTED_LONG_DESCRIPTIONS)
        print(
            f"OK: {len(skills)} skills, all names valid, unique, and matching "
            "their folders, all descriptions within limits "
            f"({exempt} allowlisted)"
        )
        return 0

    write_index(skills, output)
    print(f"Wrote {len(skills)} skills to {output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
