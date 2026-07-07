---
name: not--bad-skill
description: This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator. This is a deliberately oversized description used by the bad-skill fixture to trip the 1024-character limit check in the validator.
---

# Bad Skill

A deliberately INVALID bundle-shape fixture. It violates at least four rules:

1. `name` (`not--bad-skill`) != directory name (`bad-skill`)  — identity mismatch
2. `name` contains `--`                                       — pattern violation
3. `description` is > 1024 chars                              — oversize
4. missing `metadata.version` key                            — required-key gap
5. unescaped `{{today}}` macro below                          — Langfuse-interpolation hazard

The date filter uses `{{today}}` which Langfuse would interpolate to empty.
