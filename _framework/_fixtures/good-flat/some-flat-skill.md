---
name: some-flat-skill
description: Use this fixture skill to exercise the validator's flat branch. It is a minimal but VALID flat skill whose name equals its filename stem (some-flat-skill), NOT its directory name. Triggers include 'run the linter test', 'validate the good flat fixture'.
metadata:
  version: 1.0.0
---

# Some Flat Skill

A minimal valid flat-shape skill (a bare `<file>.md`, name == filename stem).
Exists only as a known-good fixture for `bin/validate-skills.sh`.

## A body section

---

The horizontal rule above is a legitimate markdown thematic break in the BODY.
The validator must NOT mistake it for a frontmatter delimiter — only the first
two `---` (lines 1 and 5) delimit frontmatter.
