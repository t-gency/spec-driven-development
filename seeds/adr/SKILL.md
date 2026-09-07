---
name: adr
description: >
  Write an Architecture Decision Record: a cross-cutting technical decision captured with its
  context, the alternatives that were rejected, and the consequences the team accepts. Use when
  the user says "write an ADR", "record this decision", "we decided to use X, document it",
  "why did we choose X", "supersede ADR NNN", or asks to lock in a choice of database, framework,
  protocol, auth model, deployment target, or any decision that will outlive the feature that
  prompted it. Also use to review an existing ADR for missing alternatives or unstated
  consequences. NOT for feature-scoped decisions, which belong in a Concept Note as D-* entries;
  NOT for how-we-write-code rules, which are living conventions; NOT for research that has not
  reached a decision, which is an investigation.
---

# ADR — Architecture Decision Record

A decision that is **cross-cutting and one-time**: which database, which identity provider, which
multi-tenancy model. It outlives every feature that depends on it.

## The rule that gives an ADR its value

**Immutable once accepted.** When the decision changes you write a new ADR that supersedes the
old one. You do not edit the old one.

A decision log you can rewrite is not a decision log: it becomes a description of what you
currently believe, which you already had in the code. The value is in being able to read what was
known, what was considered, and what was accepted, *at the time*.

## Is this an ADR?

Three questions. All three must be yes:

1. **Does it outlive the feature that prompted it?** If it only makes sense inside one feature,
   it is a `D-*` in that feature's Concept Note
2. **Does it constrain future work?** An ADR closes a space of options. If nothing is closed,
   there is no decision to record
3. **Has it actually been decided?** If you are still comparing, that is an investigation. An ADR
   with an open question in it is not accepted yet

## Writing one

**Number it sequentially and never renumber.** `001-`, `002-`. Gaps are fine; a renumber breaks
every citation.

**Title the decision, not the topic.** "Postgres only, no second datastore" beats "Database".
Someone scanning the index should learn the decision without opening the file.

**Alternatives are the highest-signal section.** An ADR with no rejected alternatives reads like
a justification written afterwards. For each one, say what it would have bought and why that was
not enough. If you genuinely considered nothing else, say so and say why.

**Consequences include the ones you do not like.** "We accept N+1 queries on the audit view until
we add a projection" is what makes an ADR trustworthy. An ADR listing only benefits is marketing.

**Ground it.** Cite the file, the benchmark, the incident, the constraint. An ADR whose context is
all assertion cannot be re-evaluated later.

## Status

```
proposed · accepted · superseded
```

`superseded` carries a forward link to the ADR that replaced it. **Keep the file.** The point of
an immutable log is that the superseded entry is still readable.

## Process

1. **Check for an existing one.** Read the index. If an ADR already covers this, you are
   superseding it, not writing a new one
2. **Ground the context** in the codebase and in whatever investigation preceded it. Do not
   invent constraints
3. **Ask for what you cannot ground.** Who decided, when, and what was rejected are often not in
   the repo
4. **Write it** from `TEMPLATE.md`
5. **Update the index** in the same change
6. **If it supersedes another**, edit only the old one's status line and forward link. Nothing
   else

## What makes a bad ADR

- **Only the chosen option**, no alternatives
- **Only benefits**, no accepted costs
- **A topic as the title**, so the index says nothing
- **Edited in place** when the decision changed, erasing the original reasoning
- **Feature-scoped**, so it will be irrelevant next quarter and clutter the index forever
