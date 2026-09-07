<!--
Spec template — stage 2 of 3 in the AI-assisted feature methodology.

This document defines *what* the system shall do, *how* it shall behave, and
*which solutions are admissible* — not how it is built. Concrete
implementation details live in the Implementation Plan.

How to use this template:
- Replace every {{PLACEHOLDER}} with concrete content.
- Number every functional requirement (FR-001, FR-002 …), every
  non-functional requirement (NFR-001 …), and every technical constraint
  (TC-001 …). Every acceptance test should refer back to one of these IDs.
- Functional requirements use EARS syntax (see §7 preamble). Acceptance
  scenarios use Given/When/Then.
- Mark unresolved items inline with [OPEN-Q-N] so a downstream agent can spot
  and resolve them.
- This Spec must be derivable in either direction: an LLM should be able to
  generate the Concept Note from it (by inferring decisions and motivation)
  or generate the Implementation Plan from it (by mapping requirements to
  modules). To make that possible, *cite the Concept Note's decision IDs
  (D-01, D-02 …) wherever you are encoding a decision*.
- See the companion guidance file
  `staged-engineering-doc/references/spec-guidance.md` for
  section-by-section authoring tips and EARS / GWT examples.
-->

# {{FEATURE_NAME}} — Spec

> **Status:** Draft · **Date:** {{YYYY-MM-DD}} · **Owner:** {{AUTHOR}}
>
> **Reviewers:** {{REVIEWERS}}
>
> **Concept note:** [{{FEATURE_NAME_SLUG}}_CONCEPT.md](./{{FEATURE_NAME_SLUG}}_CONCEPT.md)
>
> **Implementation plan:** *not yet written*

> **Grounding evidence (`MD-25`).** This Spec grounds in the Concept
> Note's §6.5 *Sources & Origins* ledger. Where an FR / NFR / TC in this
> Spec is pinned by a specific codebase location, standard clause, or
> prior-art reference beyond what §6.5 already captures, cite it *inline*
> in the relevant section (e.g. `FR-005 — … (grounded in
> <repo>/packages/auth/session.ts:120)`) — do not defer stage-specific
> citations to §6.5. If this Spec is being authored against a Concept
> Note whose §6.5 is missing or empty, stop and back-derive the missing
> ledger first; drafting without grounding is what MD-25 exists to
> prevent.

## 1. Purpose

{{Two to four sentences: what this Spec defines, who it is for, and what it
does *not* cover (defer to the Concept Note for "why" and to the
Implementation Plan for "how").}}

## 2. Summary

{{One paragraph plain-language description of the feature for someone who has
not read the Concept Note. End with a single sentence framing the product
identity (e.g. "The system remains a requirements-gathering agent that becomes
document-aware.").}}

## 3. Scope

### 3.1 In scope

- {{...}}

### 3.2 Out of scope / non-goals

{{Restate the Concept Note's non-goals as testable boundary statements. Add
any new non-goals discovered while drafting the Spec.}}

- {{The system shall not …}}

### 3.3 Constraints inherited from the Concept Note

{{List the Concept Note decisions (D-01 …) that this Spec inherits as
constraints. Do not relitigate them here.}}

- **D-01** ({{decision title}}) — inherited; this Spec assumes …

## 4. Technical & architectural constraints

> **What goes here.** Mandates on the *solution space* — what any compliant
> implementation must respect. Distinct from:
> - **NFRs** (§8) — quality attributes the system must achieve (latency,
>   availability, security posture).
> - **Design pattern choices** — engineering judgement made by the
>   implementer; those live in the Implementation Plan as `TD-*` decisions.
>
> A useful test: if reading the constraint feels like *"the implementer is
> being told what they may not choose"*, it belongs here. If it feels like
> *"the system must achieve this measurable outcome"*, it is an NFR.

### 4.1 Platform / stack constraints

- **TC-001** — {{The implementation shall reuse {{existing system / library / vendor}} rather than introduce a parallel stack.}}
- **TC-002** — {{...}}

### 4.2 Architectural / integration constraints

- **TC-010** — {{The feature shall integrate with {{system X}} via {{contract Y}}.}}
- **TC-011** — {{Backend-specific concerns shall remain encapsulated behind {{abstraction}} so {{alternative backends}} can be substituted later without changing user-visible behaviour.}}

### 4.3 Compliance / regulatory constraints

- **TC-020** — {{e.g. data shall remain in region {{R}}; audit logs shall meet {{standard}}.}}

### 4.4 Conventions to follow

- **TC-030** — {{Prompts / scripts / configs shall follow the project's {{existing convention}}.}}
- **TC-031** — {{...}}

### 4.5 Security constraints (`MD-31`)

Security-shaped `TC-*` rows for every CWE Top 25 category the Concept
Note's §5.2 *Security posture* declared applicable. Each row cites its
CWE identifier verbatim in the TC body — the CWE number is *content
of the row*, not a new ID prefix (`MD-05`'s one-prefix-per-section
discipline is preserved).

**The CWE Top 25 is a moving target.** At Spec-authoring time,
retrieve `https://cwe.mitre.org/top25/` live over HTTPS; the closed
set this section draws from is whatever the current CISA publication
lists on that date. If the environment cannot fetch external URLs
(air-gapped / offline), tag the derived TC set
`[UNVERIFIED — offline; last known Top 25 as of {{date}}]` per
`MD-26` — the rubric grades a disclosed offline case as 🟡, not 🔴,
**and enumerate that marker in §17 *Handoff to the Implementation
Plan*** so the downstream stage inherits the verification debt (the
`MD-26` handoff obligation applies to every `[UNVERIFIED]` marker).

**Every applicable category must land as either a `TC-*` or an
explicit ruling.**

- **TC-040** — {{example: user-supplied file paths shall be resolved
  through the sandboxed-path helper before any filesystem access,
  **defends `CWE-22` *Path Traversal***}}
- **TC-041** — {{example: all HTML rendered from user-supplied
  content shall be produced by the templating layer's auto-escaping
  API, **defends `CWE-79` *Cross-Site Scripting***}}

**A category ruled out by the Concept §5.2 posture** still gets a
one-line entry, as a ruling not a commitment (this is the escape that
saves the category from the rubric's obligation-gap 🔴):

`- **CWE-79 *XSS*** — not applicable; §5.2 posture declared no HTML rendering surface.`

**Outside-Top-25 escape.** A TC citing a CWE outside the current Top 25
(e.g. `CWE-1039` AI/ML prompt neutralisation, or an OWASP LLM Top 10
category) is allowed — cite the CWE and add a one-line reason for
outside-Top-25 inclusion, mirroring `MD-27`'s `Custom arc: <N> — <reason>`.

*If no CWE Top 25 category is in scope per §5.2:*
`Security constraints: none — see Concept §5.2 posture.`

Full protocol, per-category authoring guidance, and the extended
handoff to Plan §12: `skills/staged-engineering-doc/references/security-protocol.md`.

## 5. Users & use cases

### 5.1 Personas / actors

| Actor | Description | Primary need |
|---|---|---|
| {{...}} | {{...}} | {{...}} |

### 5.2 User stories

{{INVEST-style user stories. Each story gets an ID and links to the FRs that
implement it.}}

| ID | Story | Implements |
|---|---|---|
| US-01 | As a {{actor}}, I want {{capability}} so that {{outcome}}. | FR-001, FR-003 |
| US-02 | … | … |

## 6. Glossary

{{Define every domain-specific term used in this Spec, exactly once. LLMs
hallucinate when synonyms drift — pin the terminology here.}}

| Term | Definition |
|---|---|
| {{Term}} | {{Single-sentence definition}} |

## 7. Functional requirements

> **EARS conventions used below.** Every FR is one of:
> - **Ubiquitous:** *The system shall {{do X}}.*
> - **Event-driven:** *When {{trigger}}, the system shall {{do X}}.*
> - **State-driven:** *While {{state}}, the system shall {{do X}}.*
> - **Optional feature:** *Where {{feature is enabled}}, the system shall {{do X}}.*
> - **Unwanted behaviour:** *If {{undesired condition}}, then the system shall {{respond with X}}.*
>
> One requirement per line, one ID per line, one obligation per line. No
> compound requirements ("…and also…"); split them.

### 7.1 {{Capability cluster 1}}

- **FR-001** — {{The system shall …}}
- **FR-002** — When {{...}}, the system shall {{...}}.
- **FR-003** — If {{...}}, then the system shall {{...}}.

### 7.2 {{Capability cluster 2}}

- **FR-010** — …

## 8. Non-functional requirements

{{Quantify wherever possible. "Fast" is not a contract; "p95 < 200 ms under
nominal load" is. Each NFR gets an ID so it can be cited from acceptance tests
and the Implementation Plan.}}

| ID | Category | Requirement |
|---|---|---|
| NFR-001 | Performance | {{p95 latency for action X is < 300 ms under nominal load (Y rps).}} |
| NFR-002 | Reliability | {{The feature shall maintain ≥ 99.9% monthly availability when the upstream service is healthy.}} |
| NFR-003 | Security | {{Inputs from untrusted sources shall be validated against {{schema}}; rejected inputs shall not modify state.}} |
| NFR-004 | Privacy / compliance | {{...}} |
| NFR-005 | Observability | {{Each handled request shall emit a trace span with {{attributes}}; errors shall be logged at WARN or higher with a correlation ID.}} |
| NFR-006 | Accessibility | {{...}} |
| NFR-007 | i18n / localisation | {{...}} |
| NFR-008 | Cost | {{...}} |
| NFR-009 | Scalability | {{...}} |
| NFR-010 | Maintainability | {{...}} |

## 9. System behaviour & scenarios

> **Format:** Given / When / Then. Each scenario references the FRs it
> exercises. Scenarios cover happy path, the most consequential edge cases,
> and the most consequential failure modes. They are not a substitute for
> exhaustive testing; they are the contract.
>
> **Every scenario here is a test obligation.** The Implementation Plan
> must reference a runnable test at one of the levels in the closed
> set `unit / integration / contract / e2e / property` (multi-value
> rows allowed) for each scenario in its §12.1
> *Scenario Traceability Matrix* and §16 *AC coverage* matrix. Each
> test should embed the scenario ID in its name or as a framework-native
> tag (e.g. `test_S_04_…`, `it("S-04: …")`,
> `@pytest.mark.scenario("S-04")`) so traceability survives refactors
> and is mechanically verifiable. A scenario without a test is a Plan
> gap — caught by `AC-50` in §11.5 below.
>
> **Variants for breadth.** The parent scenario above IS the happy
> path — its Given/When/Then block describes the typical successful
> flow. A scenario shipped with one happy-path test covers behaviour
> at a single point in its input/state envelope; for most non-trivial
> scenarios that point is not enough. The failure modes the
> methodology was observed missing live at the boundaries and on the
> error paths *of the same scenario*. Enumerate *shifts away from the
> happy parent* as variants directly under the scenario using
> letter-suffixed IDs (`S-04a`, `S-04b`, `S-04c`, …). Each variant is
> a one-liner naming the input or state shift, prefixed with one of
> the four kind tags below — this is a **closed set**; do not invent
> new tags ad-hoc:
>
> - `[boundary]` — at the edge of accepted input (min, max, empty, full)
> - `[failure]` — input rejected, state error, dependency unavailable
> - `[concurrency]` — race, interleaving, idempotency, retry
> - `[property]` — an invariant that should hold across many generated inputs
>
> There is no `[happy]` tag — the parent already plays that role. A
> "happy" variant would just duplicate the parent.
>
> Each variant is its own row in the Plan's §12.1 matrix with its own
> test, mechanically gated by **two** DoD tasks in the Plan: `T-N.D8`
> enforces *variant → test binding* (the regex extends to
> `S-[0-9]+[a-z]*`), and `T-N.D8b` enforces *Variants-block presence*
> via a structural awk lint over §9 — every `Scenario S-NN` heading
> must be followed by either a `Variants:` block or the explicit
> `Variants: none — single-path scenario` declaration. Without
> `T-N.D8b`, a scenario shipped without a `Variants:` block at all
> would pass `T-N.D8` silently (`comm -23` only sees IDs that exist)
> — exactly the breadth gap MD-22 exists to close. Variants of one
> scenario may legitimately ship at *different* test levels — see
> Plan §12.1 for the level decision-tree.
>
> If a scenario genuinely has only one path — no boundary, no
> failure, no concurrency, AND no property-style invariant worth
> testing across many inputs (i.e. none of the four closed kind tags
> apply) — say so explicitly: `Variants: none — single-path
> scenario.` Silent absence used to read as "I didn't think about
> variants"; the `T-N.D8b` structural lint now catches it before
> review.
>
> **Optional diagrams per scenario (MD-24).** Two diagram types are
> permitted under a scenario, both Mermaid text only, ≤15 messages (`sequenceDiagram`) or ≤15 states (`stateDiagram-v2`):
>
> - **`sequenceDiagram`** — for multi-actor scenarios (≥2 actors with
>   ordering that prose can't easily convey). Place after the GWT
>   block, before the Variants list.
> - **`stateDiagram-v2`** — for stateful scenarios where the feature
>   has named states (e.g. session lifecycle, document status). Pairs
>   well with EARS "While …" FRs.
>
> Banned: `activityDiagram` (overlaps with the two above; lowest VLM
> comprehension per SADU), PNG / SVG / ASCII art.

### 9.1 Happy path scenarios

#### Scenario S-01 — {{Title}} (covers FR-001, FR-002)

- **Given** {{precondition}}
- **And** {{additional precondition}}
- **When** {{the user/system does X}}
- **Then** {{the system shall do Y}}
- **And** {{observable consequence}}

**Variants:**

- `S-01a [boundary]` — {{at the minimum accepted size/count/length}}
- `S-01b [boundary]` — {{at the maximum accepted size/count/length}}
- `S-01c [failure]` — {{input exceeds limit → {{error response}}}}
- `S-01d [concurrency]` — {{two requests in flight from the same session}}
- `S-01e [property]` — {{invariant tested across many generated inputs — e.g. "every accepted file round-trips through extract→index→fetch"}}

#### Scenario S-02 — {{Title}} (covers FR-XXX) — single-path example

- **Given** {{precondition}}
- **When** {{the user/system does X}}
- **Then** {{the system shall do Y}}

Variants: none — single-path scenario.

### 9.2 Edge cases

> Use §9.2 for scenarios that don't naturally hang off a happy-path
> parent in §9.1 — e.g. a feature whose primary behaviour *is* the
> edge case. Most edge cases should live as variants under their
> parent scenario in §9.1.

#### Scenario S-10 — {{Title}} (covers FR-003)

- **Given** …
- **When** …
- **Then** …

**Variants:**

- `S-10a [boundary]` — {{...}}
- `S-10b [boundary]` — {{...}}

### 9.3 Failure / unwanted-behaviour scenarios

> Use §9.3 for failure scenarios with no happy-path counterpart (e.g.
> "unauthenticated user attempts X"). Failures that are the
> error-path *of* a happy scenario belong as `[failure]` variants
> under that scenario in §9.1.

#### Scenario S-20 — {{Title}} (covers FR-005, NFR-003)

- **Given** {{the upstream service is unavailable}}
- **When** {{the user attempts X}}
- **Then** {{the system shall return {{error}} with {{message}} without modifying state}}

**Variants:**

- `S-20a [failure]` — {{upstream returns 5xx}}
- `S-20b [failure]` — {{upstream times out beyond {{N}}s}}
- `S-20c [concurrency]` — {{upstream recovers mid-request — retry succeeds}}

## 10. Data model & external contracts

{{Interface-level only. Field-level schemas, migrations, and persistence
choices belong in the Implementation Plan.}}

### 10.1 Domain entities (conceptual)

| Entity | Purpose | Key attributes (conceptual) | Lifecycle |
|---|---|---|---|
| {{...}} | {{...}} | {{...}} | {{...}} |

#### 10.1.1 Entity-relationship diagram

{{**Required** when the feature introduces ≥1 new domain entity. Mermaid
`erDiagram`; conceptual only (no implementation field types); shows
entities + key attributes + relationships with cardinality. ≤15 entities;
split into two diagrams if larger. Per MD-24 — ER is the
highest-comprehension diagram class per SADU and maps directly to DDL at
Plan stage.}}

```mermaid
erDiagram
  {{ENTITY_A}} ||--o{ {{ENTITY_B}} : "{{relationship}}"
  {{ENTITY_A}} {
    {{id-type}} id PK
    {{attr-type}} {{attribute_name}}
  }
  {{ENTITY_B}} {
    {{id-type}} id PK
    {{id-type}} {{ENTITY_A}}_id FK
    {{attr-type}} {{attribute_name}}
  }
```

### 10.2 External APIs / events the feature consumes

| Source | Contract | Direction | Notes |
|---|---|---|---|
| {{...}} | {{...}} | inbound / outbound | {{versioning, idempotency, ordering}} |

### 10.3 External APIs / events the feature exposes

| Endpoint / event | Inputs | Outputs | Notes |
|---|---|---|---|
| {{...}} | {{...}} | {{...}} | {{...}} |

## 11. Acceptance criteria

{{The "definition of done" at the Spec level. Each criterion is testable and
references the FRs/NFRs/TCs/scenarios it validates.}}

### 11.1 Functional acceptance

- **AC-01** — {{All scenarios in §9.1 pass against a fresh deployment}} (covers FR-001 … FR-009).
- **AC-02** — {{...}}

### 11.2 Non-functional acceptance

- **AC-10** — {{NFR-001 verified by a load test that …}}
- **AC-11** — {{...}}

### 11.3 Constraint compliance

- **AC-15** — {{TC-001 verified by {{evidence: code review, dependency audit, integration test}}.}}
- **AC-16** — {{...}}

### 11.4 Negative / safety acceptance

- **AC-20** — {{Scenario S-20 produces no state mutation as observed via {{evidence}}}}.

### 11.5 Test & traceability obligations

> **Test- and traceability-obligation acceptance criteria.** Meta-ACs
> about the test suite and the cross-document binding fabric, in the
> spirit of a Requirements Traceability Matrix (RTM — IEEE/ISO/IEC/IEEE
> 29148). They close the most common Plan gaps: a scenario or
> quantified NFR with no runnable test (`AC-50`/`AC-51`), a TC with no
> compliance evidence (`AC-52`), a scenario with no enumerated impact
> (`AC-53`), a quantified NFR with no bound observability signal
> (`AC-54`). Without this subsection, reviewers can mark
> `AC-01..AC-20` complete on the basis of unit tests that exercise one
> happy path, while the enumerated scenarios go unverified, their
> consequences un-traced, and their post-deploy signals unwired.
>
> **Binding convention.** Every test that satisfies a Spec ID embeds
> that ID in its name or via a framework-native tag (`test_S_04a_…`,
> `it("S-04a: …")`, `@pytest.mark.scenario("S-04a")`, etc. — pick the
> convention that matches your stack and document it in §5 of the
> Plan). The §12.1 *Scenario Traceability Matrix* can then be
> auto-generated by `grep`, and the AC-50/51/52 gates become
> mechanically verifiable rather than manually maintained. The
> matrix and the `T-N.D8` regex both extend to letter-suffixed
> variant IDs (`S-[0-9]+[a-z]*`).

- **AC-50** — Every scenario in §9 — including every enumerated variant (`S-NNa`, `S-NNb`, …) — has at least one runnable test referenced in the Plan's §12.1 *Scenario Traceability Matrix*, with the scenario or variant ID embedded via a **structurally-anchored** binding (a framework mark, an `it()` / `t.Run()` / `test_case` string argument, or a function-name binding with the §12.1 normalising regex — *not* in a comment or docstring; those false-match the `T-N.D8` grep gate). The §16 *AC coverage* matrix should also cite the scenarios or scenario ranges each `AC-*` aggregates, so the roll-up is readable — this half is **reviewer-checked, not mechanically gated**. It cannot be: §16 legitimately cites ranges (`covers S-NN..S-NN`), so a `comm` against enumerated scenario IDs would report every scenario inside a range as missing. Only the binding half below is machine-enforced. Additionally, every scenario heading in §9 is followed by either a `Variants:` block enumerating its shifts or the explicit `Variants: none — single-path scenario` declaration. Mechanically enforced by Plan `T-N.D8` (variant → test binding via the anchored regex) **and** `T-N.D8b` (Variants-block structural presence) — both must pass; `T-N.D8` alone is insufficient because `comm -23` cannot detect a missing block.
- **AC-51** — Every NFR in §8 with a quantified target has a measurement test referenced in the Plan's §12 (typically §12.8 *Performance / load tests* or §12.4 *Integration tests*), with the NFR ID embedded similarly.
- **AC-52** — Every TC in §4 has a §11.3 compliance check AND a corresponding entry in the Plan's §12. Where the TC is mechanically verifiable (dependency audit, lint rule, integration test, CI policy), the §12 entry references the runnable verification with the TC ID embedded in the test name or tag. Where the TC is inherently non-mechanical (architectural standard, prose convention), the §12 entry names the reviewer / review checklist that verifies it. Mechanically gated by Plan `T-N.D10` (every `TC-NN` from §4 is referenced in Plan §12, any form of evidence) **and `T-N.D10b`** (every `TC-NN` from §4 also has a §11.3 compliance check). Both must pass — this AC is a conjunction, and `T-N.D10` alone leaves the §11.3 half unexamined.
- **AC-53** — The change has at least one `IMP-*` row in the Plan's §12.2 *Impact Traceability* matrix for every materially-affected scope (`code` / `system` / `business` / `external`). Impact is recorded at **feature granularity** — a single `IMP-*` row may be *triggered by* several scenarios, so not every `S-*` needs its own row. Each `IMP-*` row records the consequence's scope, the triggering Spec ID(s) in its *Triggered by* column, the bound risk (`R-*` if any), the bound observability signal (`OBS-*` if any), and the mitigation task (`T-N.*`). Mechanically gated by Plan `T-N.D15`.
- **AC-54** — Every NFR in §8 with a quantified target has at least one `OBS-*` row in the Plan's §11 *Observability*, with the NFR ID embedded in the row's *Binds to* column. The `OBS-*` row records the signal, type (metric / log / trace / alert / dashboard), source module, and threshold or use. Mechanically gated by Plan `T-N.D16`.
- **AC-55** — Every direct and transitive dependency in the branch's committed lockfile passes a current-advisory-DB check with **no unwaived advisory** (the scanner exits clean); any advisory the team accepts is cited in the Plan's §14 *Risks & rollback* as an `R-*` row with a rationale — severity judgement lives in the waiver, not a gate threshold — and (where possible) an `OBS-*` for the residual-risk signal. A branch with no lockfile to scan declares `Supply-chain: none — <reason>` in Plan §5 and satisfies this vacuously. Mechanically gated by Plan `T-N.D20`. Advisory data is fetched at gate-run time — no snapshot is embedded in the methodology (`MD-31`).

## 12. Success metrics

{{How we will know the feature works post-launch. Distinct from acceptance
criteria — these are observed in production over time.}}

| Metric | Target | Measurement |
|---|---|---|
| {{Adoption}} | {{≥ X% of eligible sessions in 30d}} | {{Source}} |
| {{Quality}} | {{...}} | {{...}} |
| {{Performance}} | {{...}} | {{...}} |

## 13. Dependencies

- **Upstream services / specs:** {{...}}
- **Internal modules / teams:** {{...}}
- **Feature flags / config:** {{...}}
- **Third-party APIs:** {{...}}

## 14. Assumptions

{{Things this Spec relies on being true. If any becomes false, the Spec is
invalidated; flag it in §16.}}

- **A-01** — {{...}}
- **A-02** — {{...}}

## 15. Risks

| Risk | Severity | Likelihood | Spec-level mitigation |
|---|---|---|---|
| {{...}} | High / Med / Low | High / Med / Low | {{e.g. additional NFR, additional TC, additional scenario}} |

## 16. Open questions

{{Each open question is tagged so the Implementation Plan or a follow-up Spec
revision can resolve it. Do *not* leave open questions about FR semantics —
those must be resolved before this Spec is approved.}}

| ID | Question | Owner | Target stage | Notes |
|---|---|---|---|---|
| OPEN-Q-01 | {{...}} | {{name}} | Implementation Plan | inherited from Concept Note OPEN-Q-03 |
| OPEN-Q-02 | {{...}} | {{name}} | Spec revision | must resolve before approval |

## 17. Handoff to the Implementation Plan

{{Short note for whoever (human or AI) will write the Implementation Plan
from this Spec. Call out what the Plan must respect and what it has freedom
to decide.}}

- **Plan must respect (no relitigation):** every FR-* (§7), every NFR-* (§8), every TC-* (§4), every AC-* (§11 — including the `AC-50`/`AC-51`/`AC-52` test-obligation gates, the `AC-53`/`AC-54` traceability gates, and the `AC-55` supply-chain gate in §11.5), and every Concept Note constraint inherited in §3.3.
- **Plan has freedom over:** module layout, internal class structure, file paths, design pattern choices (Strategy, Repository, etc.), choice of library {{X}} (within TC-* limits), test framework details.
- **Plan must resolve:** OPEN-Q-01, OPEN-Q-04.

## 18. Change log

| Date | Author | Change |
|---|---|---|
| {{YYYY-MM-DD}} | {{name}} | Initial draft. |

---

*This Spec defines what the system shall do, how it shall behave, and which
solutions are admissible. Concrete implementation choices (module layout,
file paths, design patterns, library picks within TC-* limits) live in
[{{FEATURE_NAME_SLUG}}_IMPLEMENTATION_PLAN.md](./{{FEATURE_NAME_SLUG}}_IMPLEMENTATION_PLAN.md).
Motivation and decision rationale live in
[{{FEATURE_NAME_SLUG}}_CONCEPT.md](./{{FEATURE_NAME_SLUG}}_CONCEPT.md).*
