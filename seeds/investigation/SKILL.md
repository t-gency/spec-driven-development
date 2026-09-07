---
name: investigation
description: >
  Write an investigation document: pre-spec research, a codebase audit, a post-mortem, a market
  or vendor analysis. Use when the user says "investigate X", "research whether we can", "audit
  the codebase for", "write this up as an investigation", "post-mortem", "compare these options",
  or asks a question whose answer needs evidence gathering before anyone can decide. Also use to
  review an existing investigation for unsupported claims. NOT for decisions already made, which
  are ADRs; NOT for design intent, which is a Spec; NOT for how-we-write-code rules, which are
  living conventions.
---

# Investigation

Research that informs a decision but is not itself a decision. **A dated snapshot, never
retro-edited.**

## Why never edited

An investigation is evidence of what was known on a date. Updating it destroys exactly the thing
that made it worth keeping: if it turns out to be wrong, you write a new one and link back.

That is the difference from a convention, which is living and gets fixed in place.

## Writing one

**Name it `YYYY-MM-DD-what-was-investigated.md`.** The date is part of the meaning, not metadata.

**Separate verified from inferred, explicitly.** This is the discipline that makes an
investigation trustworthy. Anything you could not confirm gets marked `[UNVERIFIED — reason]`,
and the reason has to be real: *"the endpoint is not in the published spec"* is a reason;
*"didn't check"* is not, and an unverified claim with a bad reason should be treated as if the
marker were not there.

**Cite so it can be re-run.** File and line, the API response, the measurement, the document, the
person asked. An investigation nobody can reproduce is an opinion with formatting.

**Say what it does not tell you.** What you did not look at, what the sample could not cover. Six
months later this is usually the most useful section, because it is what stops someone reading
more into the finding than it supports.

**Do not decide.** If a decision falls out, it becomes an ADR and this document is its evidence.
Ending an investigation with a recommendation is fine; ending it with a decision is a category
error, and it means the decision has no ADR.

## Process

1. **Gather first.** Codebase, then primary sources, then people. Do not start writing to a
   conclusion
2. **Mark every claim** you could not ground
3. **Write it** from `TEMPLATE.md`
4. **List the open questions** with owners
5. **Say what it feeds:** the spec, the decision, the work

## What makes a bad one

- **Conclusion first**, evidence assembled to fit
- **Verified and inferred mixed**, so a reader cannot tell which is which
- **No limits section**, so it gets over-applied
- **Retro-edited** when reality moved, destroying the snapshot
- **Undated**, which makes it impossible to know if it is still true
