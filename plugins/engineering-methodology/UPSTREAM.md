# Upstream

This directory is a **mirror**. The plugin is developed in a private engineering repository and
copied here so that this repo is installable on its own.

| | |
|---|---|
| **Upstream repository** | `<org>/<engineering-repo>` — private |
| **Upstream path** | `procedures/engineering-methodology` |
| **Mirrored at commit** | `TODO — fill in the upstream SHA` |
| **Mirrored on** | `2026-09-07` |
| **Plugin version** | `0.15.0` |
| **Tree fingerprint** | `544bfa4e07af1ae6` |

---

## Why a mirror at all

A single source of truth beats a mirror, and we are not pretending otherwise. But the
alternative here was worse: an install path that only resolves for people with access to a
private organization, failing with a 404 that does not say "permissions". A colleague who
downloads this repository has to be able to install what it describes.

So the compromise is a mirror **that says what it is**:

- It records the upstream commit, so a document written under this copy can cite a real version.
- It records a fingerprint of the tree, so **CI fails when the mirror changes without the record
  changing**. Drift becomes a red build rather than a discovery six months later.

That second point is the whole reason this file exists. A copy nobody can date is the failure
mode; a copy that breaks the build when it drifts is a manageable one.

## If you are adopting this

**Delete this file.** You have no upstream — your fork is the source of truth, and a mirror
record pointing at a repository you cannot read is worse than nothing. Remove the
`mirror-fingerprint` step from CI at the same time.

## Re-syncing the mirror

```bash
# 1 · copy the upstream tree over this directory
rsync -a --delete \
  <path-to-upstream>/procedures/engineering-methodology/ \
  plugins/engineering-methodology/ \
  --exclude UPSTREAM.md

# 2 · record what you just mirrored
scripts/mirror-fingerprint.sh --write

# 3 · the gates the methodology applies to itself must still pass
plugins/engineering-methodology/scripts/closed-set-consistency.sh
plugins/engineering-methodology/scripts/closed-set-consistency.test.sh
```

Then commit the tree and this file **in the same commit**. A mirror update that does not update
its own record is exactly the drift the fingerprint exists to catch, and splitting it across two
commits means `main` is briefly lying.

## What is not mirrored

The upstream marketplace carries sibling plugins — a variant for legacy migrations, an autonomous
bug pipeline, issue triage, multi-agent orchestration, an evaluator for LLM-facing behaviour.
**None of them is published here.** This repo publishes one plugin, on purpose: it is the one the
documentation describes, and a marketplace advertising plugins nobody outside the org can install
is a broken promise, not a feature list.

## Citing a version in a document

Cite a commit, never a branch:

```markdown
> **Methodology:** engineering-methodology v0.15.0 ·
> [`spec-driven-development@<sha>`](https://github.com/acme-test/sdd-test/tree/<sha>/plugins/engineering-methodology)
```

A link to `main` will misrepresent, three weeks from now, which rules that Spec was approved
under. That is the entire point of the SHA.
