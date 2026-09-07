# 6 · The delivery loop

Documents 1 to 4 cover what the documents are. This is how a feature actually moves from idea to
merged code, and it is the part most teams improvise.

It comes from the platform team's practice, which is further along than ours: they run it today.

## Two principles decide everything else

**WHAT before HOW.** A feature's value is decided in the Concept Note and the Spec, not in the
code. That is where the investment goes.

**Prototype first, then completeness.** Get a version that *works* and show it to Product. Only
after they confirm the direction do you give the feature completeness: security, performance, the
rest of the scope.

The second principle is the one that changes the shape of the work, and it is the biggest thing
missing from our own guide.

## The two phases

| | Phase 1 · Prototype | Phase 2 · Completeness |
|---|---|---|
| **Goal** | A working prototype Product can react to | Production-grade, complete feature |
| **Focus** | Functional behaviour: the `FR-*` and scenarios | Security, performance, completeness |
| **`NFR-*` / `TC-*`** | **Captured** in the Spec, **scheduled** | **Implemented** and verified |
| **Trigger** | Ready when localhost proves the happy path | Starts only after Product sign-off |

The subtlety is worth stating twice: **the non-functional requirements are written into the Spec
in Phase 1, they are just not built yet.** They are not discovered later and they are not
optional. Deferring the work is not the same as deferring the decision, and conflating the two is
how "we'll add security later" happens.

The bar for Phase 1 is that the happy path works in a browser. Nothing more.

## Defining the WHAT is a team sport

Product owns the WHY and the scope. Everyone else shapes it, and each role lands in a different
part of the Spec:

| Role | Shapes | Lands as |
|---|---|---|
| **Product** | The WHY and the scope | `D-*`, scope |
| **Engineering** | Feasibility and how it gets built | `TC-*`, the Plan |
| **UX** | The experience | `FR-*`, scenarios, accessibility |
| **Security** | Threats, data, posture | `NFR-*`, `TC-*` |
| **Test / QA** | What automated tests will prove | `S-*` variants, `AC-*` |

Iterate until aligned, not one-shot. The output is a Concept Note and Spec that already carry the
functional, experience, security and test obligations, instead of discovering three of the four in
review.

**This is stronger than an approval gate.** Four signatures at the end catch problems late; four
authors from the start prevent them.

## The ten steps

Every step is a plain-language instruction to a coding agent. You do not type skill names.

| | Step | What happens |
|---|---|---|
| 1 | **Issue** | One per independently deliverable user story, on the board |
| 2 | **Concept Note** | The WHY, via guided Q&A plus codebase research |
| 3 | **Spec** | The WHAT: `FR-*` in EARS, every scenario with its variants |
| 4 | **Plan** | Exact paths, a stacked-branch arc behind a flag, the traceability matrix |
| 5 | **Implement** | Autonomous. Commit locally; **do not push** |
| 6 | **Verify** | Bring it up on localhost. Show Product the prototype |
| 7 | **Completeness** | After sign-off: the deferred `NFR-*` and `TC-*`, remaining variants |
| 8 | **Pre-PR gate** | Four checks, all before anything goes up |
| 9 | **Open PRs** | Stacked, each linked to its issue, the last one `Closes #NNN` |
| 10 | **Watch to merge** | A background loop keeps the stack green until it is ready |

Steps 1 to 6 are Phase 1. Steps 7 to 10 are Phase 2.

### The prompts that drive it

Worth copying nearly verbatim, because the constraints in them are load-bearing:

**Step 2, Concept Note.** *"Draft a concept note for {feature}. Research the codebase first, and
ask me whatever you can't ground."* The second clause is what stops invention.

**Step 3, Spec.** *"Turn this concept note into a spec. Keep the focus on the WHAT, and enumerate
the variants for every scenario."* Variants are where happy-path-only Specs get caught.

**Step 4, Plan.** *"Generate an implementation plan from the spec. Use real file paths, stacked
branches per the arc behind a flag, and a scenario → test matrix."*

**Step 5, Implement.** *"Implement the whole plan end to end. Commit locally as you go, but do NOT
push and do NOT open the PR: stop when it's ready to verify on localhost."* Nothing is pushed, so
the session can run unattended.

**Step 6, Verify.** *"Make sure every service I need to validate {feature} on localhost is
running: start whatever is down. Then walk me through validating the change, and give me example
API calls where that is the clearest check."*

**Step 7, Completeness.** *"Product confirmed the prototype. Now complete {feature}: implement the
deferred NFRs and TCs, and close the remaining scenario variants."*

## Where security actually runs

Three points, and the first is the one that matters:

- **Step 3, writing the Spec.** `secure-dev` is what turns "it should be secure" into
  named `NFR-*` and `TC-*`. Security shapes the WHAT; it is not a review afterwards
- **Step 7, completeness.** Implementing the controls the Spec already committed to
- **Step 8, the gate.** `production-readiness-gate` over the complete feature

Only running the third makes security a veto at the most expensive moment.

## The pre-PR gate: four checks

All four before anything goes up:

1. **Coherence against the Spec.** Run the conformance audit and reconcile any drift.
2. **End-to-end coverage.** Enough browser specs asserting on the real DOM.
3. **Related docs impacted.** Sibling Specs, ADRs and `docs/**` updated in the same change.
4. **Security review.** `production-readiness-gate` over the complete feature, not the prototype.

## What this changes for us

Our guide covered the documents and stopped. This adds the four things it was missing:

- **The two phases**, so a prototype gets validated before anyone invests in completeness
- **Cross-functional authorship of the WHAT**, which is better than our four-signature approval
  gate because it moves the work upstream
- **The ten steps with their prompts**, so the practice is repeatable by someone who was not in
  the room
- **The pre-PR gate**, which is where the traceability from document 3 finally gets enforced

**We adopted the platform team's layout** rather than the methodology's default: documents are
committed to `specs/NNN-feature/` as `concept-note.md`, `spec.md` and `implementation-plan.md`.
The methodology explicitly says to mirror whatever convention a repo already has, and a shared
shape is what lets one person read across four codebases.

---

Next: [Branching and PRs](07-branching-and-prs.md)
