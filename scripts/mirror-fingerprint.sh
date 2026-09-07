#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# mirror-fingerprint.sh - proves plugins/engineering-methodology/ has not
# changed since UPSTREAM.md last recorded it.
#
#   scripts/mirror-fingerprint.sh          verify  (exit 1 on drift)
#   scripts/mirror-fingerprint.sh --write  record the current tree
#
# The fingerprint is a sorted list of path + content hash for every file in
# the mirror, hashed once. UPSTREAM.md itself is excluded: it is the record,
# not part of what is recorded, and including it would make every write
# invalidate itself.
#
# Why this exists: the mirror's upstream is a private repository, so CI cannot
# diff against it. What CI can prove is that nobody edited the mirror without
# updating its record - which is the drift that actually bites, and the one
# nobody notices for six months.
#
# If you forked this repository to adopt the methodology, you have no upstream:
# delete UPSTREAM.md, delete this script, and drop the CI step.
# ---------------------------------------------------------------------------
set -uo pipefail
export LC_ALL=C

MIRROR="plugins/engineering-methodology"
RECORD="$MIRROR/UPSTREAM.md"

[ -d "$MIRROR" ] || { echo "mirror-fingerprint: $MIRROR not found - run from the repo root" >&2; exit 2; }
[ -f "$RECORD" ] || { echo "mirror-fingerprint: no $RECORD - nothing to verify. If this fork has no upstream, remove this script from CI." >&2; exit 0; }

# Resolve the hasher into a plain command. It must NOT be a shell function:
# xargs cannot call one, and the failure is exit 127 with no output - a gate
# that silently does nothing, which is worse than no gate at all.
if command -v sha256sum >/dev/null 2>&1; then
  SHA="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
  SHA="shasum -a 256"
else
  echo "mirror-fingerprint: no sha256sum or shasum available" >&2; exit 2
fi

current=$(
  find "$MIRROR" -type f ! -name UPSTREAM.md -print0 \
    | sort -z \
    | xargs -0 $SHA \
    | $SHA \
    | cut -c1-16
)
[ -n "$current" ] || { echo "mirror-fingerprint: could not compute a fingerprint" >&2; exit 2; }

recorded=$(sed -n 's/^| \*\*Tree fingerprint\*\* | *`\{0,1\}\([^`|]*\)`\{0,1\} *|.*/\1/p' "$RECORD" | tr -d ' ')

if [ "${1:-}" = "--write" ]; then
  python3 - "$RECORD" "$current" <<'PY'
import re, sys, pathlib, datetime
record, fp = pathlib.Path(sys.argv[1]), sys.argv[2]
t = record.read_text(encoding='utf-8')
t, n1 = re.subn(r'(\| \*\*Tree fingerprint\*\* \| )[^|]*(\|)', r'\1`%s` \2' % fp, t, count=1)
t, n2 = re.subn(r'(\| \*\*Mirrored on\*\* \| )[^|]*(\|)',
                r'\1`%s` \2' % datetime.date.today().isoformat(), t, count=1)
if not n1:
    sys.exit("mirror-fingerprint: no 'Tree fingerprint' row in UPSTREAM.md to write into")
record.write_text(t, encoding='utf-8')
print("recorded fingerprint", fp, "(and today's date)" if n2 else "")
PY
  rc=$?
  [ $rc -eq 0 ] && echo "Now set the upstream SHA in $RECORD by hand, and commit the tree and the record together."
  exit $rc
fi

case "$recorded" in
  ""|TODO*) echo "mirror-fingerprint: UPSTREAM.md has no fingerprint yet."
            echo "  current tree: $current"
            echo "  record it with: scripts/mirror-fingerprint.sh --write"
            exit 1 ;;
esac

if [ "$current" != "$recorded" ]; then
  cat >&2 <<EOF
mirror-fingerprint: DRIFT

  recorded in UPSTREAM.md : $recorded
  current tree            : $current

The mirror changed without its record changing. Either:
  - you edited the mirror directly - do not; edit upstream and re-sync, or
    accept this fork as the source of truth and delete UPSTREAM.md; or
  - you re-synced and forgot the record - run:
        scripts/mirror-fingerprint.sh --write
    then set the upstream SHA and commit the tree and the record together.
EOF
  exit 1
fi

echo "mirror-fingerprint: ok ($current)"
