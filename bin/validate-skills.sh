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
# Every awk parser strips a trailing '\r' first (CRLF-authored files must lint the
# same as LF files — else '---\r' never matches '^---$' and the split silently breaks).
# exit 1 => no leading '---' (no frontmatter); exit 3 => opening '---' but no closing '---'.
extract_frontmatter() { # $1=file -> stdout
  awk '{ sub(/\r$/, "") }
       NR==1 && $0 !~ /^---[[:space:]]*$/ { exit 1 }
       /^---[[:space:]]*$/ && n<2 { n++; next }
       n==1 { print }
       n>=2 { done=1; exit }
       END { if (!done && n<2) exit 3 }' "$1"
}

extract_body() { # $1=file -> stdout (everything AFTER the second '---')
  awk '{ sub(/\r$/, "") }
       f { print; next }
       /^---[[:space:]]*$/ && !f { c++; if (c==2) f=1 }' "$1"
}

# description value: inline (quoted or bare) OR YAML block scalar (>, |, >-, |-)
# with indented continuation lines, joined with single spaces.
extract_description() { # $1=frontmatter-file -> stdout
  awk '
    { sub(/\r$/, "") }
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
  awk '{ sub(/\r$/, "") }
       /^name:/ { n = $0; sub(/^name:[[:space:]]*/, "", n)
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

  local fm body name desc fm_rc
  fm=$(mktemp) || return 1
  body=$(mktemp) || { rm -f "$fm"; return 1; }
  extract_frontmatter "$file" > "$fm"
  fm_rc=$?
  if [ "$fm_rc" -eq 3 ]; then
    echo "== $file [$shape] — FAIL: unterminated frontmatter (opening '---' at line 1 but no closing '---')"
    rm -f "$fm" "$body"
    AGGREGATE=1
    return 1
  elif [ "$fm_rc" -ne 0 ]; then
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
  # awk NR counts the final line even with no trailing newline; `wc -l` counts
  # newline chars, so a 501-line file whose last line lacks '\n' reports 500 and
  # wrongly passes. awk 'END{print NR}' is the correct line count.
  local lines
  lines=$(awk 'END{print NR}' "$file")
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

  # --- NEW rule (in-product finding b): unescaped '{{ ... }}' in BODY *and* frontmatter ---
  # Langfuse (serve-time) interpolates {{token}} -> empty on the MCP path; unescaped
  # macros silently vanish in-product. This affects the served body AND the
  # description/frontmatter (which is Langfuse-fed too), so v1 flags EVERY '{{' in
  # either. No repo-side escape syntax is defined; the fix is to remove/rephrase.
  local body_brace_hits fm_brace_hits
  body_brace_hits=$(grep -c '{{' "$body" || true)
  fm_brace_hits=$(grep -c '{{' "$fm" || true)
  if [ "$body_brace_hits" -gt 0 ] || [ "$fm_brace_hits" -gt 0 ]; then
    echo "   FAIL unescaped '{{ }}' ($body_brace_hits body + $fm_brace_hits frontmatter line(s) — Langfuse interpolates {{token}} to empty):"
    grep -n '{{' "$body" | head -5 | sed 's/^/        body-line /'
    grep -n '{{' "$fm"   | head -5 | sed 's/^/        frontmatter-line /'
    violations=$((violations + 1))
  else
    echo "   PASS no unescaped '{{ }}' in body or frontmatter"
  fi

  # --- NEW rule: leftover template scaffolding in the served BODY ---
  # An authored skill must not ship the template's fill-in scaffolding: '[BRACKET]'
  # placeholders, '<!-- ... -->' guidance comments, or 'AC-<number>' PRD citations.
  # These are authoring artifacts that leak into the served get-skill body.
  # Scope: authored skills only. '_framework/*.template.md' is exempt (it IS the
  # scaffolding) and is excluded from lint targets by callers, but guard here too.
  case "$file" in
    _framework/*.template.md|*/[A-Z]*.template.md) : ;;  # template file — do not lint body scaffolding
    *)
      local leak_bracket leak_comment leak_ac leak=0
      # bracketed placeholder starting with an uppercase letter, NOT a markdown link
      # (a real link is '[text](url)'; a placeholder is '[Skill Title …]' with no '(' after ']').
      leak_bracket=$(grep -nE '\[[A-Z][^]]*\]([^(]|$)' "$body" || true)
      leak_comment=$(grep -nF '<!--' "$body" || true)
      leak_ac=$(grep -nE 'AC-[0-9]' "$body" || true)
      if [ -n "$leak_bracket" ]; then
        echo "   FAIL leftover template scaffolding: '[BRACKET]'-style placeholder in body:"
        printf '%s\n' "$leak_bracket" | head -5 | sed 's/^/        body-line /'
        leak=1
      fi
      if [ -n "$leak_comment" ]; then
        echo "   FAIL leftover template scaffolding: guidance comment '<!-- ... -->' in body:"
        printf '%s\n' "$leak_comment" | head -5 | sed 's/^/        body-line /'
        leak=1
      fi
      if [ -n "$leak_ac" ]; then
        echo "   FAIL leftover template scaffolding: 'AC-<number>' PRD citation in body:"
        printf '%s\n' "$leak_ac" | head -5 | sed 's/^/        body-line /'
        leak=1
      fi
      if [ "$leak" -eq 0 ]; then
        echo "   PASS no leftover template scaffolding in body"
      else
        violations=$((violations + 1))
      fi
      ;;
  esac

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
