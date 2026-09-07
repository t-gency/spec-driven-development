# Spec authoring guidance

Use alongside `templates/SPEC_TEMPLATE.md`. This file gives section-by-section
advice; it is **not** the template itself.

> **MD-25 grounding** applies to the Spec even though the master
> `Sources & Origins` ledger lives in Concept Note §6.5. When drafting
> a Spec that introduces new evidence beyond what the Concept Note
> captured (e.g. a codebase location that pinned an `FR-*`/`NFR-*`/`TC-*`
> that wasn't in the Concept), cite it **inline** where the requirement
> is defined — do not defer stage-specific citations back to §6.5. See
> `references/concept-note-guidance.md` §6.5 for the full grounding
> discipline and per-sub-list rules.

Two additional cross-cutting reference files apply to every doc type:

- `references/verification-protocol.md` — the MD-26 *Trust but verify*
  discipline: what to verify against per claim class, the
  `[UNVERIFIED — <reason>]` marker, how it differs from `[INFERRED]`
  and `[OPEN-Q-N]`.
- `references/review-passes.md` — the MD-21 two-pass consistency check
  (self-consistency, cross-consistency) run before saving.

## Tone & shape

- The Spec is *normative*. Each requirement is a contract a tester (human
  or LLM) can verify. Vague language ("fast", "secure", "robust") fails
  this test — replace with quantified statements.
- Keep prose for §1, §2, §14. Everything else is bullets, tables, or
  Given/When/Then blocks.
- Length: most Specs land between **4,000 and 10,000 words**. Beyond the
  ceiling, split the feature.

  The band counts the **delivered document**, scaffolding included. The
  template's own normative scaffolding is ~3,900 words before a single
  placeholder is filled — §11.5's meta-ACs alone contribute ~1,100 words
  that must survive into the delivered Spec — so a conforming Spec cannot
  be shorter than the floor. The old 1,500–3,500 band predated the
  traceability layer and was arithmetically impossible to meet.

## What goes in the Spec — three flavours of obligation

The Spec contains three orthogonal kinds of normative content. Keep them
in separate sections, not mixed together.

| Flavour | Section | Question it answers | ID prefix |
|---|---|---|---|
| Functional requirement | §7 | What shall the system *do*? | `FR-` |
| Non-functional requirement | §8 | What quality shall the system *achieve*? | `NFR-` |
| Technical / architectural constraint | §4 | Which solutions are *admissible*? | `TC-` |

A useful test for separating §4 from §8:
- *"The implementer is being told what they may not choose"* → §4 (TC-*).
- *"The system must achieve this measurable outcome"* → §8 (NFR-*).

## EARS — Easy Approach to Requirements Syntax

Every functional requirement (FR) follows one of these five patterns. Pick
the one that fits the requirement; do **not** mix patterns in a single FR.

| Pattern | Template | Example |
|---|---|---|
| Ubiquitous | The system shall {{behaviour}}. | FR-001 — The system shall persist every uploaded document. |
| Event-driven | When {{trigger}}, the system shall {{behaviour}}. | FR-002 — When a user uploads a file, the system shall return a document reference within 30 seconds. |
| State-driven | While {{state}}, the system shall {{behaviour}}. | FR-003 — While a session has no uploaded documents, the system shall not invoke retrieval. |
| Optional feature | Where {{feature is enabled}}, the system shall {{behaviour}}. | FR-004 — Where the grounding feature flag is enabled, the system shall extract candidate state fields on every upload. |
| Unwanted behaviour | If {{undesired condition}}, then the system shall {{response}}. | FR-005 — If a file exceeds the configured size limit, then the system shall reject it with a clear error and shall not modify session state. |

### EARS authoring rules

- **One obligation per line.** No "…and also…". Split compound requirements.
- **Active voice.** "The system shall …", not "X shall be done by the system".
- **No implementation prescription.** "shall persist" not "shall write to Postgres".
- **One trigger per event-driven FR.** If two triggers, write two FRs.
- **Always testable.** If you cannot describe an evidence-of-compliance check, the FR is too vague.

## Given / When / Then for scenarios

Scenarios in §9 act as the executable contract. Conventions:

- One scenario covers exactly one path. If you find yourself writing
  "and then if X happens, …", split it.
- Every scenario lists the FRs it exercises.
- Cover the three §9 sub-sections with the right granularity:
  - **§9.1 Happy path** — the typical successful flow per capability.
    Most edge / boundary / failure / concurrency *variants* of a
    happy-path scenario live as `Variants:` bullets under their
    parent in §9.1, **not** as sibling scenarios in §9.2 / §9.3.
    Co-location is what surfaces missing breadth at authoring time.
  - **§9.2 Edge cases** — reserved for edge-case scenarios *with no
    happy-path parent*. These are uncommon; if an edge case is a
    boundary of an existing happy scenario, it belongs as a
    `[boundary]` variant under that parent.
  - **§9.3 Failure / unwanted behaviour** — reserved for failure
    scenarios with no happy-path counterpart (e.g. "unauthenticated
    user attempts X"). Failures that are the error-path *of* a
    happy scenario belong as `[failure]` variants under that
    parent. EARS "If … then …" FRs typically produce either kind
    depending on whether the FR has an implicit happy
    counterpart — when in doubt, prefer the variant form so
    breadth stays co-located.
- See the §9 Variants sub-section below for the closed kind-tag set
  and the letter-suffix ID convention.

Example skeleton:

```
Scenario S-12 — Upload exceeds file count limit (covers FR-005, NFR-003)
- Given a session with the grounding feature enabled
- And the configured `max_files_per_upload` is 5
- When the user uploads 6 files in a single request
- Then the system shall reject the request with HTTP 422
- And the response body shall identify which limit was exceeded
- And the session state shall not be modified

Variants:
- S-12a [boundary] — exactly at the limit (5 files) succeeds (sanity)
- S-12b [boundary] — limit + 1 (6 files) rejects (this scenario's parent path)
- S-12c [concurrency] — two requests of 4 + 3 files in flight from same session
```

## NFR quantification

Every NFR must be testable. The smell to avoid: "the system shall be fast".
The shape to use:

| Category | Bad | Good |
|---|---|---|
| Performance | "Fast" | "p95 latency for `POST /uploads` < 30 s under nominal load (10 rps, 10 MB files)." |
| Reliability | "Highly available" | "≥ 99.9% monthly availability when upstream X is healthy; degraded mode defined in S-25." |
| Security | "Secure" | "Inputs validated against the project's contract schema for this endpoint; rejected inputs do not modify state; AuthZ enforced by the project's existing auth middleware." |
| Observability | "Observable" | "Each request emits a trace span with attributes {{...}}; errors logged at WARN+ with correlation ID." |
| Compliance | "GDPR compliant" | "Personal data fields enumerated in §10.1 are encrypted at rest and excluded from logs and traces." |

## Section-by-section tips

### §3.3 Constraints inherited from the Concept Note

This is the bridge to the Concept Note. Cite each `D-*` you inherit and
state how it constrains the Spec. Do not relitigate; if you find yourself
arguing with a `D-*`, the Concept Note needs to change first.

### §4 Technical & architectural constraints

This is where solution-space mandates live — what the implementer is
*not* free to choose. Examples (not prescriptive; pick what applies to
your feature):

- **Platform / stack** — "must reuse the existing X integration layer",
  "must use vendor Y for retrieval", "must persist to Postgres because
  the platform team mandates it".
- **Architectural / integration** — "must integrate via the company's
  event bus", "must remain backend-agnostic so backend Z can be
  substituted later", "must follow the existing layered-architecture
  convention used in module W".
- **Compliance / regulatory** — "data shall remain in region R",
  "audit logs shall meet standard S", "personal data fields enumerated
  here shall be encrypted at rest".
- **Conventions** — "prompts/scripts/configs shall follow the project's
  existing convention {{X}}".

What does **not** belong here:

- **Design pattern choices** (Strategy, Repository, Observer, …) made by
  the implementer for engineering reasons. These belong in the
  Implementation Plan as `TD-*` decisions.
- **Project-wide code conventions** (file naming, import style). These
  belong in the project's `AGENTS.md` / style guide and are referenced
  from the Plan's §5, not redocumented here.
- **Quality attributes** (latency, availability, security posture). These
  are NFRs (§8).

Each TC must be **citeable** by the Plan and **verifiable** at acceptance
time (§11.3). If you cannot describe how compliance with a TC will be
checked (code review, dependency audit, integration test), the TC is too
vague.

### §5 Users & use cases

User stories use INVEST traits (Independent, Negotiable, Valuable,
Estimable, Small, Testable) as a quality filter — not a section to
author. Each story should map to at least one FR via the Implements
column; FRs without a story are usually internal-system requirements
and that's fine, but stories without FRs are usually unimplementable
wishes — promote them to FRs or drop them.

### §6 Glossary

Define each domain term **once**. LLMs hallucinate when synonyms drift, and
human reviewers disagree silently. Lock the vocabulary here.

### §7 Functional requirements

Group FRs by capability cluster (§7.1, §7.2, …). Within a cluster, order by
importance, not by chronology. Stable IDs (`FR-001`, `FR-002`) — do not
renumber when adding new FRs; keep gaps if needed.

### §9 Scenarios

A common mistake: writing scenarios as paraphrases of the FR. Scenarios
should add **specific values**, **specific timing**, and **specific
observable consequences**. If a scenario could be replaced by re-reading
the FR, delete it.

**Every scenario you write here is a test contract.** The Plan must
reference a runnable test for each in its §12.1 *Scenario Traceability
Matrix* (and the §16 AC matrix). Empirically, this is where the
methodology's functional gaps come from: scenarios get written into
the Spec, then the Plan's task list ships unit tests on the happy
path only and never wires the scenario walks. `AC-50` in §11.5
exists to make that a gate, not a hope. (Canonical wording of
`AC-50` / `AC-51` / `AC-52` lives in `templates/SPEC_TEMPLATE.md`
§11.5 *Test & traceability obligations* — those IDs (with `AC-53`–`AC-55`) are fixed
methodology rows; don't renumber them per-project.)

Each test that satisfies a scenario should embed the scenario ID in
its name or as a framework-native tag (e.g. `test_S_04a_…`,
`it("S-04a: …")`, `@pytest.mark.scenario("S-04a")`). This is the
tag-based binding pattern used by BDD frameworks and recent AI
spec-driven plugins (`swingerman/atdd`, Duvall's ATDD-driven AI
development pattern). It lets the Plan's `T-N.D8` DoD task be
mechanically verifiable via `grep`, and the traceability survives
refactors that a static table doesn't.

#### §9 Variants — covering breadth at Spec time

A scenario shipped with one happy-path test covers behaviour at a
single point in its input/state envelope. Empirically, that is *the*
failure mode the methodology was observed missing: scenarios get
enumerated, a test gets bound, and the test exercises only the
happy path. The boundaries and error paths *of the same scenario*
go unverified. The Variants sub-block in §9 closes this gap by
making breadth a first-class authoring obligation, not a
hope-it-gets-tested.

**Pattern.** The parent scenario's Given/When/Then block describes
the happy path (or, in §9.2/§9.3, the canonical edge/failure case).
*Variants are shifts away from the parent* — there is no `[happy]`
tag because a "happy" variant would just duplicate the parent. Each
scenario in §9 gets a `Variants:` block listing its meaningful
shifts as one-line bullets with stable letter-suffixed IDs (`S-04a`,
`S-04b`, …) and one of four kind tags:

| Tag | Meaning | Industry basis |
|---|---|---|
| `[boundary]` | At the edge of accepted input (min, max, empty, full, just-inside, just-outside). | Boundary Value Analysis (ISTQB): "input values at the extreme ends cause more errors." Equivalence Partitioning (ISTQB) gives the corresponding "pick one representative per class" rule for the parent. |
| `[failure]` | Input rejected, state error, dependency unavailable. | Cucumber best practice: "write separate scenarios for positive and negative test cases." (The parent is the positive; failure variants are the negatives.) |
| `[concurrency]` | Race, interleaving, idempotency, retry, replay. | Distributed-systems testing literature; not in the ISTQB list. |
| `[property]` | An invariant that should hold across many generated inputs (property-based testing). | Hypothesis / fast-check / QuickCheck terminology. |

These four are a **closed set** — don't invent new tags ad-hoc. If a
variant doesn't fit, it usually isn't a variant of *this* scenario;
write it as a separate scenario (`S-NN`).

**Why this and not full Cucumber Scenario Outlines?** Cucumber's
`Scenario Outline + Examples` table is the canonical BDD pattern for
"same scenario, parameterised over inputs", and it works — but it's
heavyweight (full Gherkin tooling, step-definition maintenance) and
its own best-practice guide warns: *"using too many scenario
outlines leads to many scenario runs … use a reasonable number."*
We get ~90% of the value with one-line variant bullets, no examples
table, no Gherkin runner.

**When to enumerate vs. when not to.** Enumerate variants for any
scenario that:

- accepts user-controllable input with valid/invalid ranges
- has documented limits (max size, max count, max length, timeout)
- has failure modes the FR enumerates (EARS "If … then …" requirements)
- crosses a concurrency boundary (multi-request, retries, idempotency)
- has an invariant that should hold for many inputs (property-test territory)

If a scenario genuinely has only one path — none of the four closed
kind tags apply (no boundary, no failure, no concurrency, no
property-style invariant) — state it explicitly:
`Variants: none — single-path scenario`. Silent absence reads as "I
didn't think about variants", which is exactly the failure mode this
sub-block was added to close.

**Mechanical gate (dual).** Each variant is a row in the Plan's §12.1
matrix with its own test, gated by **two** DoD tasks: `T-N.D8` enforces
*variant → test binding* (the regex extends from `S-[0-9]+` to
`S-[0-9]+[a-z]*` so variants are caught by `comm -23`), and `T-N.D8b`
enforces *Variants-block structural presence* via an awk lint over §9
Scenario headings. The second gate is necessary because `T-N.D8` alone
cannot detect a scenario shipped without any `Variants:` block at all —
`comm -23` only diffs IDs that *exist*. Together they close the breadth
gap completely.

**Variant ID rollover beyond 26.** Single-letter suffixes (`a`–`z`) give
26 variants per parent scenario, which fits the typical case. If you
genuinely need more, roll over multi-letter Excel-column-style:
`S-04z` → `S-04aa` → `S-04ab` → … → `S-04az` → `S-04ba` → …. The regex
`[a-z]*` accepts arbitrary length, so the gate keeps working without
edit. But: needing more than ~26 variants is a smell — usually the
parent scenario is doing too much and should be split into two
peer scenarios (`S-04` and `S-05`) with their own variants.

**Where variants live in §9.1 / §9.2 / §9.3.** Variants of a
happy-path scenario stay nested under that scenario in §9.1, even
the `[boundary]` and `[failure]` variants. §9.2 and §9.3 carry
scenarios with *no* happy-path parent (e.g. "unauthenticated user
attempts X" — no meaningful happy counterpart). This keeps related
behaviour co-located and makes the AI-coding-agent failure mode
*"trained on happy-path code, handles edge cases poorly"* harder to
hit, because variants surface as the author is still writing the
parent.

#### §9 Scenario diagrams (sequence / state) — when each helps

Per MD-24, two optional Mermaid diagram types may sit under a scenario:

- **`sequenceDiagram` — multi-actor flows.** Use when ≥2 actors with
  ordering that Given/When/Then prose makes awkward. The diagram owns
  the *timing*; the GWT block still owns the *contract* (the
  pre/post-conditions). Don't restate the GWT in the diagram; show
  what GWT can't show easily — message ordering, parallel branches,
  acks. ≤15 messages.
- **`stateDiagram-v2` — stateful features.** Use when the feature has
  named states (e.g. session lifecycle: idle → active → expired;
  document status: draft → review → published). Pairs naturally with
  EARS "While …" FRs — each `While {state}` clause corresponds to a
  state in the diagram. ≤15 states.

Both are **optional**. Don't force a diagram when the GWT block plus
Variants already say everything. The cost of a redundant diagram is
drift (the prose and diagram diverge over time, the prose wins per
*cite-don't-paraphrase*, the diagram becomes a lie).

**Banned in §9:** `activityDiagram` (overlaps with the two above;
lowest VLM comprehension per SADU), `classDiagram` (premature — that's
Plan §3 territory), `flowchart` for behaviour (use `sequenceDiagram`
or `stateDiagram-v2` instead — they're semantically richer).

### §10 Data model & external contracts

**Interface-level only.** Field names and types belong here; storage
choices and migration steps belong in the Implementation Plan. The test:
could a different team build this Spec on a completely different stack
(within the §4 constraints)? If yes, the Spec is at the right level.

#### §10.1.1 ER diagram — required for new entities

Per MD-24, every Spec that introduces ≥1 new domain entity ships a
Mermaid `erDiagram` block in §10.1.1. Required, not optional —
SADU (arXiv 2604.04009) reports ER as the highest-comprehension
diagram class for LLMs (across 11 evaluated VLMs the ER-class
accuracy ranges 24.71%–82.54%; top-tier models reach the upper
bound), and the diagram maps directly to DDL at Plan stage,
removing a known agent error class.

**What to put in:**

- Entities (named, plural-or-singular per your project's convention; pick one and stick to it across the Spec)
- Key attributes (PK + FK markers; data type hints OK but kept conceptual — `id`, `string`, `timestamp` not `BIGINT NOT NULL`)
- Relationships with cardinality (`||--o{` one-to-many, `}o--o{` many-to-many, etc. — Mermaid's standard `erDiagram` syntax)

**What to keep out:**

- Implementation field types (`VARCHAR(255)` belongs in the Plan)
- Migration steps (Plan §8)
- Storage engine choices (Plan §8 or §3)

**Complexity ceiling:** ≤15 entities. If the data graph is larger,
split into two diagrams along bounded-context lines — one diagram
of 30 entities exceeds the methodology's working-memory ceiling, and
SADU's reported monotonic accuracy decline with diagram size makes a
single 30-entity ER unlikely to remain comprehensible to current
SOTA LLMs (no specific size threshold is claimed by the paper;
≤15 is our calibration), and not readable by humans either.

#### §10 example — sequence and state diagrams elsewhere

Sequence and state diagrams belong in **§9 Scenarios** (under the
scenario they illustrate), not §10. §10 is structural (what the data
looks like); §9 is behavioural (how the system uses it).

### §11 Acceptance criteria

Each AC must reference an FR / NFR / TC / scenario it validates. ACs
without a reference are usually quality goals masquerading as ACs —
promote them to NFRs or TCs.

§11.3 (Constraint compliance) is the section reviewers most often forget.
For each TC-* in §4, write at least one AC that says how compliance is
checked (code review pass, dependency audit, integration test).

§11.5 (Test & traceability obligations) is the meta-AC layer that
catches the most common gaps in real runs of this methodology:
features that pass unit tests but miss enumerated scenarios, NFRs
that are quantified but never measured in production, and consequences
("what did I just break?") that are never enumerated. There are
six meta-ACs:

- `AC-50` — every scenario `S-*` has a runnable test in Plan §12.1.
- `AC-51` — every quantified `NFR-*` has a measurement test in Plan §12.
- `AC-52` — every `TC-*` has a §11.3 compliance check + Plan §12 entry.
- `AC-53` — the change has at least one `IMP-*` row in Plan §12.2 *Impact Traceability* for every materially-affected scope (`code` / `system` / `business` / `external`). Recorded at feature granularity — one row may cover several scenarios; you do not need one row per scenario. Closes the consequence gap.
- `AC-54` — every quantified `NFR-*` has at least one `OBS-*` row in Plan §11 *Observability*. Closes the post-deploy-signal gap.
- `AC-55` — the branch's committed lockfile has no unwaived advisory (or the Plan declares `Supply-chain: none — <reason>` in §5); any accepted advisory is an `R-*` row in Plan §14 with a rationale. Closes the known-vulnerable-dependency gap (`MD-31`).

Do not skip them. Each binds Spec content to a structurally
verifiable artefact in the Plan and is gated by a `T-N.D*` task on
the Plan side (`AC-50` → `T-N.D8`, `AC-51` → `T-N.D9`,
`AC-52` → `T-N.D10`, `AC-53` → `T-N.D15`, `AC-54` → `T-N.D16`,
`AC-55` → `T-N.D20`).

The pattern is a Requirements Traceability Matrix (RTM) restricted to
the Spec → test edge, borrowed directly from IEEE/ISO/IEC/IEEE 29148
and adopted by recent AI multi-agent papers (e.g. arXiv 2510.19868
loads RTMs into agent context). We pair it with the *tag-based
binding* idea from BDD (Cucumber, SpecFlow) and recent AI-spec
plugins (`swingerman/atdd`, Paul Duvall's ATDD-driven AI development):
every test embeds the Spec ID in its name or as a framework-native
tag, so the matrix is derivable from `grep` rather than maintained by
hand. We deliberately do **not** require Gherkin tooling — that
adds a step-definition maintenance tax and a documented LLM
"summarises multi-step scenarios" failure mode without proportional
benefit for our case.

### §12 Success metrics

Distinct from acceptance criteria. ACs are checked at delivery; success
metrics are observed in production over time. Each metric needs a
**measurement source** (which dashboard, which query, which event).

### §13 Dependencies

Services, modules, teams, feature flags, third-party APIs the feature
relies on. Distinct from §4 TCs (which are *mandates* about which
solutions are admissible) — dependencies are *facts* about what already
exists. If a dependency is at risk (vendor going away, API deprecating),
add it to §15 Risks too.

### §14 Assumptions

Things this Spec relies on being true. Each gets an `A-NN` ID. If an
assumption becomes false, the Spec is invalidated — flag the assumption
in §16 Open questions and treat the Spec as needing revision.

Examples that belong here: "the vendor X SLA continues to be ≥ 99.9%",
"the existing auth middleware authenticates all callers". Examples that
do *not*: hard requirements (those are TCs / NFRs / FRs).

### §15 Risks

Spec-level risks that could prevent delivery or invalidate requirements.
Each row gets a severity, a likelihood, and a Spec-level mitigation
(adding an NFR, adding a TC, adding a scenario). Operational rollback
risks belong in the Plan's §14, not here.

### §16 Open questions

Two kinds of open questions are acceptable here:
1. Inherited from the Concept Note, deferred to the Plan.
2. Discovered while writing the Spec, expected to be resolved by Spec
   revision before approval.

A Spec with FR-level open questions ("we don't know what should happen
when X") cannot be approved. Either resolve them or carry the underlying
ambiguity into a more general FR with explicit `If unspecified, the system
shall …` fallback behaviour.

### §17 Handoff to the Implementation Plan

When an LLM reads this Spec to draft the Plan, this section is the single
most load-bearing — symmetric to §16 in the Concept Note. Three parts:

1. **Plan must respect** — every FR / NFR / TC and the non-goals, plus
   every constraint inherited in §3.3.
2. **Plan has freedom over** — module layout, internal class structure,
   design pattern choices (Strategy, Repository, etc.), library choice
   (within TC-* limits), file paths, test framework details.
3. **Plan must resolve** — open question IDs targeting "Plan".

### §18 Change log

Append-only. One row per material change after the Spec is first
approved. Skip nits; record substantive changes (FR added, NFR
quantified differently, TC introduced or removed, AC reworded). Plan
authors check this section to know what they're tracking.

## Common authoring smells

- **Compound FRs ("…and also…").** Split them.
- **Implementation leaking in** ("the system shall write to Postgres
  table X"). If "Postgres" is mandated, it is a TC; otherwise it is a
  Plan decision. Either way, do not bury it in an FR.
- **TC that should be an NFR.** "Must be fast" is not a TC; it is an NFR
  ("p95 < 200 ms"). The TC equivalent would be "must use the existing
  caching tier {{X}}".
- **TC that is really a design pattern choice.** "Must use the Repository
  pattern" is rarely a constraint imposed from outside; it is usually an
  engineering choice. Move it to the Plan as a `TD-*` unless there is a
  documented project-wide rule.
- **NFR without a number.** Replace with a measurable target.
- **Scenarios that paraphrase FRs.** Add specific values or delete.
- **Glossary missing for a term used 5+ times.** Lock it in §6.
- **Acceptance criteria that re-state FRs.** Promote to scenarios in §9 or delete.

## Bidirectional derivation

Because the Spec is the middle document, it must support both directions:

- **Spec → Plan (forward).** Every FR / NFR / TC / AC must be specific
  enough that a Plan author can map it to a module + tests without
  ambiguity. If you find yourself writing FRs that are still abstract
  enough to admit multiple incompatible plans, tighten them.
- **Spec → Concept Note (back-derivation).** §14 assumptions, §3.3
  inherited constraints, §4 technical constraints, and "why" prose in
  §1/§2 must contain enough signal that an LLM can reconstruct the
  problem statement, vision, and alternatives section of the Concept
  Note. If those sections of the Spec are sparse, back-derivation will
  fail.
