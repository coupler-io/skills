#!/usr/bin/env bash
# build-skill.sh — bundle -> flat-for-get-skill inliner (AC-2.2, T-4a/T-4b/T-4c)
#
# *** PROVISIONAL — pending Peter's runtime confirmation ***
# (references-bundling / size cap / {{ }} escaping — the AC-2.3 open items).
# NO flat output is handed to the product/MCP team until the T-4 gate clears.
# PM decision 2026-07-07 (Aurelien): build now, label PROVISIONAL, adjust when answers land.
#
# Invoke FROM REPO ROOT: bin/build-skill.sh <repo-root-relative-bundle-dir>
#   e.g. bin/build-skill.sh marketing/marketing-analytics
# Emits: build/<name>.flat.md   (build/ is git-ignored; artifacts are never committed)
#
# Behaviour:
#   - strips frontmatter (get-skill strips it anyway — live-probe fact 1, conventions.md)
#   - inlines each references/<file>.md link / read directive AT ITS LINK SITE
#   - FAILS CLOSED (exit 1, no artifact) if any references/*.md link cannot be resolved
#   - WARNS on residual non-.md 'references/' mentions (e.g. runtime dirs) in the flat output
#   - WARNS if the flat output contains unescaped {{ }} (Langfuse interpolates {{token}} -> empty)
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
strip_frontmatter() { # $1=file -> stdout
  awk 'NR==1 && $0 !~ /^---[[:space:]]*$/ { nofm=1 }
       nofm { print; next }
       /^---[[:space:]]*$/ && c<2 { c++; next }
       c>=2 { print }' "$1"
}

# --- fail-closed: every references/*.md link in the body must resolve to a real file
MISSING=0
REFS="$(grep -o 'references/[[:alnum:]._/-]*\.md' "$SKILL" | sort -u || true)"
if [ -n "$REFS" ]; then
  while IFS= read -r ref; do
    if [ ! -f "$BUNDLE/$ref" ]; then
      echo "ERROR: unresolved reference link: $ref (no file $BUNDLE/$ref)" >&2
      MISSING=1
    fi
  done <<EOF
$REFS
EOF
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
    full = bundle "/" path
    # delimiter must NOT contain the literal "references/" — the flat output is
    # verified with grep -c "references/" == 0 (T-4b/T-4c)
    base = path; sub(/^references\//, "", base)
    print ""
    print "<!-- inlined reference: " base " (by build-skill.sh) -->"
    while ((getline l < full) > 0) print l
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
  echo "WARN: flat output contains unescaped '{{ }}' — Langfuse interpolates {{token}} -> EMPTY on the MCP path (AC-2.3 open item):" >&2
  grep -n '{{' "$OUT" >&2
fi

BYTES="$(wc -c < "$OUT" | tr -d ' ')"
if [ "$STATUS" -ne 0 ]; then
  mv "$OUT" "$OUT.FAILED"
  echo "FAIL-CLOSED: artifact moved to $OUT.FAILED (size: $BYTES bytes) — do not ship." >&2
  exit "$STATUS"
fi

echo "BUILT (PROVISIONAL): $OUT"
echo "size: $BYTES bytes — get-skill hard cap UNKNOWN, pending Peter (record only, no cap claim)"
echo "PROVISIONAL — pending Peter's runtime confirmation (references-bundling / size cap / {{ }} escaping)."
echo "Do NOT hand this flat output to the product/MCP team until the T-4 gate clears."
