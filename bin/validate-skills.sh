#!/usr/bin/env bash
# validate-skills.sh — spec linter for coupler-io-skills (AC-2.1)
# Invoke FROM REPO ROOT: bin/validate-skills.sh <repo-root-relative-path> [...]
# A path may be a flat skill .md, a bundle SKILL.md, or a bundle dir containing SKILL.md.
# Emits PER-SKILL pass/fail; exits non-zero if ANY skill fails (fail-closed).
set -uo pipefail

if [ "$#" -lt 1 ]; then
  echo "usage: bin/validate-skills.sh <repo-root-relative-path> [...]" >&2
  exit 2
fi

AGGREGATE=0

# --- frontmatter/body split: ONLY the first two '---' lines delimit frontmatter.
# Body horizontal rules ('---' further down) are legitimate markdown, never delimiters.
extract_frontmatter() { # $1=file -> stdout
  awk 'NR==1 && $0 !~ /^---[[:space:]]*$/ { exit 1 }
       /^---[[:space:]]*$/ && n<2 { n++; next }
       n==1 { print }
       n>=2 { exit }' "$1"
}

extract_body() { # $1=file -> stdout (everything AFTER the second '---')
  awk 'f { print; next }
       /^---[[:space:]]*$/ && !f { c++; if (c==2) f=1 }' "$1"
}

# description value: inline (quoted or bare) OR YAML block scalar (>, |, >-, |-)
# with indented continuation lines, joined with single spaces.
extract_description() { # $1=frontmatter-file -> stdout
  awk '
    /^description:/ {
      d = $0; sub(/^description:[[:space:]]*/, "", d)
      if (d == ">" || d == "|" || d == ">-" || d == "|-") { d = "" }
      indesc = 1; desc = d; next
    }
    indesc {
      if ($0 ~ /^[^[:space:]]/) { indesc = 0 }
      else { s = $0; sub(/^[[:space:]]+/, "", s)
             if (desc == "") desc = s; else desc = desc " " s }
    }
    END {
      sub(/^"/, "", desc); sub(/"$/, "", desc)
      print desc
    }' "$1"
}

extract_name() { # $1=frontmatter-file -> stdout
  awk '/^name:/ { n = $0; sub(/^name:[[:space:]]*/, "", n)
                  sub(/^"/, "", n); sub(/"$/, "", n); print n; exit }' "$1"
}

validate_one() { # $1=path
  local path="$1" file shape identifier
  local violations=0

  # scope-outs by name (T-3e): never scanned in v1
  case "$path" in
    coupler-live-artifact/*|coupler-live-artifact|humanizer/*|humanizer)
      echo "== $path — SCOPED OUT of v1 lint target (by name), not scanned"
      return 0 ;;
  esac

  # resolve dir -> bundle SKILL.md
  if [ -d "$path" ]; then
    file="${path%/}/SKILL.md"
  else
    file="$path"
  fi
  if [ ! -f "$file" ]; then
    echo "== $path — FAIL: no such skill file ($file)"
    AGGREGATE=1
    return 1
  fi

  # shape detection (conventions.md § name == identifier rule):
  # bundle = file named SKILL.md -> identifier is the parent DIRECTORY name
  # flat   = any other .md       -> identifier is the FILENAME STEM
  local base parent
  base=$(basename "$file")
  if [ "$base" = "SKILL.md" ]; then
    shape="bundle"
    parent=$(dirname "$file")
    identifier=$(basename "$parent")
  else
    shape="flat"
    identifier="${base%.md}"
  fi

  local fm body name desc
  fm=$(mktemp) || return 1
  body=$(mktemp) || { rm -f "$fm"; return 1; }
  if ! extract_frontmatter "$file" > "$fm"; then
    echo "== $file [$shape] — FAIL: no frontmatter block at line 1"
    rm -f "$fm" "$body"
    AGGREGATE=1
    return 1
  fi
  extract_body "$file" > "$body"
  name=$(extract_name "$fm")
  desc=$(extract_description "$fm")

  echo "== $file [$shape] name='$name' identifier='$identifier'"

  # --- T-3a: name == identifier, branching on shape ---
  if [ -z "$name" ]; then
    echo "   FAIL name: missing 'name' key in frontmatter"
    violations=$((violations + 1))
  elif [ "$name" != "$identifier" ]; then
    echo "   FAIL name==identifier: name '$name' != $shape identifier '$identifier'"
    violations=$((violations + 1))
  else
    echo "   PASS name==identifier ($shape: '$identifier')"
  fi

  # --- T-3b: name matches ^[a-z0-9-]{1,64}$ and contains no '--' ---
  if [ -n "$name" ]; then
    if ! printf '%s' "$name" | grep -Eq '^[a-z0-9-]{1,64}$'; then
      echo "   FAIL name pattern: '$name' does not match ^[a-z0-9-]{1,64}\$"
      violations=$((violations + 1))
    elif printf '%s' "$name" | grep -q -- '--'; then
      echo "   FAIL name pattern: '$name' contains '--'"
      violations=$((violations + 1))
    else
      echo "   PASS name pattern"
    fi
  fi

  # --- T-3c: description <= 1024 chars ---
  if [ -z "$desc" ]; then
    echo "   FAIL description: missing 'description' key in frontmatter"
    violations=$((violations + 1))
  elif [ "${#desc}" -gt 1024 ]; then
    echo "   FAIL description length: ${#desc} chars > 1024"
    violations=$((violations + 1))
  else
    echo "   PASS description length (${#desc}/1024)"
  fi

  # --- T-3d: file <= 500 lines ---
  local lines
  lines=$(wc -l < "$file" | tr -d '[:space:]')
  if [ "$lines" -gt 500 ]; then
    echo "   FAIL file length: $lines lines > 500"
    violations=$((violations + 1))
  else
    echo "   PASS file length ($lines/500)"
  fi

  # --- T-3d: required frontmatter key metadata.version ---
  # ('name' and 'description' presence already enforced by the checks above.)
  if grep -q '^metadata:' "$fm" && grep -Eq '^[[:space:]]+version:' "$fm"; then
    echo "   PASS metadata.version present"
  else
    echo "   FAIL required frontmatter key missing: metadata.version"
    violations=$((violations + 1))
  fi

  # --- NEW rule (in-product finding b): unescaped '{{ ... }}' in BODY ---
  # Langfuse interpolates {{token}} -> empty on the MCP path; unescaped macros
  # silently vanish in-product. No escape syntax is defined yet (open Peter item),
  # so v1 flags EVERY '{{' in the body.
  local brace_hits
  brace_hits=$(grep -c '{{' "$body" || true)
  if [ "$brace_hits" -gt 0 ]; then
    echo "   FAIL unescaped '{{ }}' in body ($brace_hits line(s) — Langfuse interpolates {{token}} to empty):"
    grep -n '{{' "$body" | head -5 | sed 's/^/        body-line /'
    violations=$((violations + 1))
  else
    echo "   PASS no unescaped '{{ }}' in body"
  fi

  rm -f "$fm" "$body"
  if [ "$violations" -gt 0 ]; then
    echo "   RESULT: FAIL ($violations violation(s))"
    AGGREGATE=1
    return 1
  fi
  echo "   RESULT: PASS"
  return 0
}

for p in "$@"; do
  validate_one "$p"
done

exit "$AGGREGATE"
