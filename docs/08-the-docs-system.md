# 8 · The documentation system

The three documents are not the whole story. A feature Spec answers "what should this do"; it does
not answer "why is the whole system built this way", "what did we learn before we specified it",
or "how does an operator restart it at 3am".

The platform repo has a full taxonomy for that, and it is the largest thing our methodology was
missing. This is what it looks like and what to take from it.

## One folder per lifecycle, not per topic

The organising idea is not subject matter. **It is how the document changes over time**, and that
is what decides where it goes:

| Path | What it is | Lifecycle |
|---|---|---|
| `README.md` | The front door: what this is, how to run it | Updated with the behaviour it describes |
| `specs/NNN-slug/**` | The per-feature working set | Lives with the feature branch |
| `docs/specs/**` | **Design intent**, for engineers and agents | Carries a status banner; kept as the record |
| `docs/site/**` | **Shipped behaviour**, for users | Written when a feature ships |
| `docs/adrs/**` | One-time architectural decisions | **Immutable once accepted**: superseded, never edited |
| `docs/investigation/**` | Pre-spec research, audits, post-mortems | Dated. A snapshot, never retro-edited |
| `docs/conventions/**` | How we write code here | Living: fixed in the PR that changes the pattern |
| `docs/runbooks/**` | Operator playbooks | Updated with the operation they describe |

Sorting by lifecycle rather than by topic is what stops the same fact from living in two places
and disagreeing. A decision is immutable, a convention is living, research is a dated snapshot:
three different rules, so three different folders.

## Specs are not docs

The distinction the whole team runs on, and the one most often collapsed:

| | Spec | Doc |
|---|---|---|
| Describes | Proposed or in-progress design | Shipped, working behaviour |
| Audience | Engineers and coding agents | Users |
| Status | Always carries a status banner | Not applicable |

**Never let a spec quietly become the user documentation.** When a feature ships, its spec gets
`status: implemented` and a durable doc is written for users. The spec stays as the record of what
was intended; the doc says what exists.

Collapsing the two is how a document ends up describing a design that shipped differently and
nobody notices, because it reads like documentation.

## The status vocabulary

Every spec opens with one:

```
draft · proposed · accepted · implemented · superseded
```

**This closes a hole in the methodology.** As shipped, every template says `Status: Draft` and
nothing ever promotes it out, so `Draft` alone means nothing. Five states with a defined
transition is what makes a status banner worth reading, and `superseded` is what lets a document
be retired without being deleted.

## ADRs are not Concept Note decisions

Both record decisions, and they are not the same thing.

A `D-*` in a Concept Note is **feature-scoped**: it decides something inside one feature and lives
with it. An ADR is **cross-cutting and one-time**: which database, which identity provider, which
multi-tenancy model. It outlives every feature that depends on it.

The rule that gives ADRs their value: **immutable once accepted.** You do not edit an ADR when the
decision changes; you write a new one that supersedes it, and the old one keeps its context and
its consequences. A decision log you can rewrite is not a decision log.

The platform repo has 26 of them, numbered, each carrying context, alternatives and consequences. **We
have none**, which means every cross-cutting decision our client surfaces have made lives in someone's
memory or in a thread.

## `investigation/` is where research goes before it earns a spec

253 files. Pre-spec research, market analysis, audits, post-mortems. **Dated, and never
retro-edited**, because a snapshot that gets updated stops being evidence of what was known at the
time.

This is the folder our own work has been missing a home for: the analysis of the OS conversations
API, the design-audit findings, the migration study. All of it is investigation, none of it
is a spec, and putting it in a spec folder would give it an authority it has not earned yet.

## The rule that makes the whole thing hold

> **A behaviour change is not done until the docs that describe that behaviour change with it, in
> the same PR.**

Not a follow-up ticket. Not someone else's job.

The reasoning is worth quoting because it is the argument against "we'll document it later":
documentation that lags behind the code is **worse than no documentation, because it is
confidently wrong, and readers act on it.** The audit that produced that convention found a README
that had gone a hundred commits without a substantive update and was telling new developers to
deploy to a retired environment and run a seed script that no longer existed.

It is enforced with a lookup table: *if your PR changes X, update Y in the same PR.* Change the
schema, regenerate the README. Change an API contract, regenerate the OpenAPI. Change the
methodology, regenerate every rendering of it.

And the escape hatch is the same *declared-none-visible* rule the methodology uses everywhere:

> If nothing in that table applies, say so in the PR description. "No docs needed: internal
> refactor, no behaviour change" is a complete and acceptable answer. **Silence is not.**

## Generated versus hand-written

Anything countable from the repo is generated, not maintained:

- Generated blocks sit between markers and are rebuilt from the real source
- **Never edit inside the markers.** A check in CI fails on a stale block
- The generator is **fail-closed**: add a service or a workspace without a description and it
  aborts, naming what you have to document

That last one is the good idea. **A new component cannot reach `main` while remaining invisible in
the README.** Not a reminder, not a review comment: the build stops.

The rule of thumb generalises past READMEs: *if you find yourself hand-maintaining a list that
could be counted from the repo, generate it instead.* Hand-maintained copies of machine-readable
truth always drift; the only question is how long it takes and who gets misled meanwhile.

## Writing rules worth stealing verbatim

- **English only.** Conversation in any language is fine; the committed file is not
- **State what is true now**, not what changed. "The gateway routes across the catalog", not "we
  recently migrated the gateway". Changelogs live in git
- **Link, do not copy.** One fact, one home. A restatement is a future contradiction
- **Delete confidently.** A section describing something that no longer exists is a bug. Remove
  it; git remembers
- **Do not invent counts.** A number you could have counted from the repo belongs in a generator

## Review

> Reviewers should treat missing documentation the same as a missing test.

Two questions per review: does this PR change behaviour that a doc describes, and is that doc in
the diff? CI can answer the mechanical half. The judgement half is human, and it is the one that
matters.

## Seeds for the other four types

[`seeds/`](../seeds/) has a starting point for each: a **seed skill** that teaches an agent to write
that document type well, a **template**, and a **README for the destination folder** so whoever
opens `docs/adrs/` learns the rules without reading this.

```
seeds/adr/            seeds/investigation/
seeds/runbook/        seeds/site-doc/
```

They are starting points, not finished products. Install one, use it for a month, and edit it to
match what your team actually does. The `description` in the front matter is the routing table:
that is the field to get right when adapting, and the one to suspect when a skill does not fire.

## What we should adopt, in order

1. **The status vocabulary.** Five states, one banner per spec. Cheapest thing here and it closes
   a real hole in the methodology
2. **`docs/investigation/`.** We already have the content with nowhere to put it
3. **The docs-change-in-the-same-PR rule**, with our own lookup table. It needs no tooling to
   start: it is a review habit, and it is what keeps everything else true
4. **ADRs.** Ours would start at three or four: the platform dependency, the shared design system,
   two chat components in parallel
5. **Generated blocks.** Last, and only where we are already hand-maintaining a list that drifts

The first three cost nothing but agreement. The last two cost engineering time, and neither is
worth doing before the first three are habits.

---

Next: [Talk outline](09-talk-outline.md)
