# 2 · The three documents

One set per **feature**. Not per epic, not per release, not per ticket.

| | Answers | Voice | Length |
|---|---|---|---|
| **Concept Note** | Why, and in what direction | Divergent, exploratory: a memo | 2,500–6,000 words |
| **Spec** | What it must do, how it must behave | Normative: every line is an obligation | 4,000–10,000 words |
| **Implementation Plan** | What to build, where, in what order | Executable: an agent could run it | 8,000–25,000 words, by branch arc |

**The bands count the delivered document, scaffolding included.** That matters, because the
scaffolding is not small: the Spec template carries ~3,900 words of normative structure before
a single placeholder is filled, and §11.5's meta-acceptance-criteria alone contribute ~1,100
words that have to survive into the delivered document. A conforming Spec cannot be shorter
than its own template. The earlier 1,500–3,500 band predated the traceability layer and was
arithmetically impossible to meet — worth saying out loud, because a limit the templates
violate teaches people to ignore limits.

The Plan does not get one number, because its size is set by the **branch arc** it declares in
§7.0 — the nine per-branch subsections and the closing `T-N.D1`–`T-N.D20` block are replicated
per branch:

| Arc | Band |
|---|---|
| `refactor-1`, `single-branch` | 8,000–12,000 words |
| `two-branch-backend-ui` | 10,000–16,000 words |
| `three-branch-scaffold-core-rollout` | 12,000–19,000 words |
| `five-branch-default`, `migration-5` | 15,000–25,000 words |

The upper bounds still carry a rule: **if a document runs past its band, split the feature** —
except for the Plan, where you check the arc first. An oversized Plan is more often a
five-branch arc on a two-branch feature than a feature that needs splitting.

---

## Concept Note

The document you write when the direction is not settled. It is allowed to be uncertain; that is
what it is for.

**What it carries.** The problem and why now. Goals and non-goals. The proposed direction and the
alternatives that were considered and rejected. Numbered decisions. Risks. Open questions with an
owner. And the section most people skip, which is the one that matters most downstream: where the
evidence came from.

**Decisions get IDs and a reversibility flag.** `D-01`, `D-02`, each marked Easy / Hard / One-way.
That flag changes how much argument a decision deserves: a one-way door is worth a week; an easily
reversible choice is worth ten minutes and a note.

**Non-goals are load-bearing.** They are quoted verbatim into the handoff, so the Spec cannot
quietly expand scope without someone noticing the contradiction.

**The handoff section** splits everything into three: *settled, do not relitigate*; *decide in the
Spec*; *must remain non-goals*. When an agent drafts the Spec from this, that section does more
work than the rest of the document.

## Spec

The normative one. Every line is an obligation someone can be held to.

**Functional requirements** are one obligation per line, each with an ID, written in a constrained
syntax so they cannot be vague:

```
FR-003 — When the client disconnects mid-turn, the system shall persist the partial
         response and mark the turn as recoverable.
FR-004 — While a turn is recoverable, the system shall return it on the next
         conversation fetch with its recovery state.
```

Not "the system should handle disconnections gracefully". That sentence cannot be tested and
cannot be violated, which means it cannot be a requirement.

**Non-functional requirements are quantified or they are not requirements.** "Fast", "secure",
"robust" fail the test. A number and a percentile pass it.

**Technical constraints** are separate from requirements. A requirement says what the system does;
a constraint restricts *which solutions are admissible* — the stack, an architectural rule, a
compliance clause, a security control. Mixing them is the most common Spec defect: it looks like
you have decided the behaviour when you have actually decided the implementation.

**Scenarios** are Given/When/Then, each with an ID, each citing the requirements it exercises. Each
one also declares its **variants** — boundary, failure, concurrency — or explicitly says it has
none. That declaration is what stops a happy-path-only Spec from looking complete.

**Acceptance criteria** close the loop, including a fixed set of meta-criteria that assert the
document is internally consistent: every scenario has a test, every quantified NFR has a
measurement, every constraint has a check.

**A Spec with open questions at the requirement level cannot be approved.** Either resolve them,
or lift the ambiguity into a more general requirement with an explicit fallback: *if unspecified,
the system shall …*. Shipping a Spec that says "we don't know what happens when X" just moves the
decision to whoever writes the code, at the worst possible moment.

## Implementation Plan

The executable one. The test: hand it to a competent person who has never seen the codebase, give
them five days, and they ship without asking a question.

**Exact paths and signatures.** Not "the auth module". `src/auth/session.ts`, the function name,
the types.

**A branch plan sized to the feature.** Not every feature deserves five pull requests. The plan
declares which shape it uses — one branch for a refactor, two for backend plus UI, five for a
cross-service producer/consumer pair, five for a data migration — and says why. Small features
shipping with five PRs of overhead is a real failure mode, and naming the shape is what prevents
it.

**A traceability matrix** mapping every Spec scenario to the test that covers it and at what level
— unit, integration, contract, end-to-end.

**A Definition of Done per branch**, written as discrete tasks rather than a single "make sure
things are good" line. These are gates, not a checklist: several are mechanically checkable, and
at least one runs at merge.

**Observability bound to requirements.** Every quantified NFR names the signal that proves it in
production. A performance requirement with no metric behind it is a hope.

---

## What holds the set together

Two rules, and they are the difference between a document set and three files.

**Cite, don't paraphrase.** When the Spec inherits a decision, it writes `D-01`, not a re-worded
version of the decision. Paraphrase is how two documents start disagreeing without anyone
noticing.

**Empty is legal; silent is not.** Any section can be empty, but it must say so and say why:
*Security constraints: none — see Concept §5.2*. An undeclared gap is a defect; a declared one is
a decision. This single rule does more for quality than most of the structure, because it turns
"we forgot" and "we decided not to" into visibly different things.

---

Next: [Traceability](03-traceability.md)
