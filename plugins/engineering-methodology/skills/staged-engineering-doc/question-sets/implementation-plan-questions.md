# Implementation Plan — question set

Use this list as a **checklist**, not a script. If a Spec exists, read it
first; many answers will be there. Read the codebase before asking
file-layout questions. Batch 3–7 questions per turn.

## A. Inheritance from the Spec

1. **FR / NFR / AC coverage.** Confirm the full list of FRs, NFRs, and ACs the Plan must satisfy.
2. **Open questions.** Which Spec `OPEN-Q-*` the Plan must resolve, and the user's preference for each.
3. **Plan freedom.** Items the Spec explicitly delegates to Plan judgement.

## B. Project conventions (read repo first)

4. **AGENTS.md / CONTRIBUTING.** Path to the project's engineering rules. (Read it; restate verbatim in §5 of the Plan.) Pay particular attention to **commit conventions** — they drive every `T-N.C*` task. If AGENTS.md is silent on commits, ask the user once for the project's style (Conventional Commits, Angular, prefix-based, free-form), record the answer in AGENTS.md and §5, and use it for `T-N.C*` message examples.
5. **Existing module layout.** Where do similar features live? (E.g., `src/services/X/`, `src/handlers/Y/`.)
6. **Tests location & style.** Test framework, test file naming, fixture conventions.
7. **Lint / type-check / test commands.** Exact commands the DoD `T-N.D*` tasks will reference (e.g. `ruff check .`, `pyright`, `pytest tests/unit/...`, `pytest --cov=path --cov-fail-under=80`).
8. **CI / pre-commit / PR-template gates.** Which DoD items are already enforced at merge by CI, pre-commit, or a PR template? (Items already gated need referencing, not re-implementing in `T-N.D*`.)
9. **Coverage / quality thresholds.** Is there a coverage gate, a complexity gate, an accessibility audit, a self-review skill the team requires? (Drives the project-specific row in §6 DoD.)
10. **Existing observability stack.** Metrics library, tracing system, log destination.

## C. Architecture

11. **Where the feature plugs in.** Which existing modules are entry points? Which are downstream consumers?
12. **New modules to introduce.** Name them (paths and package boundaries).
13. **Modules untouched but adjacent.** What sits on the path of the feature but must not change?
14. **TD-* technical decisions.** What new technical choices does the Plan commit to (beyond the Concept Note's `D-*`)? Library picks, abstraction choices, data-shape choices.
14a. **§3 Architecture diagram shape (drives §3 Mermaid block, MD-24).** Is this an *agentic* feature (multiple specialised agents, orchestration, tool registry, decision loops)? If yes — use C4 Component (Container-only views under-represent multi-agent orchestration per industry consensus). If no — pick `flowchart` (component granularity) for structural features or `sequenceDiagram` for mostly-behavioural ones. ≤15 elements per diagram (components for C4 Component; nodes for `flowchart`; messages for `sequenceDiagram`); split if larger.

## D. Data model & migrations (skip if no DB changes)

15. **Schema deltas.** New tables/columns/indexes, with types and nullability.
16. **Migration sequence.** Expand-migrate-contract phases — which branch lands which phase?
16a. **Migration state diagram (gate, MD-24).** If this feature includes a migration, the answer to Q16 drives a **required** Mermaid `stateDiagram-v2` in §8.2 — one state per phase (expand → dual-write → backfill → switch-reads → contract), each annotated with the branch it lands in. Skip if no DB changes.
17. **Backfill plan.** Idempotency, resumability, expected runtime, batch size.
18. **Reversibility.** Per phase — reversible or forward-only? If forward-only, blast radius and recovery.

## E. APIs & contracts

19. **New endpoints.** Method, path, auth, request shape, response shape, status codes (4xx and 5xx, not just 200).
20. **Modified endpoints.** Backwards-compat behaviour, deprecation window.
21. **Internal contracts.** New events/queues/types crossed by the feature.
21a. **§9.2.1 cross-service sequence diagram (gate, MD-24).** Does this feature introduce ≥1 new producer/consumer pair (new event, new queue, new internal API, or a new contract crossed)? If yes, the answer drives a **required** Mermaid `sequenceDiagram` in §9.2.1 — one lane per actor, ordered messages, error/timeout arrows where they exist. If no producer/consumer pair is introduced, optional.

## F. Configuration & flags

22. **Feature flag name.** And default per env (dev, beta, prod).
23. **Other config.** Env vars, secrets, runtime limits.
24. **Kill-switch behaviour.** What happens when the flag flips off mid-traffic?

## G. Branch / phase plan

25. **Branch arc.** How many branches? Confirm names. (Default base is trunk — `main`/`develop` — for every branch; ask only when there's a reason to stack.)
26. **Trunk name.** What is the team's trunk branch (`main`, `develop`, something else)?
27. **Stacking exceptions.** Are there branches that genuinely cannot compile/test without uncommitted code from a prior branch? If yes, which ones and why? (Default answer: none.)
28. **Per-branch goal.** One sentence per branch describing the end state.
29. **Per-branch Spec coverage.** Which FRs/NFRs/TCs/ACs each branch satisfies. (This drives §16 of the Plan.)
30. **Per-branch verification.** How will we know the branch is done? (Tests, command, behaviour.)
31. **Per-branch task list.** Decompose into file-level tasks; mark `[P]` on parallelisable ones. **Confirm two patterns are present in every branch's checklist:** (a) `T-N.C*` commit tasks group implementation tasks into atomic commits whose message format follows §5 `Commits`; (b) the closing `T-N.D*` DoD block enumerates each §6 DoD item with the runnable commands from B-7. **Sub-tasks** like `T-N.D8b` are allowed when a single DoD item needs both a structural and a behavioural gate (e.g. T-N.D8 binds variants to tests; T-N.D8b structurally lints that every §9 scenario has a `Variants:` block).

## H. Test plan

32. **Scenario Traceability Matrix (gate).** For every Spec scenario `S-NN` in §9 *and every enumerated variant* `S-NNa`, `S-NNb`, …, name the test file/function that exercises it and pick the test level from the closed set `unit / integration / contract / e2e / property` (multiple levels allowed per row when warranted). Apply the per-scenario decision-tree in `references/implementation-plan-guidance.md` §12 — top-down: inter-service contract? property/invariant? real external systems? cross-module? user-visible flow? otherwise unit. Do **not** declare a target pyramid ratio up front — the shape of the suite falls out of per-row decisions. Drives §12.1 *Scenario Traceability Matrix* and the **dual DoD gate** — `T-N.D8` (variant→test binding via `S-[0-9]+[a-z]*` regex) **plus** `T-N.D8b` (Variants-block structural presence via awk lint over Spec §9 headings; closes the silent-Variants gap that `comm -23` cannot detect since it only sees IDs that exist). Empirical failure modes: (a) the matrix question gets skipped and enumerated scenarios go unverified; (b) every row picks `unit` reflexively, leaving cross-module / cross-service paths untested; (c) the author ships a scenario with no `Variants:` block at all — caught only by `T-N.D8b`, not by `T-N.D8`.
33. **Test-tag convention.** Which stack-appropriate tag convention will the project use to bind tests to Spec IDs (`test_S_04_…`, `it("S-04: …")`, `@pytest.mark.scenario("S-04")`, Cypress tags, etc.)? Record the answer in Plan §5 *Engineering rules* (Tests / Test tagging row). This is what makes §12.1 and `T-N.D8` mechanically verifiable rather than manually maintained.
34. **Quantified-NFR measurement (gate).** For every NFR in Spec §8 with a number, name the test file that measures it. Drives §12.8 and the `T-N.D9` DoD task.
35. **TC compliance verification.** For every TC in Spec §4, what evidence verifies it — a runnable test with the TC ID embedded (for mechanically verifiable TCs: dependency audit, lint rule, integration test, CI policy) **or** a named reviewer / review-checklist citation (for inherently non-mechanical TCs: architectural standard, prose convention)? Drives §11.3 of the Spec and §12 of the Plan. Gates Spec §11.5 `AC-52`, mechanically verified by `T-N.D10` which accepts both evidence forms — runnable test path *or* reviewer/checklist name — because TCs are heterogeneous.
36. **Impact Traceability (gate).** What does this change actually affect, and where does each consequence land? Enumerate the impacts at **feature granularity** — at least one `IMP-*` row for every materially-affected `scope` (`code` / `system` / `business` / `external`), each with the triggering Spec ID(s), the bound risk (`R-*` if any), and the bound observability signal (`OBS-*` if any). A single row may cover several scenarios; you do **not** need one row per scenario. Drives §12.2 *Impact Traceability* and the `T-N.D15` DoD task. In greenfield projects, expect `scope=code` to be rare and `scope=external`/`business`/`system` to dominate — forward-looking commitments rather than retroactive regressions.
37. **Unit tests.** New test files and what they cover, *beyond* the scenario-coverage tests.
38. **Integration tests.** Which integrations need them; environment expectations.
39. **Contract tests.** Producer/consumer pairs.
40. **End-to-end / smoke.** Pre-rollout smoke; post-deploy verification path.

## I. Observability

41. **Signal per quantified NFR (gate).** For every quantified NFR in Spec §8, which `OBS-*` (metric / log / trace / alert / dashboard) will measure it in production? Drives §11 *Observability* and the `T-N.D16` DoD task. NFRs without a bound signal are quantified contracts no one is going to verify.
42. **New metrics / traces / logs.** Names, types, labels, alerting thresholds — one `OBS-*` per row in §11. Each binds to an `NFR-*`, `S-*`, or `R-*`.
43. **Dashboards / alerts.** What needs to exist at GA; which `OBS-*` rows feed each.

## J. Rollout & rollback

44. **Rollout sequence.** Dev → beta → prod stages, percentages, dwell time.
45. **Rollback procedure.** Per branch — exact command/PR-revert order.
46. **Worst-case blast radius.** If everything goes wrong, what is the recovery story?

## K. Risks & open items

47. **Risks (gate).** Beyond Spec / Concept Note risks — every `R-*` row in §14 must cite a likelihood, severity, detection signal (preferably an `OBS-*` from §11), a **mitigation path**, and an exact rollback procedure. The mitigation path is one of: a task `T-N.*` in §7.x.9, an explicit `accepted (rationale: …)`, or `monitored only — see OBS-NN`. Drives §14 and the `T-N.D17` DoD task.
48. **Open questions.** What remains unresolved at Plan time, with target branch for resolution.
49. **Assumptions.** What this Plan relies on being true.

## L. Consistency gates

50. **Self-consistency (gate).** Run the within-doc pass from `references/review-passes.md`: every ID referenced inside this Plan resolves to a definition inside this Plan (no dangling intra-doc references); every `OPEN-Q-*` in §15.1 either resolves or is carried forward; prescribed sections are present. Referential integrity only — non-contiguous ID numbering is fine. Drives the `T-N.D18` DoD task.
51. **Cross-consistency (gate).** Run the across-doc pass: every Spec ID (`FR-*` / `NFR-*` / `TC-*` / `AC-*` / `S-*`) cited in this Plan resolves in the Spec; every Concept Note `D-*` cited resolves in the Concept Note; every Spec `OPEN-Q-*` targeting "Plan" is resolved or carried into §15.1. Any unresolved citation is a dangling reference. Drives the `T-N.D19` DoD task.

## How to use answers

- A → §3.1 TD-* citing Spec, §6 DoD, §16 AC coverage
- B-4,5,6,10 → §5 Engineering rules (B-4 specifically governs the `Commits` row; commits drive §7.x.9 `T-N.C*` task message format) · B-7,8,9 → §6 DoD (verbatim commands), §7.x.9 `T-N.D*` tasks
- C → §3 Architecture, §4 Module map, §3.1 TD-* · C-14a → §3 required Mermaid architecture (C4 Component / `flowchart` / `sequenceDiagram`) per MD-24
- D → §8 Data model & migrations · D-16a → §8.2 required `stateDiagram-v2` per MD-24
- E → §9 API & contract changes · E-21a → §9.2.1 required `sequenceDiagram` per MD-24
- F → §10 Configuration & feature flags
- G → §7 Branch / phase plan (whole section); G-31 specifically gates §7.x.9 DoD blocks
- H-32 → §12.1 Scenario Traceability Matrix + §16 AC matrix Test column · H-33 → §5 Engineering rules (Test tagging row) · H-34 → §12.8 Performance / load · H-35 → §11.3 + §12 · H-36 → §12.2 Impact Traceability + §16 AC matrix Test column for `AC-53` · H-37,38,39,40 → §12.3–§12.7
- I-41 → §11 Observability + §16 AC matrix Test column for `AC-54` · I-42,43 → §11
- J → §13 Rollout, §14 Risks & rollback
- K-47 → §14 Risks (`R-*` rows + `T-N.D17` gate) · K-48,49 → §15 Open questions & assumptions
- L-50 → §6 DoD + §7.x.9 `T-N.D18` (self-consistency) · L-51 → §6 DoD + §7.x.9 `T-N.D19` (cross-consistency) · supply-chain → §5 `Supply-chain` token (lockfile path or `none — <reason>`) + §6 DoD + §7.x.9 `T-N.D20` (gates `AC-55`, `MD-31`)
