# Critic rubric — Step 5 *Self-critique* and Step 7 *Independent critique*

Use alongside `SKILL.md` Step 5 and Step 7. This file is the
single normative rubric a *critic* invocation of the skill scores a
produced document against — **not** the author's authoring guide
(those live in `{concept-note,spec,implementation-plan}-guidance.md`).
Keep the two strictly separate: the authoring guides tell you *how to
produce well*; this rubric tells you *how to find what's wrong*.

**Both Step 5 and Step 7 are opt-in.** The skill prompts the user
before running either pass. If declined, the rubric is not loaded
and no critique artefact is produced; the audit signal is the
`Self-critique: skipped` entry the skill writes in the doc's
Change-log row (Step 5) or the absence of a Step 7 critique file
(Step 7).

## Why a critic pass — and why Step 7 needs a *different model*

Step 5 (self-review) is the author re-reading their own work. It catches
typos and obvious omissions. It does *not* catch the failure modes that
come from the author's own blind spots — vocabulary the author
overloaded, assumptions the author made without noticing, sections the
author thinks are clear because *they* wrote them.

Self-preference bias is well-documented in 2026 LLM-as-judge research:
when the same model authors and judges, it systematically rates its own
outputs higher than independent evaluators do (~10% on GPT-4; up to
+90% on ArenaHard). *"Larger and more capable models often show stronger
self-preference."* The mitigation is consensus: **for Step 7 (independent
critique), use a different model family than the author** — this is the
non-negotiable rule of Step 7.0. For **Step 5 (self-critique)** the
same-model rubric pass is the intended mode by design — it's the
author's own model running a structured rubric over their own work,
acknowledged upfront as catching the structural floor but biased on
the bias-shaped findings.

For Step 7 specifically: if the author was Claude Opus, run the critic
with Sonnet or Haiku — at minimum. For high-stakes specs, prefer a
different *provider* (Claude → GPT / Gemini / open model). Provider mix
is a *proxy* for error-profile diversity, not the goal; what we want is
for the critic to disagree on the right things.

> **Operating rule.** A critic invocation with the **same model family**
> as the author (see Step 7.0 in SKILL.md for what "family" means —
> `claude-opus-*`, `claude-sonnet-*`, `gpt-4o-*`, `gemini-2.5-*` are
> example families; a different size within the same family — e.g.
> `claude-opus-4-7` vs `claude-opus-4-8` — is still "same family")
> produces a Step-5 self-review, not a Step-7 independent critique.
> "Same family" is what counts — not "exact same model identifier".
> Cross-family within the same provider (Opus author, Sonnet critic) is
> the acceptable middle tier and is *not* same-family. Document the
> critic's model family in the report header so the audit trail shows
> that cross-model independence was actually achieved.

## Two modes — per-doc and cross-doc

The rubric has two distinct halves with different failure modes; do
**not** conflate them:

| Mode | Inputs | What it catches |
|---|---|---|
| **Per-doc critique** | One document (Concept Note, Spec, or Plan) | Internal failures: vague NFRs, EARS violations, missing Variants, unverifiable TCs, paraphrased FRs, missing IDs |
| **Cross-doc critique** | Two or three documents from the same feature folder | Inter-document failures: Concept `D-*` not propagated to Spec; Spec scenarios missing from Plan §12.1; Plan TD-* contradicting Spec TC-* |

A critic invocation declares which mode it is in. Step 7 in `SKILL.md`
(Step 7.1) gates this — don't try to run both at once on a single pass.

## Per-doc rubric (5 dimensions)

For each dimension, the critic enumerates findings using the format in
the *Findings format* section below. The dimensions are deliberately
**closed** — agents can't invent ad-hoc dimensions, the same way the
Spec's variant kind tags are a closed set (MD-22).

### Dim 1 — **Accuracy**

Claims grounded in source materials. The doc does not invent content
that contradicts the Concept Note, the codebase, or stated user input.
Concretely, the critic flags:

- Statements about external systems / vendors that the source did not establish
- Numeric NFRs (`p95 < 200 ms`, `99.9% availability`) without an upstream basis
- FRs / TCs that contradict an inherited `D-*` from the Concept Note
- `[INFERRED]` markers missing from content that was in fact inferred
- Citations to non-existent sections (`§7.4` when there is no §7.4)

### Dim 2 — **Consistency**

Internal vocabulary stays stable. Terms defined in the §6 Glossary are
used identically everywhere; stable IDs (`FR-001`, `D-04`, `S-04a`) are
not silently renumbered or split. Concretely:

- Term drift: §6 defines "document" then §9 uses "file" interchangeably
- ID reuse: two FRs both labelled `FR-005`
- ID skips that look like a missing FR (`FR-001`, `FR-003` with no record of `FR-002`)
- Cross-section contradictions: §3.1 "in scope" lists X, §3.2 "out of scope" also lists X
- AC references that don't match the FR/NFR/TC they cite

### Dim 3 — **Completeness**

Every template section is populated, or explicitly marked N/A with a
reason. Concretely:

- Empty placeholder text left in: `{{...}}`, `TODO`, `[INFERRED]` without follow-up
- §11.5 *Test & traceability obligations* missing any of `AC-50`–`AC-55` (Spec)
- §12.1 *Scenario Traceability Matrix* missing rows for §9 scenarios or variants (Plan)
- (Variants-block presence is checked in Dim 5.2 Spec invariants — do not re-raise here to avoid duplicate findings)
- Concept §16 *Handoff* missing settled `D-*`, decide-in-Spec `OPEN-Q-*`, or non-goal bullets
- Plan §16 *AC coverage* table rows with blank `Test` column
- §15 *Risks* table populated only with severity/likelihood but no mitigation

### Dim 4 — **Clarity**

Single-clause, testable, active-voice obligations. Concretely:

- Compound FRs ("…and also…", "…where applicable…")
- Vague NFRs ("fast", "secure", "robust") not replaced with quantified targets
- Scenarios that paraphrase the FR they exercise instead of adding specific values
- ACs that re-state FRs verbatim instead of describing evidence of compliance
- TCs that read as design pattern choices (should be `TD-*` in the Plan instead)
- Section headings that don't match what the body delivers

### Dim 5 — **Methodology-invariants**

The doc respects the methodology's stable rules — the closed sets,
binding conventions, and gating obligations encoded in `DESIGN_RATIONALE`
`MD-*` decisions. **All-doc-types** invariants apply to whichever
artefact is under critique; the **doc-type-specific** tables below
apply only to that doc type.

#### 5.0 All-doc-types invariants

| Invariant | Check |
|---|---|
| Stable IDs (`MD-05`) | `D-NN`, `FR-NNN`, `NFR-NNN`, `TC-NNN`, `AC-NN`, `S-NN` (parent) / `S-NNa` / `S-NNb` (variants, MD-22), `TD-NN`, `OPEN-Q-NN` (zero-padded two-digit form `OPEN-Q-01`, `OPEN-Q-02`, … is preferred for sortability — `OPEN-Q-N` is the placeholder form, *not* the shipped ID), `US-NN`, `A-NN`, and compound task IDs (`T-1.1`, `T-2.C3`, `T-3.D8`, `T-3.D8b` sub-DoD) used per section; no cross-prefix mixing; no silent renumbering |
| Three-doc separation (`MD-01`) | Concept = why/direction; Spec = what/behaviour; Plan = what/where/order. The doc under critique stays in its lane — Concept doesn't prescribe modules, Spec doesn't prescribe libraries, Plan doesn't re-derive Spec content |
| `[OPEN-Q-N]` / `[INFERRED]` markers (`MD-10`) | Honest unknowns surfaced; back-derived content tagged `[INFERRED]` for human review |
| Quantification | NFRs (Spec) and metrics (anywhere) are numbers, not adjectives. "Fast" / "secure" / "robust" never appears as a contract; targets are `p95 < N ms`, `≥ X% monthly`, etc. |
| Cite-don't-paraphrase | Cross-doc references use stable IDs (`D-01`, `FR-005`, `S-04a`), not paraphrases |
| Grounding evidence (`MD-25`) | Concept Note §6.5 *Sources & Origins* is populated with three sub-lists — *Codebase evidence*, *Industry-standard evidence*, *Prior-art evidence* — each either carrying real citations with one-line "what this pinned" notes or an explicit `<sub-list> evidence: none — <one-line reason>` declaration (e.g. `Codebase evidence: none — greenfield feature`). Silent absence of any sub-list is a failure (the explicit `evidence: none — <reason>` line is what distinguishes "considered and empty" from "forgot to fill"). Spec and Plan add stage-specific citations *inline* where they introduce new evidence (Spec: codebase locations pinning FR/NFR/TC; Plan: modules/files each branch touches) and reference Concept §6.5 as master ledger. Verify arXiv IDs and DOIs against the actual source page (per `MD-26` — see the row below for the symmetric external-and-internal verification rule) — fabricated citations found in §6.5 are a 🔴 finding |
| Trust but verify (`MD-26`) | Every external claim (arXiv ID / DOI / URL / paper finding quoted or paraphrased / CLI flag / syntax form / peer-framework quote / standard-clause text) is either verified against a primary source at authoring time or explicitly tagged `[UNVERIFIED — <one-line reason>]`. Every internal claim (`<repo>/path:LN` citation; cross-doc reference such as `Spec §7 already handles this`) is either verified (the file exists and the "what this pinned" note matches; the referenced section exists and its content matches the claim) or explicitly tagged `[UNVERIFIED]`. **Fabricated citations that survive to the final doc are 🔴** (author invented the source). **Un-flagged unverifiable claims are 🔴** (author neither verified nor disclosed). **`[UNVERIFIED]` markers with an illegitimate reason** (e.g. `[UNVERIFIED — didn't check]` / `[UNVERIFIED — looked plausible]` / `[UNVERIFIED — ]`) **are 🔴** — `verification-protocol.md` treats them as if the marker were absent, so the un-flagged-unverifiable-claim rule (🔴 above) applies. **All `[UNVERIFIED]` markers must be cited in the handoff-adjacent slot — Concept §16 *Handoff to the Spec* / Spec §17 *Handoff to the Implementation Plan* / Plan §15.1 *Open questions* (the Plan is terminal per MD-01 and has no handoff; markers live with its open questions)** so the downstream stage inherits the verification-debt explicitly — missing citation is 🟡. Extends the MD-25 §6.5 rubric's arXiv-verification check symmetrically to all citations. Distinguished from MD-10 `[INFERRED]` (back-derived from other docs, not primary-source verified) and `[OPEN-Q-N]` (unknown, deferred) — same marker family, different semantic category |
| Diagrams (`MD-24`) | Every diagram in the doc is a Mermaid text block (no PNG / JPG / SVG / external image links; no ASCII art); every block parses cleanly (Mermaid syntax validates — paste into https://mermaid.live, or save as `diagram.mmd` and run `npx -y @mermaid-js/mermaid-cli@latest -i diagram.mmd -o /tmp/check.svg` and confirm the SVG renders without errors); no block exceeds ~15 elements (precise unit per diagram type — nodes for `flowchart`, entities for `erDiagram`, messages for `sequenceDiagram`, states for `stateDiagram-v2`; split into two diagrams if larger); no `activityDiagram` (banned — overlaps with `sequenceDiagram` / `stateDiagram-v2`, lowest VLM comprehension per SADU); diagrams sit in the section MD-24 assigns them to (Concept §5.1/§9.4; Spec §9/§10.1.1; Plan §3/§7.1/§8.2/§9.2.1), not arbitrary other sections |
| Security posture (`MD-31`) | **Each clause names the doc it applies to** — like the `MD-25` row above, a clause fires only against the artefact that carries the section, so a Spec or Plan critiqued alone is never docked for a Concept Note's missing §5.2. **[Concept] Missing §5.2 *Security posture* declaration** → 🔴 (structural gap). **[Spec, when a Concept Note is present] A CWE category §5.2 declared in-scope has no §4.5 `TC-*` cite and no explicit ruling** → 🔴 (obligation gap: a ruling — *"CWE-XX — not applicable; §5.2 rules out …"* — is the escape valve). **[Plan] `T-N.D20` unchecked at merge with no waiver `R-*` row in §14, no disclosed-offline marker, AND no `Supply-chain: none — <reason>` token in §5** → 🔴 (supply-chain gap; an *undeclared* Supply-chain token is itself 🔴, a declared `none` passing vacuously is not). **[Cross-doc] Posture drift** (Concept §5.2 says "public API + PII"; Spec §4.5 cites no input-validation CWE) → 🟡. **[Any doc] A disclosed offline `[UNVERIFIED — offline; …]` marker** (on the §4.5 CWE-set, or the `T-N.D20` gate) → 🟡, never 🔴 — grading a disclosed diligence-blocked case 🔴 would punish honesty (`MD-26`). Full protocol: `references/security-protocol.md`. Scope reminder: this row grades security posture of *the software being specified*, not of the agent running the methodology |

#### 5.1 Concept Note — specific invariants

| Invariant | Check |
|---|---|
| §3 Goals vs §4 Non-goals | Both populated and **disjoint** — no goal also listed as non-goal |
| §4 Non-goals vs §14 Out of scope | §4 = permanent non-goals; §14 = deferred / out-of-scope-for-now. The two are clearly distinct, not duplicated |
| §9 Alternatives considered | Each alternative includes **why it was rejected** — not just listed |
| §10 Decisions | Every decision has a `D-NN` ID with reversibility classification; no anonymous decisions |
| §16 Handoff to Spec | Populated with concrete IDs — settled `D-*` to inherit, decide-in-Spec `OPEN-Q-*`, must-remain non-goal bullets. A vague "see above" handoff fails this check |
| §5 Vision (PRFAQ-style) | One paragraph, user-visible value, not architecture |
| §5.1 Context diagram (`MD-24`) | When the feature crosses ≥2 system boundaries (third-party services, other internal systems, new infrastructure), §5.1 carries a Mermaid `C4Context` block (or equivalent `flowchart LR`). Below threshold: optional. Banned: PNG / SVG / ASCII; any block >15 nodes |
| §9.4 Alternatives diagram (`MD-24`) | Optional Mermaid `flowchart` when ≥3 alternatives share a decision tree (e.g. "if X then Alt A; if Y then Alt B"); otherwise omit. Same format constraints as §5.1 |
| §6.5 Sources & Origins (`MD-25`) | Section present with all three sub-lists (*Codebase evidence*, *Industry-standard evidence*, *Prior-art evidence*) each either populated with citations + one-line "what this pinned" notes, or carrying the explicit `<sub-list> evidence: none — <one-line reason>` declaration (e.g. `Codebase evidence: none — greenfield feature`). Every citation is either a repo-rooted path (`<repo>/path:LN`) or a URL/DOI/standard-clause; bare names ("the session module", "GDPR") without an anchor are 🟡. Every citation has the one-line "what this pinned" note — the note is what makes the citation useful for back-derivation; missing notes are 🟡. §7 Research narrative claims are cross-checkable against §6.5 citations — a §7 claim not grounded in a §6.5 citation is a 🟡 (speculative claim) unless flagged with `[INFERRED]` per MD-10 |

#### 5.2 Spec — specific invariants

| Invariant | Check |
|---|---|
| EARS (`MD-03`) | Every FR matches one of the 5 EARS patterns (Ubiquitous / Event-driven / State-driven / Optional feature / Unwanted behaviour); no compound "…and also…" requirements; one obligation per line |
| GWT (`MD-04`) | Every §9 scenario is Given/When/Then; one path per scenario; references the FRs it exercises |
| §4 TC discipline (`MD-11`) | Technical / architectural constraints are solution-space mandates, **not** design pattern choices (Strategy / Repository / Observer belong in Plan as `TD-*`); not quality attributes (those are NFRs in §8); not project-wide conventions (those are in AGENTS.md) |
| §11 AC referencing | Every `AC-*` references at least one `FR-*` / `NFR-*` / `TC-*` / `S-NN`; ACs that re-state FRs verbatim instead of describing evidence-of-compliance fail this |
| §11.3 TC compliance | Each `TC-NN` in §4 has at least one matching AC in §11.3 |
| §11.5 *Test & traceability obligations* (`MD-17`) | Populated with `AC-50` (scenarios + variants → tests), `AC-51` (NFRs → measurement tests), `AC-52` (TCs → §12 verification entry), `AC-53` (impact → `IMP-*`), `AC-54` (quantified NFRs → `OBS-*`), `AC-55` (lockfile → clean supply-chain scan). Without §11.5 the Spec is a list of requirements without enforcement |
| §9 Variants for breadth (`MD-22`) | Every scenario has a `Variants:` block using the closed four-tag set `[boundary] / [failure] / [concurrency] / [property]` **OR** the explicit `Variants: none — single-path scenario` declaration. Mechanically gated by Plan `T-N.D8b` (awk lint over §9 scenario headings) — `T-N.D8` cannot detect a missing block because `comm -23` only sees IDs that exist. Silent absence is the most common observed breadth gap |
| §6 Glossary | Defined for each domain-specific term used 5+ times across the Spec; locks vocabulary so synonyms don't drift |
| §9 Scenario diagrams (`MD-24`) | Multi-actor scenarios (≥2 actors with ordering) MAY include a Mermaid `sequenceDiagram`. Stateful scenarios with named states (EARS "While …" patterns) MAY include a Mermaid `stateDiagram-v2`. Both optional; neither required. Format constraints from MD-24 §5.0 apply (Mermaid text, ≤15 messages for `sequenceDiagram` or ≤15 states for `stateDiagram-v2`, no `activityDiagram`) |
| §10.1.1 Data-model ER diagram (`MD-24`) | **Required** Mermaid `erDiagram` whenever the feature introduces ≥1 new domain entity. Lists entities + key attributes + relationships with cardinality; conceptual only (no implementation field types). ER is the highest-comprehension diagram class per SADU — and maps directly to DDL at Plan stage, removing a known agent error class |

#### 5.3 Implementation Plan — specific invariants

| Invariant | Check |
|---|---|
| Exact paths + symbols | "The auth module" never appears — paths are repo-rooted; symbols are named. Agent-execution failure mode if violated |
| §5 *Engineering rules* | `Commits` row sources from AGENTS.md (not invented); `Tests` row records the project-specific test-tag convention used in §12.1 |
| §6 DoD | Every checklist item mechanically verifiable; "code is clean" replaced by "ruff passes"; coverage gates stated as exact commands |
| Branch sizing (`MD-27`) | §7.0 opens with an `Arc:` declaration picked from the closed vocabulary (`refactor-1` / `single-branch` / `two-branch-backend-ui` / `three-branch-scaffold-core-rollout` / `five-branch-default` / `migration-5`) with a one-line justification citing Spec signals, **OR** the explicit `Custom arc: <N> branches — <reason>` escape declaration. Missing `Arc:` declaration is 🔴; off-vocabulary arc without `Custom arc:` is 🔴; `Custom arc:` with an illegitimate reason (`didn't feel like it`, blank) is 🟡. Arc-vs-signal mismatch (e.g. Plan picks `single-branch` while Spec §10 has a migration; Plan picks `five-branch-default` while Spec has no cross-service edge and no progressive-rollout NFR) is 🟡 — author defends or downsizes. §7.1 tracker row count and §7.1 branch-graph node count match the arc's declared branch count (rows > arc count = extra branches; rows < arc count = missing branches) |
| Trunk-based branches (`MD-12`) | §7.1 tracker `Base branch` defaults to trunk (`main`/`develop`); stacking exceptions documented in `Notes` with the reason |
| DoD-as-tasks (`MD-15`) | Every branch's §7.x.9 closes with a `T-N.D*` DoD block enumerating each §6 DoD item as a discrete runnable task — count varies by branch and project (sub-tasks like `T-N.D8b` are allowed when a single DoD item needs structural + behavioural gates). Nothing collapsed to "ensure §6 is satisfied" |
| Commits-as-tasks (`MD-16`) | Every branch's §7.x.9 has explicit `T-N.C*` commit tasks between implementation-task clusters; commit-message format comes from §5 `Commits` row |
| Feature flag (`MD-06`) | Each feature flag named in §10; default `false` across all envs; kill-switch behaviour explicit |
| RTM + §12.1 matrix (`MD-17`, `MD-22`) | Every Spec `S-NN` *and every variant `S-NNa`/`S-NNb`* has a row with a runnable test path. The `T-N.D8` regex `S-[0-9]+[a-z]*` runs clean: no missing IDs. Plus `T-N.D8b` (Variants-block structural presence) runs clean: every §9 Scenario heading has either a `Variants:` block or a `Variants: none` declaration. Both gates must pass — the dual gate closes the silent-Variants gap |
| Level decision-tree (`MD-22`) | `Level` column populated from the closed set `unit / integration / contract / e2e / property` (multi-value allowed). Picked per row using the §12 decision-tree (inter-service → contract; invariant → property; real I/O → integration; cross-module → integration; user-visible flow → e2e; otherwise unit). Rows that reflexively say `unit` for cross-module / cross-service scenarios fail this check |
| No fixed pyramid ratio (`MD-22`) | Plan does not declare a target 70/20/10 (or any other ratio); the shape falls out of per-row decisions |
| §16 AC coverage | Every Spec `AC-*` has a row with a populated `Test` column. Blank `Test` cell = "claimed satisfied without proof" |
| `[P]` parallelism markers | Tasks that can run concurrently with the previous (no shared file, no shared state) carry `[P]` so subagents can fan out |
| Migrations (§8) | If the feature touches a database, §8 is populated with expand-migrate-contract phasing; each phase maps to a branch; reversibility stated explicitly |
| §3 Architecture diagram (`MD-24`) | **Required** Mermaid block in §3 — C4 Component (`C4Component` or annotated `flowchart`) for agentic features (multiple specialised agents, orchestration, tool registry); for non-agentic features a `flowchart` or `sequenceDiagram` at component level is acceptable. Behaviorally annotated where possible (key method names, message labels). Container-only views (C4 L2) avoided for agentic features (methodology judgement; arXiv 2603.15021 retains L2 — skip-L2 is our choice, not the paper's). ASCII / PNG / SVG banned |
| §7.1 Branch graph (`MD-24`) | **Required** Mermaid `flowchart LR` or `gitGraph` showing merge order + `Base branch` decisions. Replaces the legacy ASCII arrow diagram. ≤15 nodes (`flowchart`) or ≤15 commits (`gitGraph`) |
| §8.2 Migration state diagram (`MD-24`) | When a migration is present, §8.2 carries a Mermaid `stateDiagram-v2` over the expand → dual-write → backfill → switch-reads → contract phases (each state maps to a branch). Skipped if no DB changes |
| §9.2.1 Cross-service sequence (`MD-24`) | Optional Mermaid `sequenceDiagram` for new/modified cross-service contracts; required when the feature introduces ≥1 new producer/consumer pair |

A methodology-invariant violation is almost always a **🔴 Blocking**
finding (see severities below) — these are the gates the methodology
exists to enforce.

## Cross-doc rubric (5 dimensions)

Runs on a pair (Concept ↔ Spec or Spec ↔ Plan) or the full triple. The
dimensions test the methodology's bidirectional-derivability promise
(`MD-02`).

### Dim X1 — **Decision propagation**

Every Concept `D-*` that the Spec inherits as a constraint appears in
Spec §3.3 (inherited) or §4 as a `TC-*` (encoded). Concretely:

- `D-NN` cited in Concept Note but absent from Spec §3.3 and §4
- `D-NN` carried as a TC in §4 but stripped of attribution to the Concept (back-derivability broken)
- Spec encodes a decision the Concept Note did not record — likely a Plan-level `TD-*` that leaked

### Dim X2 — **Behaviour coverage**

Every Spec FR / NFR / TC reaches the Plan with a clear satisfaction
path. Every Spec scenario `S-NN` *and every variant `S-NNa`/`S-NNb`*
appears in Plan §12.1 with a runnable test path. Concretely:

- Spec `FR-NNN` not mentioned in any Plan branch's `Spec coverage` line
- Spec `S-NN` missing from Plan §12.1 (gate `T-N.D8` would catch this; flag for the author)
- Spec variant `S-NNa` missing from Plan §12.1 (the breadth gap; gate `T-N.D8`)
- Spec scenario `S-NN` in §9 without a following `Variants:` block or `Variants: none` declaration (gate `T-N.D8b` structural lint; this is the breadth-gap that `T-N.D8` cannot see)
- Spec `NFR-NNN` (quantified) not bound to a measurement test in Plan §12 (gate `T-N.D9`)
- Spec `TC-NNN` not referenced in Plan §12 (gate `T-N.D10`)

### Dim X3 — **AC coverage**

Every Spec `AC-*` maps to a Plan branch in §16 with a populated `Test`
column. Concretely:

- Spec `AC-NN` missing from Plan §16
- Plan §16 row exists but `Test` column blank (the "claimed satisfied without proof" pattern)
- Plan §16 row references a test that doesn't appear in §12.1 (broken cross-link)

### Dim X4 — **No silent drift**

The Plan does not invent decisions that contradict Spec mandates, and
the Spec does not invent decisions that contradict Concept Note
mandates. Concretely:

- Plan `TD-*` that picks a library or pattern explicitly forbidden by Spec `TC-*`
- Plan §10 flag default contradicting Spec non-goal
- Spec NFR softer than what the Concept Note's `D-*` committed to (e.g., Concept said "p95 < 100 ms"; Spec says "p95 < 500 ms")
- Plan §3.1 `TD-*` records a decision that should have been a Spec `TC-*` (escalation needed — propose Spec amendment)

### Dim X5 — **Reverse-derivability**

A reader who only has the *downstream* doc could reconstruct the
upstream. Concretely:

- Plan that names libraries and patterns with no Spec `TC-*` justification (could not regenerate Spec)
- Spec with no §1/§2/§14 "why" prose (could not regenerate Concept's problem statement)
- Concept Note with no §9 alternatives (could not regenerate the decision rationale)
- Missing `[INFERRED]` markers on back-derived content

## Findings format

Each finding the critic produces uses the same structure (borrowed from
`pr-review-coda` and the ARCADE adversarial-validation pattern):

```
### {{N}}. {{short title}}

- **Dimension:** Accuracy / Consistency / Completeness / Clarity /
  Methodology-invariants / Decision propagation / Behaviour coverage /
  AC coverage / No silent drift / Reverse-derivability
- **Where:** `{{file path}}` §{{section}} (line {{N}} if known)
- **What:** {{one-sentence statement of the problem}}
- **Why it matters:** {{impact — what breaks if this stays}}
- **Evidence:** {{the specific text quoted; or the missing item named}}
- **Confidence:** High / Medium / Low
- **Severity:** 🔴 Blocking / 🟡 Should fix / 🔵 Suggestion
- **Suggested fix:** {{practical next step; specific text or section change}}
```

**Severity guide:**

- **🔴 Blocking** — Methodology-invariant violation; missing meta-AC;
  scenario without a Variants block or explicit none-declaration;
  silent drift between docs; reverse-derivability broken. Block the
  doc from being approved.
- **🟡 Should fix** — Vague NFR, unquantified target, ambiguous AC,
  paraphrased FR. Doesn't block but degrades the doc.
- **🔵 Suggestion** — Clarity wins, terminology tightening, structural
  cleanup with clear payoff.

## Calibration notes

LLM-as-judge research shows raw judge scores require calibration and
should not be used directly for cross-time or cross-study comparison.
Two consequences for this rubric:

1. **No numeric scores.** The rubric produces findings, not a 1-5
   rating. The author triages findings; they don't chase a score.
2. **Severity is not negotiable.** The Blocking / Should-fix / Suggestion
   buckets are the *per-finding* quantisation; the three-bucket *Verdict*
   (APPROVED / COMMENT / CHANGES REQUESTED) is a deterministic roll-up
   of those severities (see *What the critic does **not** do* below).
   What's banned is *scoring* — numeric ratings, letter grades, or any
   finer-grained quantisation than these two layered buckets. Drift on
   either invalidates the audit trail.

## Critique report shape

A critic invocation produces a single Markdown report with this top
structure:

```markdown
# Critique — {{doc filename}} ({{mode: per-doc | cross-doc}})

> **Critic model:** {{family / size, e.g. claude-sonnet-4-6 or gpt-4o-mini}}
> **Author model:** {{family / size, if known}}
> **Date:** {{YYYY-MM-DD}}
> **Inputs:** {{path/to/doc.md}} (+ siblings for cross-doc)

## Verdict

{{APPROVED / COMMENT / CHANGES REQUESTED}} — one paragraph.

## Findings

### Per-doc — Accuracy
[findings, or "None ✓"]

### Per-doc — Consistency
[findings, or "None ✓"]

### Per-doc — Completeness
[findings, or "None ✓"]

### Per-doc — Clarity
[findings, or "None ✓"]

### Per-doc — Methodology-invariants
[findings, or "None ✓"]

(if cross-doc mode, the cross-doc dimensions follow with the same shape)

## Summary

- Blocking: {{N}}
- Should fix: {{N}}
- Suggestions: {{N}}
- Methodology-invariants violated: {{list of MD-* IDs}}
```

If the critic model and the author model are the same family, the
report's header explicitly notes this and the *Verdict* line should
include the caveat: *"Critic / author share a model family; treat as a
strong self-review rather than independent critique."*

## What the critic does **not** do

- **Rewrite the doc.** The critic produces findings; the author decides
  what to act on. This preserves the author's authority and avoids
  the loop where the critic "fixes" something the author intended.
- **Score the doc.** No numeric ratings, no overall grade. Calibration
  drift makes scores meaningless across runs; severities + finding
  counts are what's audit-worthy. The three-bucket *Verdict* line at
  the top of the report (APPROVED / COMMENT / CHANGES REQUESTED) is
  the **one** allowed quantisation — it's a PR-style routing label
  derived deterministically from severity counts (any 🔴 → CHANGES
  REQUESTED; otherwise 🟡 / 🔵 only → COMMENT; otherwise → APPROVED),
  not a subjective grade. Anything finer-grained than those three
  buckets is banned.
- **Run both modes in one pass.** A single critique invocation is
  either per-doc *or* cross-doc, not both. The mode determines which
  rubric half loads — keeps context tight and findings interpretable.
- **Re-derive content from neighbours.** Even in cross-doc mode, the
  critic checks consistency; it does not back-derive missing content.
  Back-derivation is a separate authoring task (Step 4, derivation
  prompts in `SKILL.md`).

## References

- Self-Preference Bias in LLM-as-a-Judge (arXiv 2410.21819)
- Quantifying and Mitigating Self-Preference Bias of LLM Judges (arXiv 2604.22891)
- AI Agents-as-Judge: Automated Assessment of Accuracy, Consistency, Completeness and Clarity for Enterprise Documents (arXiv 2506.22485)
- ARCADE — Adversarial Critique Architecture for Document Evaluation (medRxiv 2025)
- Weak judges, strong panel — ensemble approach to LLM eval (orq.ai)
- Rubric-Based Evals & LLM-as-a-Judge — Adnan Masood, PhD (Medium, Apr 2026)
- Google LMEval — cross-provider LLM evaluation tool (InfoQ 2025)
