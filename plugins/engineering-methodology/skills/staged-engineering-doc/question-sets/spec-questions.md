# Spec — question set

Use this list as a **checklist**, not a script. If a Concept Note exists,
read it first and pull answers from there before asking the user. Batch
3–7 questions per turn.

## A. Inheritance from the Concept Note (if one exists)

1. **Decisions inherited.** Confirm which `D-*` from the Concept Note this Spec inherits as constraints.
2. **Open questions to resolve in this Spec.** Confirm which Concept Note `OPEN-Q-*` we must answer here.
3. **Non-goals to preserve.** Confirm the Concept Note non-goals carry forward.
4. **Anything to relitigate.** Is there any Concept Note decision the team now disputes? (If yes, fix the Concept Note first; do not silently override.)

## B. Technical & architectural constraints

> These are mandates on the *solution space* — what any compliant
> implementation must respect. Distinct from NFRs (quality attributes the
> system must achieve) and from design pattern choices (which belong in
> the Plan as `TD-*`).

5. **Platform / stack mandates.** Are there libraries, vendors, services, or layers the implementation must reuse rather than introduce a parallel stack? (E.g., "must use the existing X integration"; "must persist to Postgres".)
6. **Architectural / integration mandates.** Are there architectural patterns (event-driven, layered, plugin-based) or integration points (specific event bus, specific gateway) that the feature must follow?
7. **Backend / vendor neutrality.** Should any backend or vendor remain pluggable so it can be swapped later? If yes, behind which abstraction?
8. **Compliance / regulatory.** Data residency, audit logging, certification, retention, encryption-at-rest requirements?
9. **Conventions to follow.** Existing project conventions (prompt management, config layout, secrets handling, observability conventions) the feature must align with?
10. **Things explicitly *not* mandated.** Any solution-space item the team wants to leave to the implementer's judgement? (Captures where the Plan has freedom — useful for §17 handoff.)

## C. Users & use cases

11. **Personas.** Who interacts with the feature? Roles, not names.
12. **User stories.** 3–8 INVEST-style stories covering the primary flows.
13. **Edge personas.** Anyone with elevated privileges, restricted scope, or non-default behaviour?

## D. Functional requirements

14. **Capabilities.** Group the system's behaviours into 2–6 capability clusters. (E.g., "Upload", "Extraction", "Question generation".)
15. **Per cluster — what shall the system do?** (Drives the FR list.) Force one obligation per FR.
16. **Triggers.** For each event-driven behaviour, what is the trigger (user action, scheduled, system event, external webhook)?
17. **State-driven behaviours.** Are there modes (e.g., "while offline", "while feature flag enabled") that change behaviour?
18. **Unwanted behaviours.** What must the system explicitly refuse to do, and how should it respond?

## E. Non-functional requirements (always quantify)

19. **Performance.** Target p50/p95 latency, throughput envelope, payload sizes.
20. **Reliability.** Availability target. Degraded-mode behaviour.
21. **Security.** Authn/Authz model, input validation expectations, audit logging.
22. **Privacy / compliance.** PII categories, retention, regional restrictions.
23. **Observability.** What must be measurable in production? (Metrics, traces, logs.)
24. **Accessibility / i18n.** Required levels (e.g., WCAG 2.1 AA, supported locales).
25. **Cost / scalability.** Cost ceiling per request / per session if known. Scale envelope.

## F. Scenarios

26. **Happy path scenarios.** Top 3–5 successful flows (drives §9.1).
27. **Variants per scenario (gate).** The parent scenario IS the happy path; for each scenario in §9, enumerate the meaningful *shifts away from the happy parent* using letter-suffixed IDs and kind tags. Force the breadth conversation at Spec time, not at Plan time. The closed kind-tag set is the four-tag `[boundary] / [failure] / [concurrency] / [property]` — borrowed from ISTQB Boundary Value Analysis (for `[boundary]`), Cucumber's positive/negative scenario split (the parent is positive; `[failure]` variants are the negatives), distributed-systems testing practice (for `[concurrency]`), and property-based testing terminology (Hypothesis / fast-check / QuickCheck for `[property]`). There is no `[happy]` tag — that would just duplicate the parent. Expected answer per scenario: a bullet list (`S-NNa [tag] — one-line input/state shift`), or an explicit `Variants: none — single-path scenario` if no boundary/failure/concurrency/property variant exists. Drives §9 *Variants* sub-blocks; gated mechanically by Plan's **dual gate**: `T-N.D8` (variant→test binding via the `S-[0-9]+[a-z]*` regex; `[a-z]*` rolls over `S-04z → S-04aa` for >26 variants, though needing that many is a smell — split the parent) **plus** `T-N.D8b` (Variants-block structural presence via awk lint — catches "author shipped a scenario without thinking about variants", which `T-N.D8` cannot see because `comm -23` only diffs IDs that exist). This is the most important gate against test-breadth gaps — scenarios shipped with one happy-path test and no boundary or failure coverage.
28. **Failure modes (rolled into Q27 variants).** For each FR matching EARS "If … then …", the failure mode lives as a `[failure]` variant of the relevant scenario in §9.1, or as a standalone scenario in §9.3 if it has no happy-path counterpart. What does the user see and what does the system do?

## G. Data & contracts

29. **Domain entities.** What new conceptual entities does the feature introduce? (Conceptual only; not field-level.)
29a. **ER diagram (gate, MD-24).** If Q29 names ≥1 new entity, sketch the relationships and cardinalities (one-to-many, many-to-many, etc.) between them and any pre-existing entities they touch. Drives the **required** Spec §10.1.1 Mermaid `erDiagram`. ER is the highest-comprehension diagram class for LLMs (SADU arXiv 2604.04009 reports ER-class accuracy across 11 VLMs ranging 24.71%–82.54%, with top-tier models at the upper bound) and maps directly to DDL at Plan stage. ≤15 entities per diagram; split larger graphs along bounded-context lines.
29b. **Stateful scenarios (drives §9 stateDiagram, MD-24).** Does any scenario in §9 involve named states the feature manages (e.g. session lifecycle, document status, job phases)? If yes, note them — drives an optional Mermaid `stateDiagram-v2` under the relevant scenario.
29c. **Multi-actor scenarios (drives §9 sequenceDiagram, MD-24).** Does any scenario in §9 involve ≥2 actors with non-trivial ordering (caller, callee, third party, queue consumer)? If yes, note them — drives an optional Mermaid `sequenceDiagram` under the relevant scenario.
30. **Inbound contracts.** Which APIs/events does the feature consume?
31. **Outbound contracts.** Which APIs/events does the feature expose?
32. **Versioning / compatibility.** Existing APIs that change — what compatibility window applies?

## H. Acceptance & success

33. **Functional acceptance.** What evidence of correctness must we see at delivery?
34. **NFR acceptance.** How will each NFR be verified (load test, chaos test, audit)?
35. **Constraint compliance.** How will each TC-* be verified at acceptance time (code review, dependency audit, integration test)?
36. **Test obligations (gates).** For every scenario in §9 and every quantified NFR in §8, what kind of runnable test will verify it, and how will the test be tagged so the binding is mechanically verifiable? For every TC in §4, what kind of *verification* will it have — a runnable test with the TC ID embedded (where the TC is mechanically checkable: dependency audit, lint rule, integration test, CI policy) **or** a named reviewer / review-checklist citation (where the TC is inherently non-mechanical: architectural standard, prose convention)? (Drives §11.5 `AC-50` / `AC-51` / `AC-52` and the binding-convention note in §11.5. This is the single most important gate against functional gaps — features that pass unit tests but miss enumerated requirements. Expected answer pairs each ID with a verification reference: a test-tag convention — `test_S_04a_…`, `it("S-04a: …")`, `@pytest.mark.scenario("S-04a")`, or equivalent — for scenarios / variants / NFRs / mechanical TCs; a reviewer or checklist name for non-mechanical TCs.)
37. **Production success metrics.** What do we measure 30/60/90 days post-launch? Where is the dashboard?

## I. Risks, assumptions, open items

38. **Assumptions.** What does this Spec rely on being true?
39. **Risks.** Per Spec — beyond the Concept Note's risks, anything new surfaced while drafting?
40. **Open questions.** What remains unresolved, with owner + target stage (Plan or Spec revision)?

## J. Handoff to the Plan

41. **Plan freedom.** What is the Plan free to decide on its own (modules, libraries, file paths, design pattern choices, framework details)?
42. **Plan must resolve.** Open questions explicitly handed off to the Plan.
43. **Plan must respect.** Non-negotiable Spec elements (every FR/NFR/TC is automatic; explicitly list any that are commonly drifted from in this codebase).

## How to use answers

- A → §3.3 Inherited constraints
- B → §4 Technical & architectural constraints (TC-*)
- C → §5 Users & use cases
- D → §7 Functional requirements
- E → §8 Non-functional requirements
- F-26 → §9.1 happy path · F-27 → §9 *Variants* sub-blocks under each scenario (mechanically gated by Plan's dual gate `T-N.D8` + `T-N.D8b`) · F-28 → `[failure]` variants in §9.1 or standalone scenarios in §9.3
- G → §10 Data & contracts · G-29 → §10.1 entity table + G-29a → §10.1.1 required `erDiagram` per MD-24 · G-29b → §9 optional `stateDiagram-v2` per MD-24 · G-29c → §9 optional `sequenceDiagram` per MD-24
- H-33,34,35 → §11.1–§11.4 Acceptance criteria · H-36 → §11.5 Test & traceability obligations · H-37 → §12 Success metrics
- I → §14 Assumptions, §15 Risks, §16 Open questions
- J → §17 Handoff to the Implementation Plan
