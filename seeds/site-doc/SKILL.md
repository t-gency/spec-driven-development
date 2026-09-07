---
name: site-doc
description: >
  Write user-facing documentation for a feature that has shipped: how to use it, what to expect,
  what to do when it does not work. Use when the user says "document this feature for users",
  "write the user docs", "this shipped, document it", "write a guide for", or when a feature's
  spec is being marked implemented. Also use to review existing user docs against the shipped
  build. NOT for design intent, which is a Spec; NOT for decisions, which are ADRs; NOT for
  operator procedures, which are runbooks.
---

# Site doc

**Shipped behaviour, for users.** Written when a feature ships, from the build, not from the spec.

## The distinction that matters

A **spec** describes proposed design, for engineers and agents. A **doc** describes what exists,
for users. Different audiences, different lifecycles, different folders.

**When a feature ships:** set the spec's `status: implemented` and write the doc. Never let a spec
quietly become the user documentation, or you get a document describing a design that shipped
differently, reading like documentation, which readers then act on.

## Writing one

**From the shipped build, not from the spec.** Open the thing. What the spec intended and what
shipped are different documents, and only one of them is true.

**Present tense, the user's vocabulary.** They do not know your module names. "Your conversations
are saved automatically", not "the persistence layer writes through to the OS conversations API".

**No design rationale.** Why it works this way is an ADR or a Concept Note. A user reading a doc
wants to do something.

**The limits section prevents support tickets.** Quotas, timings, what happens at the edges, what
is not supported yet. It is the section writers skip and readers need.

## The rule that keeps it true

**A behaviour change is not done until the doc that describes that behaviour changes with it, in
the same PR.** Not a follow-up ticket.

Documentation that lags the code is worse than no documentation: it is confidently wrong, and
readers act on it. If a change needs no doc update, say so in the PR description. *"No docs
needed: internal refactor, no behaviour change"* is a complete answer. Silence is not.

## Process

1. **Use the feature**, on the shipped build
2. **Write what it does**, in the user's words
3. **Find the edges:** empty states, errors, limits, what is unsupported
4. **Table the failure modes** with what to do about each
5. **Flip the spec** to `status: implemented` in the same change

## What makes a bad one

- **Written from the spec**, so it documents what was intended
- **Architecture vocabulary** the user has never seen
- **No limits**, so every edge becomes a support ticket
- **Design rationale** the user did not ask for
- **Updated later**, in a follow-up ticket that never happens
