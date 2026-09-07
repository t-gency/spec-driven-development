#!/usr/bin/env bash
#
# Red-tests for closed-set-consistency.sh.
#
# A checker validated only by watching it PASS on a healthy tree is
# indistinguishable from a checker that tests a mere *proxy* of the property it
# claims to verify: "the file contains `T-N.D20`" instead of "the gate table has
# a `T-N.D20` row"; "`AC-5[0-9]` has a match" instead of "the AC family's max".
# Proxy and property agree on every healthy input and diverge exactly on the
# defect — which a green-only test never constructs. That gap is where every
# recurrence of the propagation bug has lived, including inside this gate itself.
#
# So this file does the opposite: it reconstructs each defect the MD-32 row
# claims the gate catches, on a throwaway copy, and asserts the gate REJECTS it
# (non-zero exit). Every "catches X" in DESIGN_RATIONALE §MD-32 is an assertion
# here. If a future change weakens the gate back toward a whole-file grep, the
# gate-table case goes green and this test goes red — which is the point.
#
# Usage:  bash scripts/closed-set-consistency.test.sh
# Exit:   0 = every defect is rejected as it should be · 1 = the gate let one pass

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"          # the plugin dir (engineering-methodology)
GATE="$HERE/closed-set-consistency.sh"
SK="skills"
pass=0; fail=0; tmps=()
cleanup(){ for d in "${tmps[@]:-}"; do [ -n "$d" ] && rm -rf "$d"; done; }
trap cleanup EXIT

gate_exit(){ bash "$GATE" "$1" >/dev/null 2>&1; echo $?; }
mk(){ local d; d="$(mktemp -d)"; cp -R "$ROOT/." "$d/"; tmps+=("$d"); echo "$d"; }
drop(){ grep -vE "$2" "$1" > "$1.x" && mv "$1.x" "$1"; }   # delete matching lines
assert(){ # assert <name> <expected> <actual>
  if [ "$2" = "$3" ]; then echo "  ✓ $1"; pass=$((pass+1))
  else echo "  ✗ $1 — expected exit $2, got $3"; fail=$((fail+1)); fi
}

# 0. the healthy tree must PASS (no false positives)
assert "healthy tree is consistent" 0 "$(gate_exit "$ROOT")"

# 1. gate-table half-propagation — the exact defect this MD closes:
#    remove the T-N.D20 gate-table ROW; D20 still occurs in the two-populations
#    table and in prose, so a whole-file grep would pass green here.
d="$(mk)"; drop "$d/$SK/spec-conformance/references/mechanical-gates.md" '^\| .?T-N\.D20.? \|'
assert "gate table stops at D19 while D20 lives in a sibling table → rejected" 1 "$(gate_exit "$d")"

# 2. verdict-source bullet gutted — AC-55 still named in the subset comment above it
d="$(mk)"; drop "$d/$SK/spec-conformance/references/grounding-contract.md" '^- .?AC-55.? '
assert "grounding-contract AC-55 verdict bullet removed → rejected" 1 "$(gate_exit "$d")"

# 3. supply-chain citation axis line removed
d="$(mk)"; drop "$d/$SK/spec-conformance/references/report-shape.md" 'Supply-chain-axis'
assert "report-shape supply-chain axis removed → rejected" 1 "$(gate_exit "$d")"

# 4. AC→gate map entry removed — AC-55 still present in its definition bullet
d="$(mk)"; drop "$d/$SK/staged-engineering-doc/references/spec-guidance.md" 'AC-55.*T-N\.D20'
assert "spec-guidance AC-55→gate map entry removed → rejected" 1 "$(gate_exit "$d")"

d="$(mk)"; drop "$d/$SK/staged-engineering-doc/references/implementation-plan-guidance.md" 'AC-55.*T-N\.D20'
assert "impl-plan-guidance AC-55→gate map entry removed → rejected" 1 "$(gate_exit "$d")"

# 5. range reverted to the penultimate — currency's job
d="$(mk)"; sed 's/AC-50…AC-55/AC-50…AC-54/' "$d/$SK/three-p-visualizer/references/content-mapping.md" > "$d/cm.x" \
  && mv "$d/cm.x" "$d/$SK/three-p-visualizer/references/content-mapping.md"
assert "visualizer card range reverted to AC-54 → rejected (currency)" 1 "$(gate_exit "$d")"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
