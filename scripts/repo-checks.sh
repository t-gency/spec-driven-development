#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# repo-checks.sh — the gates this repository applies to itself.
#
#   1 · provenance   no third party's internal policy, vendor or org name
#                    reaches the public layer
#   2 · claims       no compliance-certification language promised in a
#                    skill description
#   3 · internal     nothing under internal/ is tracked by git
#   4 · links        every relative link in the public layer resolves
#
# Run from the repository root. Reports every failure, then exits non-zero,
# so one CI run tells you everything rather than one thing at a time.
#
# LC_ALL=C throughout: these checks sort and compare, and a non-English
# locale makes comm and sort -u disagree silently.
# ---------------------------------------------------------------------------
set -uo pipefail
export LC_ALL=C

fail=0
say()  { printf '\n\033[1m%s\033[0m\n' "$*"; }
bad()  { printf '  \033[31m x \033[0m %s\n' "$*"; fail=1; }
ok()   { printf '  \033[32m ok\033[0m %s\n' "$*"; }
skip() { printf '  \033[33m ~ \033[0m %s\n' "$*"; }

PUBLIC_GLOBS=(README.md CONTRIBUTING.md docs skills seeds plugins .claude-plugin scripts)

# ---------------------------------------------------------------------------
say "1 - Provenance: no third party's internal material in the public layer"

# Anchored with \b so that "registry" does not match GIST and "front matter"
# does not match a front. This is the MD-28 lesson: a bare prefix grep matches
# inside a longer word, which both invents findings and hides real ones.
FORBIDDEN='\b(GIST|G4G|CyberArk|YubiKey|VPR)\b|SSDLC Policy v|Vulnerability Management Policy v|Encryption Key Management Policy|Access Control Policy v|Offense Team|5G-AGE009-HZ|RT-GEN029-GI|glob-ai|glob\.ai|coda-desktop|t-gency-hubs-plugins'

# This file necessarily contains the pattern it forbids. Prose that has to
# quote an identifier opts out per line with the marker below, which is the
# declared-none-visible rule applied to a grep: an exemption is legal, a
# silent one is not.
n_prov=0
while IFS= read -r hit; do
  case "$hit" in
    scripts/repo-checks.sh:*) continue ;;
  esac
  printf '%s' "$hit" | grep -q 'provenance-exempt' && continue
  bad "$hit"
  n_prov=$((n_prov+1))
done < <(grep -rIniE "$FORBIDDEN" "${PUBLIC_GLOBS[@]}" 2>/dev/null)
[ "$n_prov" -eq 0 ] && ok "no forbidden identifiers"

# ---------------------------------------------------------------------------
say "2 - Claims: no compliance certification promised in a skill description"

# The description is the routing table AND the promise. A skill whose
# description offers audit evidence is making a contractual claim, not
# listing a feature.
#
# Two different tests, because a disclaimer legitimately uses the words a
# claim uses. "not a compliance certification" is exactly the sentence we
# want in there; "produce audit evidence for SOC 2" is the one we do not.
n_claim=0
while IFS= read -r skill; do
  desc=$(awk '/^---$/{n++; next} n==1' "$skill" | tr '\n' ' ')
  if printf '%s' "$desc" | grep -qiE 'SOC ?2|ISO ?27001|ISO/IEC ?27001|audit evidence|audit-ready'; then
    bad "$skill - description names an audit framework or promises audit evidence"
    n_claim=$((n_claim+1))
  fi
  if printf '%s' "$desc" | grep -qiE 'compliance certif' \
     && ! printf '%s' "$desc" | grep -qiE 'not a compliance certif'; then
    bad "$skill - description claims a compliance certification"
    n_claim=$((n_claim+1))
  fi
done < <(find skills plugins -name SKILL.md -type f | sort)
[ "$n_claim" -eq 0 ] && ok "no compliance claims in any skill description"

# ---------------------------------------------------------------------------
say "3 - internal/ is not tracked"

if git rev-parse --git-dir >/dev/null 2>&1; then
  tracked=$(git ls-files -- internal/ 2>/dev/null)
  if [ -n "$tracked" ]; then
    bad "internal/ is tracked - this must never be pushed:"
    printf '%s\n' "$tracked" | sed 's/^/      /'
  else
    ok "internal/ untracked"
  fi
else
  skip "not a git repository yet - run this again after 'git init'"
fi

# ---------------------------------------------------------------------------
say "4 - Links: every relative link in the public layer resolves"

n_link=0
while IFS= read -r f; do
  dir=$(dirname "$f")
  while IFS= read -r target; do
    [ -z "$target" ] && continue
    case "$target" in
      http*|mailto:*|\#*)  continue ;;
      *'{{'*|*'<'*)        continue ;;
    esac
    clean=${target%%#*}
    [ -z "$clean" ] && continue
    if [ ! -e "$dir/$clean" ]; then
      bad "$f -> $target"
      n_link=$((n_link+1))
    fi
  done < <(grep -oE '\]\([^)]+\)|href="[^"]+"' "$f" 2>/dev/null \
             | sed -E 's/^\]\(//; s/\)$//; s/^href="//; s/"$//')
done < <(find "${PUBLIC_GLOBS[@]}" -type f \( -name '*.md' -o -name '*.html' \) 2>/dev/null | sort)
[ "$n_link" -eq 0 ] && ok "all relative links resolve"

# ---------------------------------------------------------------------------
if [ "$fail" -ne 0 ]; then
  printf '\n\033[31mrepo-checks: FAILED\033[0m\n'
  exit 1
fi
printf '\n\033[32mrepo-checks: all four passed\033[0m\n'
