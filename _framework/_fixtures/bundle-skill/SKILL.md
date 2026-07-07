---
name: bundle-skill
description: Use this fixture skill to exercise bin/build-skill.sh (T-4a). It is a minimal bundle skill with one markdown link and one read directive to references/foo.md, so the build script's inlining can be tested against both forms. Triggers include 'run the build-script fixture', 'test reference inlining'.
metadata:
  version: 1.0.0
---

# Bundle Skill

Minimal bundle fixture for `bin/build-skill.sh`. Contains both reference forms the
build script must inline: a markdown link and a backticked read directive.

## Link form

See [the foo reference](references/foo.md) for the link-form test.

## Read-directive form

Read `references/foo.md` before answering.
