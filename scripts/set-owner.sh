#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# set-owner.sh - point this repository's install path at its real home.
#
#   scripts/set-owner.sh <owner>/<repo>   rewrite every reference
#   scripts/set-owner.sh --check          show what is referenced today
#
# The owner is not cosmetic. It appears in the install command a colleague
# copy-pastes, in the GitHub Pages URL, in the marketplace manifest, and in
# every "Methodology: ...@<sha>" citation a Spec carries. A wrong owner reads
# as "marketplace not found", which looks like the plugin does not exist
# rather than like a typo.
#
# So it lives in one command instead of in five files someone edits by hand
# and gets four right. Forked this? Run it once with your own path.
#
# What is deliberately NOT in the file list below:
# plugins/engineering-methodology/ - the mirror. An install path baked into a
# mirrored file is wrong in every copy but one, and editing the mirror trips
# scripts/mirror-fingerprint.sh. The plugin's own README points at the host
# repository's README instead.
#
# GitHub does redirect after a repository transfer, and git follows the
# redirect - but a citation written before the move points at a redirect, and
# a redirect stops working the day someone creates a repo with the old name.
# Run this BEFORE the first push, not after.
# ---------------------------------------------------------------------------
set -uo pipefail
export LC_ALL=C

FILES=(
  README.md
  CONTRIBUTING.md
  docs/00-quickstart.md
  docs/05-plugins-and-skills.md
  docs/index.html
  docs/quickstart.html
  .claude-plugin/marketplace.json
  internal/README.md
)

[ -f .claude-plugin/marketplace.json ] || { echo "set-owner: run from the repository root" >&2; exit 2; }

if [ "${1:-}" = "--check" ] || [ -z "${1:-}" ]; then
  echo "Referenced today:"
  grep -rhoE 'marketplace add [^ `]+' "${FILES[@]}" 2>/dev/null | sort -u | sed 's/^/  /'
  grep -rhoE 'https://[A-Za-z0-9_.<>-]+\.github\.io/[A-Za-z0-9_.<>-]+' "${FILES[@]}" 2>/dev/null | sort -u | sed 's/^/  /'
  grep -rhoE 'https://github\.com/[A-Za-z0-9_.<>-]+/[A-Za-z0-9_.<>-]+' "${FILES[@]}" 2>/dev/null | sort -u | sed 's/^/  /'
  [ -z "${1:-}" ] && { echo; echo "usage: scripts/set-owner.sh <owner>/<repo>"; exit 1; }
  exit 0
fi

target="$1"
case "$target" in */*) ;; *) echo "set-owner: expected <owner>/<repo>, got '$target'" >&2; exit 2 ;; esac
owner="${target%%/*}"
repo="${target##*/}"
case "$owner" in ""|*/*) echo "set-owner: bad owner in '$target'" >&2; exit 2 ;; esac
case "$repo"  in ""|*/*) echo "set-owner: bad repo in '$target'"  >&2; exit 2 ;; esac

python3 - "$owner" "$repo" "${FILES[@]}" <<'PY'
import re, sys, pathlib
owner, repo, files = sys.argv[1], sys.argv[2], sys.argv[3:]
slug = owner + "/" + repo

# Anchored on CONTEXT, not on the repository's name.
#
# The tempting version matches "<owner>/<repo>" by shape and rewrites every
# slug it finds - which also rewrites github.com/github/spec-kit, an external
# citation that has nothing to do with us. Same class of bug as an unanchored
# ID grep: it matches inside something longer and quietly corrupts it.
#
# So each pattern carries the text that can only mean "us": the command that
# precedes it, the .github.io host shape, the /tree/<sha>/ path of a version
# citation, or the JSON key. Anything without that context is somebody else's.
# One path segment: an HTML-escaped placeholder, a raw placeholder, or a real
# name. Raw < and > are NOT in the plain-name alternative on purpose: with them
# in the class the repo part of "spec-driven-development</code>" would swallow
# the "<" of the closing tag and silently corrupt the page.
SEG = r'(?:&lt;[a-z-]+&gt;|<[a-z-]+>|[A-Za-z0-9_.-]+)'
ANY = SEG
subs = [
    (re.compile(r'(marketplace add )' + ANY + r'/' + ANY),
     lambda m: m.group(1) + slug),
    (re.compile(r'https://' + ANY + r'\.github\.io/' + ANY),
     lambda m: 'https://' + owner + '.github.io/' + repo),
    (re.compile(r'https://github\.com/' + ANY + r'/' + ANY + r'(/tree/)'),
     lambda m: 'https://github.com/' + slug + m.group(1)),
    (re.compile(r'("url": *")https://github\.com/' + ANY + r'/' + ANY + r'(")'),
     lambda m: m.group(1) + 'https://github.com/' + slug + m.group(2)),
    (re.compile(r'(`)' + ANY + r'/' + ANY + r'(@<sha>`)'),
     lambda m: m.group(1) + slug + m.group(2)),
]
total = 0
for f in files:
    p = pathlib.Path(f)
    if not p.exists():
        continue
    t0 = t = p.read_text(encoding='utf-8')
    n = 0
    for pat, rep in subs:
        t, k = pat.subn(rep, t)
        n += k
    if t != t0:
        p.write_text(t, encoding='utf-8')
        print("  " + f + ": " + str(n) + " reference(s)")
        total += n
print("")
print("set-owner: " + slug + " written into " + str(total) + " reference(s)")
if total == 0:
    print("nothing changed - already pointing there, or the file list needs updating")
PY
rc=$?

cat <<'NOTE'

Two things this does NOT touch, on purpose:

  · the marketplace NAME (tgency-method) - it is what people type in
    /plugin install ...@tgency-method, and renaming it breaks their muscle
    memory for no gain. Change it in .claude-plugin/marketplace.json if you
    really want to.

  · plugins/engineering-methodology/ - the mirror. See the header of this
    script.

Now: scripts/build-site.sh, scripts/repo-checks.sh, then commit.
NOTE
exit $rc
