# Content mapping — methodology docs → 3P views

This is the extraction map. For each visualization target, it lists the
source sections in the three methodology documents (template section
numbers from the sibling `staged-engineering-doc` skill; adapt if the
project's docs deviate). Walk it top to bottom while reading the docs;
collect content **with its stable IDs**.

Legend: **CN** = Concept Note · **SP** = Spec · **PL** = Implementation Plan.

---

## P1 · PRODUCT (abstraction ladder + NFR lenses)

### Rung 0 — System context

| Need | Source |
|---|---|
| One-paragraph framing ("what is this thing") | CN §1 TL;DR · SP §2 Summary |
| C4 context/container diagram content | CN §8.2 Architecture sketch · PL §3 Architecture overview |
| Actors (persons) | SP §5.1 Personas/actors · SP §5.2 user stories (US-*) |
| Neighboring systems | SP §10.2 consumed APIs/events · SP §13 Dependencies |
| System boundary / what's out | CN §4 Non-goals · SP §3.2 Out of scope |
| Glossary terms for labels | SP §6 Glossary |

### Rung 1 — Operation & flows

| Need | Source |
|---|---|
| Runtime modes / feature-flag states (the interactive toggle) | SP §7 routing/mode FRs · PL §10 Configuration & flags |
| Operational timeline (schedules, windows, SLAs) | CN §6 organisational context · SP §8 NFR (performance/window) |
| Failure & rollback behavior at runtime | SP §9.3 failure scenarios · SP FR on completion signal |
| What stays the legacy/neighbor's responsibility | CN/SP boundary decisions (e.g. D-* scope pins) |

### Rung 2 — Domain model

| Need | Source |
|---|---|
| Entities + attributes + lifecycle | SP §10.1 Domain entities |
| Fixed-layout records (byte bars with PIC/type/offset tooltips) | SP §10.1 attribute table · CN §8.3 data model sketch |
| Type-mapping subtleties worth flagging | CN/SP decisions about lossless mapping (D-*/TC-*) |

### Rung 3 — Containers & runtime

| Need | Source |
|---|---|
| Deployable pieces and their shape (job vs service, sidecars, tooling) | PL §3 + §3.1 key design decisions (TD-*) · PL §4 Module map (top-level) |
| Tech stack facts | PL §5 Engineering rules (language/build rows) · SP §4.1 TC platform constraints |
| Operability surface (probes, metrics) | SP §8 NFR operability/observability · PL §11 OBS-* table |
| Security posture & CWE constraints (`MD-31`) | CN §5.2 Security posture (feature exposure / data sensitivity / deployment surface) · SP §4.5 Security constraints (`TC-*` citing `CWE-XX`) — omit the card only when both are absent |

### Rung 4 — Data contracts

| Need | Source |
|---|---|
| Frozen interfaces, byte-precise where applicable | SP §10.2 / §10.3 external contracts · PL §9.2 internal contracts |
| Compatibility commitments | SP §4.2 TC integration constraints · PL §9.3 backwards compat |
| Completion/exit semantics | SP FR on success/failure signal · PL TD on exit mapping |

### Rung 5 — Code architecture

| Need | Source |
|---|---|
| Package/module layout | PL §4 Module map |
| Design patterns and why (each as a card) | PL §3.1 TD-* rows |
| Conventions that shape the code (constants, nullability, logging) | PL §5 Engineering rules |

### Rung 6 — Functions / rules (deepest)

| Need | Source |
|---|---|
| The actual behavioral rules, in normative order | SP §7 FR-* (behavior subset) |
| The signature quirk → **the simulator** | SP §9.2 edge-case scenarios + the D-* that seals the quirk |
| Counters / summary outputs | SP FR on run summary |

### NFR lenses (cross-cutting, after the ladder)

One lens chip per quantified NFR (or NFR family). Per lens, 2–4 bullets
that each anchor to a ladder level.

| Need | Source |
|---|---|
| Lens list + targets | SP §8 NFR-* table |
| Per-lens evidence/measurement | SP §11.2 non-functional acceptance · PL §11 OBS-* bindings · PL §12.8 perf tests |

---

## P2 · PROCESS (construction workflow)

| Section | Source |
|---|---|
| Workstreams band | CN §8.1 approach (workstreams) — map each to the branches that implement it |
| Branch/phase pipeline (the main diagram; one clickable node per branch with goal, spec coverage, gate) | PL §7 branch plan: §7.1 tracker + each §7.x Goal / Spec coverage / gates |
| Human gates between branches (SME sign-offs, platform scans, business closures) | PL §7.x verification subsections · PL §6 DoD rows that name reviewers |
| Per-branch cycle strip (tasks → atomic commits → tagged tests → DoD ×N → PR → neutral merge) | PL §7.2.9 task-checklist structure (T-N.*, T-N.C*, T-N.D*) · PL §5 Commits + Tests rows |
| Quality machine: verification layers | PL §12 test plan (unit / integration / contract / e2e / perf) — group into the system's natural layers (e.g. per-commit / staging / production campaign) |
| Traceability meta-gates cards | SP §11.5 AC-50…AC-55 + the PL §12.1 / §12.2 / §11 / §7.x.9 (`T-N.D20`) sections that enforce them |
| Rollout stepper (numbered; gated steps visually distinct) | PL §13 Rollout plan · PL §8.2 migration phases |

---

## P3 · PROJECT (management)

| Section | Source |
|---|---|
| Gate-driven timeline + milestones | PL §13 step order + any normative durations (campaign lengths, quarantine periods). Construction durations are **your estimates — disclaim them**. The docs' only hard times are the normative ones. |
| Critical path note | PL gates that depend on people (sign-offs) — call out that the critical path runs through reviews, not code |
| Cost structure (qualitative cards) | Derive from: CN §9 alternatives' cons (e.g. dual-run cost) · PL branch sizes (relative S/M/L effort) · CN/SP dependencies (infra to provision) · SME/reviewer time implied by gates · plus a "what it buys" return card from CN §2 pains. **No currency amounts unless the docs state them.** |
| Sealed decisions grid | CN §10 Key decisions (D-*) with reversibility chips · SP §3.3 inherited constraints |
| Risk matrix (likelihood × severity, clickable → detection / mitigation / rollback) | PL §14 Risks (R-* with OBS-* signals and T-N.* mitigations) — richer than CN §11; fall back to CN §11 if no Plan |
| Worst-case blast radius callout | PL §14 closing paragraph |
| Open questions table (with the "blocks" column) | SP §16 + PL §15.1 — merge, dedupe, keep owners and what each blocks |
| Success metrics cards | SP §12 Success metrics · CN §12 success signals |
| Stakeholders / dependencies / assumptions | CN §13 · SP §13 · SP §14 + PL §15.2 (assumptions with "if false" consequences) |

---

## Honesty rules (apply across all views)

1. **IDs on everything.** A card without a source ID is a smell.
2. **Normative vs illustrative.** Doc-fixed numbers render as facts;
   your estimates carry a visible disclaimer block.
3. **Missing doc ⇒ reduced view, said out loud** — never silently
   thinner content.
4. **Conflicts surface to the user** (e.g. epic text vs source code
   discrepancies recorded in OPEN-Qs) — they often deserve their own
   row in the open-questions table rather than resolution by the page.
