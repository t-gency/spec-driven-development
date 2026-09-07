---
name: runbook
description: >
  Write an operator runbook: the procedure someone follows to deploy, restore, rotate, migrate,
  recover or otherwise operate a running system. Use when the user says "write a runbook",
  "document this procedure", "how do we recover from", "what do we do when this alert fires",
  "document the deploy steps", or describes an operation someone else will have to repeat. Also
  use to review an existing runbook for missing verification steps or a missing rollback. NOT for
  how the system is built, which is a spec or the README; NOT for why it is built that way, which
  is an ADR; NOT for user-facing instructions, which are site docs.
---

# Runbook

A procedure someone follows under pressure, often at 3am, often not the person who wrote it.

## The two things that make it usable

**Every step says how to tell it worked.** A step with no verification is where a runbook fails:
the operator does not know whether to continue or roll back, and the whole document stops being
trustworthy from that point down.

**The rollback names the point of no return, before that step.** "You can still abort up to step
4; after step 5 the migration is one-way." Putting that after the step is worse than not having
it.

## Writing one

**Commands, not descriptions.** Not "restart the service": the command, copy-pasteable, with the
real flags.

**State the blast radius up front.** What is degraded while this runs, and who should be told
before it starts.

**Escalation is a step, not a fallback.** Who to wake and at what point. A runbook ending in "if
this fails, ask someone" has not finished.

**Carry a verification date.** *Last verified YYYY-MM-DD by name.* A runbook nobody has run in six
months is a guess, and the date is what makes that visible instead of assumed.

## Process

1. **Run it yourself**, or watch someone run it, before writing. A runbook written from memory has
   the gaps of memory
2. **Write each step with its check**
3. **Write the rollback**, and find the point of no return
4. **Collect the failure modes** that have actually happened, not the imagined ones
5. **Date it** with who verified it

## What makes a bad one

- **Steps with no way to confirm** they worked
- **A rollback that does not say where it stops being possible**
- **Prose instead of commands**
- **Never re-verified**, so it describes a system that has since changed
- **Ends without escalation**
