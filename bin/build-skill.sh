#!/usr/bin/env bash
# build-skill.sh — bundle -> flat-for-get-skill inliner (AC-2.2, T-4a/T-4b/T-4c)
#
# Reference-inlining is LOAD-BEARING and CONFIRMED (Peter, 2026-07-08):
# `get-skill` does NOT bundle a skill's references/ files — they cannot be loaded
# via tool calls at runtime. Inlining reference content at build time is therefore
# the ONLY way that content reaches the runtime. This script produces the flat
# variant that the product/MCP team loads onto the Coupler MCP (manual Langfuse sync).
#
# Invoke FROM REPO ROOT: bin/build-skill.sh <repo-root-relative-bundle-dir>
#   e.g. bin/build-skill.sh marketing/marketing-analytics
# Emits: build/<name>.flat.md   (build/ is git-ignored; artifacts are never committed)
#
# Behaviour:
#   - strips frontmatter (get-skill strips it anyway — live-probe fact 1, conventions.md)
#   - inlines each references/<file>.md link / read directive AT ITS LINK SITE
#   - rejects references/ paths containing '..' (path-traversal guard, fail-closed)
#   - FAILS CLOSED (exit 1, no artifact) if any references/*.md link cannot be resolved
#   - WARNS on residual non-.md 'references/' mentions (e.g. runtime dirs) in the flat output
#   - WARNS if the flat output contains unescaped {{ }} (serve-time Langfuse interpolates
#     {{token}} -> empty; this is a Langfuse concern, not our tooling, but we flag it)
set -uo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: bin/build-skill.sh <repo-root-relative-bundle-dir>" >&2
  exit 2
fi

BUNDLE="${1%/}"
SKILL="$BUNDLE/SKILL.md"
NAME="$(basename "$BUNDLE")"
OUTDIR="build"
OUT="$OUTDIR/$NAME.flat.md"

if [ ! -f "$SKILL" ]; then
  echo "ERROR: no SKILL.md found in '$BUNDLE' (expected $SKILL)" >&2
  exit 1
fi

# --- frontmatter strip: ONLY the first two '---' lines delimit frontmatter
# (same rule as validate-skills.sh); files without leading '---' pass through whole.
# Strip a trailing '\r' first so CRLF-authored skills build the same as LF ones
# (otherwise '---\r' never matches '^---$' and the whole body is treated as frontmatter,
#  and a matched 'references/x.md\r' would splice a bad path).
strip_frontmatter() { # $1=file -> stdout
  awk '{ sub(/\r$/, "") }
       NR==1 && $0 !~ /^---[[:space:]]*$/ { nofm=1 }
       nofm { print; next }
       /^---[[:space:]]*$/ && c<2 { c++; next }
       c>=2 { print }' "$1"
}

# --- fail-closed: every references/*.md link in the body must resolve to a real file.
# CRLF-safe: strip any trailing '\r' from the SKILL.md before grepping (a matched
# 'references/x.md\r' would otherwise carry a CR into the resolve/inline path).
MISSING=0
TRAVERSAL=0
REFS="$(tr -d '\r' < "$SKILL" | grep -o 'references/[[:alnum:]._/-]*\.md' | sort -u || true)"
if [ -n "$REFS" ]; then
  while IFS= read -r ref; do
    # --- path-traversal guard: reject any references/ path with a '..' segment
    # BEFORE resolving/inlining. 'references/../../X.md' would otherwise inline a
    # file outside the bundle. Guarded here (resolve-check) AND in the awk inliner.
    case "$ref" in
      *..*)
        echo "ERROR: path traversal rejected in reference link: $ref ('..' escapes the bundle)" >&2
        TRAVERSAL=1
        continue ;;
    esac
    if [ ! -f "$BUNDLE/$ref" ]; then
      echo "ERROR: unresolved reference link: $ref (no file $BUNDLE/$ref)" >&2
      MISSING=1
    fi
  done <<EOF
$REFS
EOF
fi
if [ "$TRAVERSAL" -ne 0 ]; then
  echo "FAIL-CLOSED: references/ path traversal ('..') detected; no flat output produced." >&2
  exit 1
fi
if [ "$MISSING" -ne 0 ]; then
  echo "FAIL-CLOSED: unresolved references/*.md link(s); no flat output produced." >&2
  exit 1
fi

mkdir -p "$OUTDIR"

# --- emit flat body with each references/*.md link/read-directive replaced by
# that file's contents AT THE LINK SITE (T-4b). Handles three forms:
#   [text](references/x.md)   |   `references/x.md`   |   bare references/x.md
# Inlined content is delimited by HTML comments so the splice points stay auditable.
strip_frontmatter "$SKILL" | awk -v bundle="$BUNDLE" '
  function inline_file(path,   full, base, l) {
    # --- path-traversal guard (defense in depth): never open a path with a ".."
    # segment, even if one somehow reaches the inliner. This is the second of two
    # guards; the first is the resolve-check above.
    if (path ~ /\.\./) {
      print "ERROR: path traversal rejected in inliner: " path > "/dev/stderr"
      exit 1
    }
    full = bundle "/" path
    # delimiter must NOT contain the literal "references/" — the flat output is
    # verified with grep -c "references/" == 0 (T-4b/T-4c)
    base = path; sub(/^references\//, "", base)
    print ""
    print "<!-- inlined reference: " base " (by build-skill.sh) -->"
    while ((getline l < full) > 0) { sub(/\r$/, "", l); print l }
    close(full)
    print "<!-- end of inlined reference: " base " -->"
    print ""
  }
  BEGIN {
    pat = "\\[[^]]*\\]\\(references/[[:alnum:]._/-]+\\.md\\)" \
          "|`references/[[:alnum:]._/-]+\\.md`" \
          "|references/[[:alnum:]._/-]+\\.md"
  }
  {
    line = $0
    while (match(line, pat)) {
      pre = substr(line, 1, RSTART - 1)
      tok = substr(line, RSTART, RLENGTH)
      line = substr(line, RSTART + RLENGTH)
      p = tok
      sub(/^\[[^]]*\]\(/, "", p); sub(/\)$/, "", p); gsub(/`/, "", p)
      if (pre != "") print pre
      inline_file(p)
    }
    print line
  }' > "$OUT"

# --- post-checks on the flat output ------------------------------------------
STATUS=0

RESIDUAL_MD="$(grep -n 'references/[[:alnum:]._/-]*\.md' "$OUT" || true)"
if [ -n "$RESIDUAL_MD" ]; then
  echo "ERROR: flat output still contains references/*.md links (inlining incomplete):" >&2
  printf '%s\n' "$RESIDUAL_MD" >&2
  STATUS=1
fi

RESIDUAL_OTHER="$(grep -n 'references/' "$OUT" | grep -v 'references/[[:alnum:]._/-]*\.md' || true)"
if [ -n "$RESIDUAL_OTHER" ]; then
  echo "WARN: residual non-file 'references/' mention(s) in flat output (dead paths on the get-skill surface):" >&2
  printf '%s\n' "$RESIDUAL_OTHER" >&2
fi

if grep -n '{{' "$OUT" >/dev/null 2>&1; then
  echo "WARN: flat output contains unescaped '{{ }}' — serve-time Langfuse interpolates {{token}} -> EMPTY on the MCP path (Langfuse concern, not this tooling); remove/rephrase before sync:" >&2
  grep -n '{{' "$OUT" >&2
fi

BYTES="$(wc -c < "$OUT" | tr -d ' ')"
if [ "$STATUS" -ne 0 ]; then
  mv "$OUT" "$OUT.FAILED"
  echo "FAIL-CLOSED: artifact moved to $OUT.FAILED (size: $BYTES bytes) — do not ship." >&2
  exit "$STATUS"
fi

echo "BUILT: $OUT"
echo "size: $BYTES bytes — no hard size cap (context-window bound; Peter, 2026-07-08)."
echo "Note: get-skill does NOT bundle references/ — build-time inlining (done above) is the only way reference content reaches the runtime."
echo "Hand-off: share this flat variant with the product/MCP team for the manual Langfuse sync (namespace ai-agents/skills/<name>)."
