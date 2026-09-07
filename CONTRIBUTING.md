# Contributing

The methodology is applied to itself. That is not a slogan here — it is what makes several of
the rules below non-negotiable, and it is why the build fails on things that look cosmetic.

---

## Before you open a PR

```bash
chmod +x scripts/*.sh plugins/engineering-methodology/scripts/*.sh

plugins/engineering-methodology/scripts/closed-set-consistency.sh
plugins/engineering-methodology/scripts/closed-set-consistency.test.sh
scripts/repo-checks.sh
```

All three run in CI. Run them locally first — `repo-checks.sh` in particular fails on things
that are trivial to fix before review and awkward to fix after.

**Use bash.** Not PowerShell. Every gate in this repository uses process substitution and
`comm`, and `LC_ALL=C` is set inside the scripts because a non-English locale makes `comm`
return garbage *without reporting an error*.

---

## The four rules that will fail your build

### 1 · Closed sets move together

The meta-acceptance-criteria (`AC-50`…`AC-55`) and the Definition-of-Done gates
(`T-N.D1`…`T-N.D20`) are **closed sets enumerated in several places** — the Spec template, the
Plan template, `spec-conformance`'s gate table and verdict-source list, the visualizer's
meta-gates card, and the two guidance AC→gate maps.

When a set gains a member, **every enumeration site has to move in the same commit.**
`closed-set-consistency.sh` is what fails the build when one does not.

This gate exists because adding `AC-55` / `T-N.D20` missed or half-did that propagation in three
consecutive review rounds — the third time inside the commit fixing the second. *A
half-propagated closed set is worse than an un-propagated one*, because a skill that declares a
member its own sibling reference does not know about reads as a silent pass.

An intentional subset opts out with an inline `closed-set:subset` marker. Declared-none-visible:
**an empty answer is legal, a silent one is not.**

### 2 · No third party's internal material

`repo-checks.sh` fails on a list of identifiers: a private SSDLC policy and its siblings, named
security vendors, internal team names, private org and repo names.

This is not tidiness. The security skills previously encoded another organization's controlled
policy — its control numbering, remediation cadences, approval workflow, MFA hardware and secrets
vendor — and a find-and-replace pass to remove the attribution left visible scars (`dependency
reSec teamry`). **The gate is anchored** (`\bGIST\b`, not the bare word) precisely because the
unanchored version matched inside *registry* and produced a page of false findings.

Every security control must be anchored to a standard the reader can download. Every threshold
that is *not* from a standard is labelled as a default the adopter should replace.

### 3 · No compliance claims in a skill description

A `description` is the routing table **and** the promise. `repo-checks.sh` fails any skill whose
description offers SOC 2 or ISO 27001 evidence, audit evidence, or a compliance certification.

`production-readiness-gate` is an **engineering assessment**. A `GO` means *the controls we could
check are implemented and evidenced in this repository at this commit*. It is not an approval
authority, and it does not replace a penetration test, an architecture review, a compliance
audit, or the accountable owner's sign-off. Say that; do not imply otherwise anywhere.

### 4 · `internal/` never gets committed

It is gitignored, and `repo-checks.sh` fails if any path under it is tracked. Do not
`git add -f internal/`. It holds a worked example that is not ours to publish.

---

## Changing the documents

`docs/01`–`docs/09` are the reference. `docs/*.html` is the same material as a site.

**The markdown is the source; the HTML is downstream.** Every HTML page says so in its footer:
*if this page and a markdown file disagree, the markdown is right and this page is stale.* So
when you change a document, change the page it feeds in the same PR — the docs-change-in-the-same-PR
rule this repository preaches in [document 8](docs/08-the-docs-system.md) applies to the
repository itself.

`repo-checks.sh` verifies every relative link resolves, which is what catches the half of that
rule a human forgets.

### Style, taken from document 8

- **English only** in committed files. Conversation in any language is fine.
- **State what is true now**, not what changed. Changelogs live in git.
- **Link, do not copy.** One fact, one home — a restatement is a future contradiction.
- **Delete confidently.** A section describing something that no longer exists is a bug.
- **Do not invent counts.** A number you could have counted from the repo belongs in a generator.

---

## Changing the plugin

`plugins/engineering-methodology/` is a **mirror** of a private engineering repository. Read
[`UPSTREAM.md`](plugins/engineering-methodology/UPSTREAM.md) first.

- **Do not edit the mirror directly.** Change it upstream and re-sync, or — if this fork is now
  your source of truth — delete `UPSTREAM.md` and remove the fingerprint step from CI, and say so
  in the PR.
- A re-sync updates the tree **and** `UPSTREAM.md` **in the same commit**. Splitting them means
  `main` is briefly lying about which version it holds.
- Structural changes get a row in
  [`DESIGN_RATIONALE.md`](plugins/engineering-methodology/DESIGN_RATIONALE.md) §5 with an `MD-NN`
  id, a rationale, the alternatives you rejected and why, and a reversibility flag. That log is
  what lets someone defend a methodology choice in a code review two years from now — cite the
  `MD-NN`, not an opinion.
- Open questions go in §6 as `EVO-NN` **with the condition that would promote them**. "We should
  look at this someday" is not an open question; "after three features have shipped through this,
  decide whether a postmortem stage is warranted" is.

---

## Reviewing

Two questions, per [document 8](docs/08-the-docs-system.md):

1. Does this PR change behaviour that a document describes?
2. Is that document in the diff?

CI answers the mechanical half. **The judgement half is human, and it is the one that matters.**
Treat missing documentation the same as a missing test.

And the rule that governs every review here, borrowed from the audit the methodology performs on
code:

> **A gate failure is evidence of a gap. A gate pass is not evidence of an implementation.**

Green CI means the checks passed. It does not mean the change is right.

---

## Reporting a problem

Open an issue. If it is a defect in the methodology rather than in this repository — a gate that
reports a conforming document as broken, a template that violates its own rule — say which
document and which ID, because that is what makes it reproducible.

**Do not open a public issue for a security vulnerability.** Use GitHub's private vulnerability
reporting on this repository.
