---
name: good-crlf
description: Use this fixture skill to exercise the validator's CRLF handling. It is a minimal but VALID bundle skill authored with Windows CRLF line endings; the linter must strip trailing carriage returns and treat it exactly like an LF file. Triggers include 'run the linter test', 'validate the CRLF fixture'.
metadata:
  version: 1.0.0
---

# Good CRLF

A minimal valid bundle-shape skill saved with CRLF line endings.
Exists only as a known-good fixture for `bin/validate-skills.sh` — it verifies
that every awk parser strips the trailing carriage return before matching, so a
Windows-authored skill lints the same as a Unix-authored one.
