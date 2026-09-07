# 1 · What it is, and why

## The problem it solves

A team decides to build something. Someone writes a ticket. A developer reads the ticket, fills
the gaps with assumptions, and ships. Three weeks later nobody can answer, without opening the
code, three basic questions:

- **Was this ever decided, or did someone assume it?**
- **Is the code doing what we agreed, or what was convenient?**
- **If we change this, what breaks?**

The ticket cannot answer them. It was a task, not a decision record, and it closed.

The usual patch is more documentation: a Confluence page, a slide deck, a long thread. That fails
for a specific reason worth naming: **the documentation is not connected to anything.** Nothing
breaks when it goes stale, so it goes stale, and then people stop trusting it, and then they stop
reading it.

## The mechanism

Spec-driven development separates three questions that are usually answered at once, and gives
each one a document:

| Question | Document |
|---|---|
| Why are we doing this, and in what direction? | **Concept Note** |
| What must the system do, and how must it behave? | **Spec** |
| What do we build, where, and in what order? | **Implementation Plan** |

Two properties make the set work, and both are easy to lose:

**Each document stands on its own.** Someone handed only the Spec can implement without reading
the Concept Note. Someone handed only the Concept Note understands the problem without the Spec.

**Any stage can be reconstructed from its neighbours.** From the Spec you can derive the decisions
that produced it, or the plan that would satisfy it. That is a real test, not a nice phrase: if
your Spec cannot be turned into a plan without a meeting, it is underspecified.

## Why the order matters

Each document answers a question that the next one is not allowed to reopen.

The Concept Note ends with a handoff section that splits decisions into **settled — do not
relitigate** and **decide in the Spec**. The Spec ends with the same split toward the Plan: what
it must respect, what it has freedom over, what it must resolve.

That is the entire mechanism against the most common failure in this kind of work, which is
relitigating a decision three stages downstream, in a code review, with none of the context that
produced it.

## Why not just write one document

The three exist because they are read by different people at different moments, and merging them
makes each worse.

A Concept Note is **divergent**: it explores alternatives, admits uncertainty, argues. It is
written to be discussed.

A Spec is **normative**: every line is an obligation, and vague words are defects. "The system
must be fast" is not a requirement. "The system shall return search results within 300 ms at p95
for datasets under 10,000 records" is one.

An Implementation Plan is **executable**: exact file paths, exact function signatures, an ordered
branch plan. The test is whether a competent person who has never seen the codebase could ship
from it without asking a question.

Ask one document to be all three and it will be none of them.

## What you get

**Decisions stop evaporating.** Every decision has an ID, an owner, and a note on whether it is
reversible. Six months later "why is it like this?" has an answer that isn't archaeology through
commit messages.

**Ambiguity surfaces before it is expensive.** The cost of discovering an unanswered question is
minutes in a Concept Note, hours in a Spec, and days in code review.

**Tests stop being an interpretation.** Each scenario carries an ID, and the test that covers it
is tagged with that ID. Coverage becomes a fact you can query instead of a feeling.

**An audit becomes possible.** This is the part that did not exist before, and document 3 is about
it: a tool walks every obligation in the Spec, finds the code that satisfies it, and reports the
ones nothing satisfies.

## What it costs

Honestly: between 15,000 and 40,000 words per feature across the three documents, and real
calendar time to write and review them. That is a larger number than this material used to
state, and the correction is deliberate: the old figure predated the traceability layer and did
not survive contact with the templates.

**That is too much for most work, and pretending otherwise is how this gets abandoned.** A bug fix
does not get a Concept Note. A copy change does not get a Spec. Document 4 covers how to decide
what earns the full treatment; the short version is that it is a small fraction of a backlog, and
a team that runs it on everything will quietly stop running it on anything.

## When it does not apply

- **The problem is not understood yet.** Do discovery first. A Spec written over a guess just
  makes the guess look official.
- **The thing is genuinely throwaway.** A prototype meant to be deleted does not need a contract.
- **Nobody will ever verify it.** If no one intends to audit the code against the Spec, you are
  buying the cost without the benefit. Write a good ticket instead and move on.

---

Next: [The three documents](02-the-three-documents.md)
