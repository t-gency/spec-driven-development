# 4 · Adopting it on a real board

The methodology says nothing about tickets. That is deliberate, not an oversight: it governs the
design documents and stops there. Which means every team adopting it has to answer four questions
itself, and getting them wrong is how adoption fails.

These are the four, with the answers t-gency Apps landed on as a worked example.

## 1 · What is the unit?

The methodology works one **feature** at a time. A board works in tickets, which are smaller. You
need a stable name that means the same thing on both sides.

The team that built this put it in the ticket title:

```
Surface | Feature → Name

iOS | Attachments → Capture from camera
Cross | Conversations → Recover the turn when the client disconnects
```

The middle segment is the feature, and it is the folder name for the documents. 53 tickets
resolved to 18 features. Without something like this, "which tickets belong to this Spec?" has no
mechanical answer and the connection is maintained by memory.

### How many tickets per feature

**One per independently deliverable user story.** Not one per feature, and not one per functional
requirement.

This is [spec-kit's](https://github.com/github/spec-kit) rule and it is the right one: user
stories are prioritized `P1` `P2` `P3`, each independently testable, and **`P1` alone has to be
viable** — if you build only that story you still have something worth shipping. That constraint
is what prevents a monolithic all-or-nothing spec.

Two mistakes to avoid, and they pull in opposite directions:

- **Counting FRs.** A requirement is an obligation inside the Spec, not a unit of work. One story
  usually spans several FRs, and one FR can serve several stories. Slicing by FR produces tickets
  nobody can ship alone
- **One ticket per feature.** It hides the priority order inside the ticket, so nothing can be
  cut. A feature with three stories has three tickets, and you can drop the third

**The ticket and the PR are different axes**, and conflating them is the common error:

| | Slices by | Rule |
|---|---|---|
| **Ticket** | User value. Vertical | Independently deliverable, prioritized, `P1` viable alone |
| **PR** | Technical sequencing. Horizontal | The Plan's branch arc: scaffolding, core, edge cases, rollout |

One ticket can take several stacked PRs. Several tickets never share a PR.

## 2 · How does a ticket point at its documents?

Two fields in the body. This is the entire bridge:

```
**Docs:** `specs/002-conversations/`
**Satisfies:** FR-003, S-04, AC-12
```

`Satisfies` is what lets the audit go from a requirement back to the ticket that claimed it, and
from a ticket to the requirement it was supposed to close. Bugs carry `Violates` instead: which
IDs the current behaviour contradicts, which is the same thing the audit reports as `DIVERGENT`.

If no ID sanctions the behaviour, the value is `unspecified` — and that is a gap in the Spec, not
just a bug.

## 3 · Where do the tasks live?

The Implementation Plan contains a task checklist meant for an agent to execute. It is tempting to
push those onto the board as tickets. **Don't.**

Two task systems drift within a sprint. Keep the split explicit:

- **The ticket** is what a person picks up: it has an owner, a label, a board column
- **The plan's tasks** are the breakdown for whoever executes, and stay in the document

## 4 · What earns the full treatment?

The hardest question, and the methodology gives no answer: it has no guidance on when *not* to use
it. That gap has to be filled locally or the team will either run it on everything, and stop, or
on nothing.

**Ask the question of the feature, never of the ticket.** That one move is what makes the rest
work, and it is the correction we had to make: an earlier version derived the answer from what was
blocking each *ticket*, which quietly created a state where a ticket sat on the board waiting for a
document nobody had started.

Three paths, and the template decides which:

| Path | What runs | Where the issues come from |
|---|---|---|
| **Spec** | Concept Note, then Spec. The Plan only if it enters the release | Out of the approved Spec: one per user story, `P1` `P2` `P3` |
| **Direct** | **Nothing** | Straight onto the board: a defect against specified behaviour, or internal work with no user surface |
| **Platform request** | **Nothing from us** | It needs a contract from the platform team, not a Spec. It carries a `blocked:` label and does not count toward the release forecast |

**There is no fourth case where a ticket waits on a document that does not exist.** Asking the
question of the feature is what prevents it. What can still block an issue *once it exists* is a
missing mock-up or an unresolved platform dependency — one label each — and an issue carrying any
`blocked:` label does not enter refinement.

> **Where we diverge from [spec-kit](https://github.com/github/spec-kit).** It ships a
> `tasks-to-issues` command: the artifacts come first and the issues are generated last, which is
> the same direction as this. It goes one step further and builds them from the Plan's *tasks*.
> **We stop at the user story.** The tasks belong to an agent and the story belongs to a person,
> and putting the tasks on the board gives you two task systems that drift within a sprint.

Result: the full three-document pipeline on **2 or 3 features out of 18**. The rest get a
well-written ticket.

That ratio is the point. At 15,000 to 40,000 words per feature, 18 features is a quarter of
writing and no shipping. A team that does not decide this in advance decides it by exhaustion.

### The honest cost

**Between 15,000 and 40,000 words per feature** across the three documents, plus real calendar
time to write and review them. That is too much for most work, and pretending otherwise is how this
gets abandoned: a bug fix does not get a Concept Note, a copy change does not get a Spec.

**A team that runs this on everything will quietly stop running it on anything.**

It also does not apply when the problem is not understood yet — do discovery first, because a Spec
written over a guess just makes the guess look official — or when the thing is genuinely
throwaway, or when nobody will ever run the audit. Without the audit you are buying the cost
without the benefit; write a good ticket instead.

> A spec nobody verifies decays into fiction. A spec that gets audited is a contract. The only
> thing that changed is that auditing got cheap.

## The gates nobody hands you

Two more the methodology deliberately leaves open.

**What "approved" means.** Every template ships as `Draft` and nothing promotes it. The
methodology gives the criteria for *not* approvable — unresolved questions at requirement level,
empty cells in the coverage matrix, blocking findings from the review — but the act of approving
is yours to define. t-gency Apps requires four signatures, recorded in the document's own change
log: Product, the surface's tech lead, testing, design.

**The same feature in two codebases.** The methodology assumes one feature, one repo. A product
with several clients against one platform breaks that assumption immediately: the same feature,
two apps, and taken literally that means two Specs of the same design diverging from day one.
t-gency Apps keeps the documents in each app's repo and has the headers point across at each
other, so a change on one side makes the stale side visible. It works, but it runs on human
discipline: nothing mechanical enforces it.

## Order of adoption

1. **Pick the naming bridge first.** Titles and folder names, before writing any document. It is
   cheap now and expensive to retrofit across a live board.
2. **Add the two body fields to your ticket templates**, even empty. A ticket created without them
   is a ticket someone has to go back and edit.
3. **Run the full pipeline on one feature.** The most expensive one you have, not the easiest. An
   easy feature will not surface the problems.
4. **Only then decide the tiering.** After one real pass, the cost is a number instead of a guess.
5. **Run the audit before the second feature.** If nobody ever runs it, stop here: the rest is
   documentation theatre and a good ticket is cheaper.

---

Next: [Plugins and skills](05-plugins-and-skills.md)
