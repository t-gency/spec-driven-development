#!/usr/bin/env bash
#
# closed-set-consistency.sh — the MD-32 gate.
#
# The methodology has four skills (staged-engineering-doc, three-p-visualizer,
# spec-answers, spec-conformance) whose closed ID sets are COUPLED: when one set
# gains a member, every skill that enumerates it must move together. Nothing else
# catches a *half*-propagated set — one skill declaring a member its own sibling
# reference doesn't know about — which reads as a silent pass (MD-32; promoted
# from EVO-08 after the pattern recurred three review rounds, once inside the
# very commit that was fixing it).
#
# Two closed sets are coupled across the skills:
#   - meta-ACs   AC-50..AC-<max>          canonical: SPEC_TEMPLATE.md §11.5
#   - DoD gates  T-N.D1..T-N.D<max>       canonical: IMPLEMENTATION_PLAN_TEMPLATE.md §7.x.9
#
# SCOPE: the operational skill files under skills/ — the instruction, template,
# guidance and reference files a running agent reads. A stale enumeration there
# produces a wrong result. DESIGN_RATIONALE.md (rationale archive; its rows
# describe decisions at their time) and README changelog rows (historical) are
# out of scope by design and are not scanned.
#
# The gate is deliberately narrow — it verifies *currency* (no enumeration lags
# the canonical maximum) and *presence* (the load-bearing sites carry the newest
# member). Whether a given site *should* carry a member is human judgement, kept
# at review time exactly as MD-25 / MD-26 keep their semantic half.
#
# A line opts out of the currency check with the literal marker  closed-set:subset
# in an HTML comment, for prose that intentionally references a subset (e.g.
# "the AC-50..AC-54 document-axis meta-ACs, alongside which AC-55 is a third
# axis"). Silent omission is the defect; a declared subset is fine — the same
# declared-none-visible rule as MD-25.
#
# Usage:   bash procedures/engineering-methodology/scripts/closed-set-consistency.sh
#          ROOT auto-resolves from the script's own location, so any CWD works;
#          pass an explicit ROOT as $1 only to check a different tree.
# Exit:    0 = consistent · 1 = drift (each offending line named) · 2 = templates unreadable

set -uo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SKILLS="$ROOT/skills"
SPEC="$SKILLS/staged-engineering-doc/templates/SPEC_TEMPLATE.md"
PLAN="$SKILLS/staged-engineering-doc/templates/IMPLEMENTATION_PLAN_TEMPLATE.md"
fail=0

# ── canonical maxima (read from the templates that define the sets) ──
# Match the AC family UNBOUNDED (AC-[0-9]+), not a hardcoded decade (AC-5[0-9]) —
# a decade-bounded class silently caps max_ac at the highest AC in 50-59 once the
# set grows into the 60s, the exact silent-pass this gate exists to prevent. The
# D-side is already unbounded; keep them symmetric.
max_ac=$(grep -oE '\*\*AC-[0-9]+\*\*' "$SPEC" | grep -oE '[0-9]+' | sort -n | tail -1)
max_d=$(grep -oE 'T-1\.D[0-9]+' "$PLAN" | grep -oE '[0-9]+' | sort -n | tail -1)
# Fail loud if either template went unread: an empty max makes the arithmetic
# below garbage and prints false ✓ lines for checks that verified nothing.
if [ -z "$max_ac" ] || [ -z "$max_d" ]; then
  echo "closed-set-consistency: could not read canonical maxima under $ROOT" >&2
  echo "  (looked for $SPEC and $PLAN)" >&2
  exit 2
fi
pen_ac=$((max_ac - 1))
pen_d=$((max_d - 1))
echo "canonical: meta-ACs → AC-50..AC-${max_ac} · DoD gates → T-N.D1..T-N.D${max_d}"
echo

# grep the operational skill files, strip backticks so `T-N.D8`–`D19` reads as a
# plain range, drop changelog rows and lines that declare an intentional subset.
scan() {  # scan <extended-regex>
  grep -rnE --include='*.md' "$1" "$SKILLS" 2>/dev/null \
    | sed 's/`//g' \
    | grep -vE '\| [0-9]+\.[0-9]+\.[0-9]+ \||closed-set:subset' || true
}

report() {  # report <label> <offending-lines>
  local label="$1" out="$2"
  if [ -n "$out" ]; then
    echo "  ✗ $label"
    printf '%s\n' "$out" | sed 's|^|        |'
    fail=1
  else
    echo "  ✓ $label"
  fi
}

# ── 1. range currency: a line naming BOTH endpoints of the growing enumeration ──
#      (AC-50 and AC-<pen>, or a D-range dash reaching D-<pen>) must also name the
#      current maximum. Bare mentions of the penultimate member on its own (its
#      definition, its own gate row) are not enumerations and are left alone.

ac_stale=$(scan "AC-50" | grep -E "AC-${pen_ac}" | grep -vE "AC-${max_ac}")
report "meta-AC currency — any AC-50…AC-${pen_ac} enumeration also reaches AC-${max_ac}" "$ac_stale"

# Prefilter on the bare penultimate token (a plain substring that matches through
# backticks), THEN apply the precise range regex to the backtick-stripped stream
# `scan` returns. BSD-portable: no \b (GNU-only) — bound with ([^0-9]|end), and
# match en-dash or hyphen explicitly.
d_stale=$(scan "D${pen_d}" \
          | grep -E "D[0-9]+ *(–|-) *(T-N\.)?D${pen_d}([^0-9]|$)" \
          | grep -vE "D${max_d}")
report "DoD-gate range currency — any …–D${pen_d} range also reaches D${max_d}" "$d_stale"

# ── 2. count currency: "<N> meta-ACs:" (colon → introduces the full list) must ──
#      equal max_ac-49. The parenthetical subset form "three meta-ACs (AC-50…)"
#      has no colon and is not a full-set count.
words=(zero one two three four five six seven eight nine ten)
want_n=$((max_ac - 49))
# Guard the spelled-number index (and drop GNU-only \b — BSD grep, the same
# portability class an earlier draft shipped) so a set that grows past "ten"
# skips the count check loudly instead of crashing on a bad array subscript.
if [ "$want_n" -ge 0 ] && [ "$want_n" -lt "${#words[@]}" ]; then
  count_stale=$(scan "(one|two|three|four|five|six|seven|eight|nine|ten) meta-?ACs:" \
                | grep -viE "${words[$want_n]} meta")
  report "meta-AC count — '<N> meta-ACs:' equals ${words[$want_n]} (${want_n})" "$count_stale"
else
  echo "  · meta-AC count — set size ${want_n} outside spelled-number range; skipped"
fi

# ── 3. presence in the load-bearing STRUCTURE (not merely somewhere in the file) ──
#      A whole-file token grep is defeated by the exact half-propagation this gate
#      exists to catch: the newest member sits in prose, in a range, or in a
#      sibling table while its load-bearing row is missing — e.g. the gate table
#      stops at D19 while the two-populations table still cites D20, so a
#      grep for "T-N.D20" over the whole file passes green on the defect. So each
#      site carries a STRUCTURAL regex matched with `grep -cE >= 1` against the
#      backtick-stripped file: the gate-table ROW, the verdict BULLET, the AC→gate
#      MAP entry — the shape the member must occupy, not just its name.
#
#      Row / bullet / map shapes are guarded ONLY here — the currency check can't
#      see them (no range string to go stale). The last two (partition, visualizer
#      card) are range-shaped and ALSO covered by currency; their rows here are a
#      documented second line. Parallel arrays, not a `|`-delimited string, because
#      these regexes contain literal pipes.
declare -a REG_PATH=(
  "spec-conformance/references/mechanical-gates.md"
  "spec-conformance/references/grounding-contract.md"
  "spec-conformance/references/report-shape.md"
  "staged-engineering-doc/references/spec-guidance.md"
  "staged-engineering-doc/references/implementation-plan-guidance.md"
  "spec-conformance/SKILL.md"
  "three-p-visualizer/references/content-mapping.md"
)
declare -a REG_RE=(
  "^\| *T-N\.D${max_d} *\|"
  "^- AC-${max_ac} "
  "Supply-chain-axis.*AC-${max_ac}"
  "AC-${max_ac}.*T-N\.D${max_d}"
  "AC-${max_ac}.*T-N\.D${max_d}"
  "AC-50.*AC-${max_ac}"
  "AC-50.*AC-${max_ac}"
)
declare -a REG_LABEL=(
  "spec-conformance gate table — no \`| T-N.D${max_d} |\` row (D${max_d} elsewhere in the file does not count)"
  "grounding-contract — no \`- AC-${max_ac}\` verdict bullet"
  "report-shape — no supply-chain-axis line naming AC-${max_ac}"
  "spec-guidance — no \`AC-${max_ac} → T-N.D${max_d}\` gate-map entry"
  "impl-plan-guidance — no \`AC-${max_ac} → T-N.D${max_d}\` gate-map entry"
  "spec-conformance SKILL — no AC-50..AC-${max_ac} partition range"
  "visualizer content-mapping — no AC-50..AC-${max_ac} card range"
)
miss=""
for i in "${!REG_PATH[@]}"; do
  f="$SKILLS/${REG_PATH[$i]}"
  n=$(sed 's/`//g' "$f" 2>/dev/null | grep -cE "${REG_RE[$i]}")
  if [ "${n:-0}" -eq 0 ]; then
    miss="${miss}${miss:+$'\n'}${REG_LABEL[$i]} (${REG_PATH[$i]})"
  fi
done
report "load-bearing sites carry the newest member in its structure (AC-${max_ac} / T-N.D${max_d})" "$miss"

echo
if [ "$fail" -eq 0 ]; then
  echo "closed sets consistent."
else
  echo "closed-set drift — a skill enumerates a set its sibling does not. Propagate before merge."
fi
exit "$fail"
