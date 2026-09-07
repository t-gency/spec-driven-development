#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# build-site.sh - inline docs/method.css into every page in docs/.
#
#   scripts/build-site.sh          write the inlined CSS into each page
#   scripts/build-site.sh --check  fail if any page is stale (for CI)
#
# Why the pages are self-contained rather than linking a stylesheet:
# these files get opened straight off a synced folder, emailed, dropped into
# a chat, and read offline. A sibling <link> breaks every one of those, and
# the failure is silent - the page renders, just naked.
#
# Why the CSS still has one home: hand-maintaining five copies is how they
# drift. So method.css is the source, this script is the generator, and the
# inlined block sits between markers that nobody edits by hand. That is the
# generated-block rule from docs/08-the-docs-system.md applied to ourselves:
# if you find yourself maintaining a copy of machine-readable truth,
# generate it instead, and let CI fail on a stale block.
# ---------------------------------------------------------------------------
set -uo pipefail
export LC_ALL=C

CSS="docs/method.css"
[ -f "$CSS" ] || { echo "build-site: $CSS not found - run from the repo root" >&2; exit 2; }

mode="write"
[ "${1:-}" = "--check" ] && mode="check"

stale=0
built=0

for page in docs/*.html; do
  [ -e "$page" ] || continue
  python3 - "$page" "$CSS" "$mode" <<'PY'
import sys, pathlib, re
page, css_path, mode = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
css  = css_path.read_text(encoding='utf-8').strip()
html = page.read_text(encoding='utf-8')

OPEN  = '<style data-src="method.css">'
CLOSE = '</style>'
BANNER = ("/* GENERATED from docs/method.css - do not edit here.\n"
          "   Edit method.css and run scripts/build-site.sh */\n")
block = OPEN + "\n" + BANNER + css + "\n" + CLOSE

# First build: replace the <link>. Later builds: replace the marked block.
link = '<link rel="stylesheet" href="method.css">'
pat  = re.compile(re.escape(OPEN) + r'.*?' + re.escape(CLOSE), re.S)

if pat.search(html):
    new = pat.sub(lambda _: block, html, count=1)
elif link in html:
    new = html.replace(link, block, 1)
else:
    print(f"  ?  {page} - no stylesheet link or generated block found")
    sys.exit(3)

if new == html:
    sys.exit(0)          # up to date
if mode == "check":
    print(f"  STALE {page}")
    sys.exit(1)
page.write_text(new, encoding='utf-8')
print(f"  built {page}")
sys.exit(10)
PY
  rc=$?
  case $rc in
    0)  ;;                       # already current
    10) built=$((built+1)) ;;
    1)  stale=$((stale+1)) ;;
    *)  echo "build-site: failed on $page" >&2; exit 2 ;;
  esac
done

if [ "$mode" = "check" ]; then
  if [ "$stale" -ne 0 ]; then
    echo "build-site: $stale page(s) stale - run scripts/build-site.sh and commit the result" >&2
    exit 1
  fi
  echo "build-site: every page carries the current method.css"
  exit 0
fi

echo "build-site: $built page(s) rebuilt, $(ls docs/*.html | wc -l) total"
