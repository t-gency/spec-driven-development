---
name: three-p-visualizer
description: Generate an interactive, single-file HTML visualization of a feature/system specified with the engineering methodology, organized as the 3 Ps of software engineering — Product (what is built and how it operates, navigated as an abstraction ladder), Process (the construction workflow — branches, gates, quality machine, rollout), and Project (management — timeline, costs, risks, decisions, open questions, stakeholders). Derives everything from the methodology's three documents (Concept Note, Spec, Implementation Plan). Triggers when the user asks to visualize a spec, explain a system as product/process/project, build a 3P view, create a stakeholder-facing explainer of a feature, or render the methodology docs as an interactive page.
---

# 3P Visualizer — Product · Process · Project

This skill turns a feature documented with the 3-stage engineering
methodology (Concept Note → Spec → Implementation Plan, see the sibling
`staged-engineering-doc` skill) into a **single self-contained HTML
page** that explains the system through the three classic Ps of
software engineering:

1. **Product** — *what is being built and how it operates in
   production*. Navigated as an **abstraction ladder** (in the spirit
   of ladder-of-abstraction tooling): from system context down to the
   individual functions/rules, plus NFR lenses that cut across every
   level. Runtime operation (modes, schedules, rollback behavior) is
   part of the Product — the delivered system includes how it runs.
2. **Process** — *the workflow used to build it*: workstreams, the
   branch/phase pipeline with its human gates, the per-branch cycle
   (tasks → atomic commits → DoD → PR → merge), the quality/parity
   machine, and the rollout steps.
3. **Project** — *how the effort is managed*: gate-driven timeline and
   milestones, cost structure, sealed decisions, risk matrix, open
   questions that block milestones, stakeholders, dependencies,
   assumptions, and success metrics.

The audience is mixed (engineers, SMEs, operations, business owners):
the page must let a reader **zoom out** to the big picture and **zoom
in** to a single byte-level contract without leaving the file.

## When to invoke

Use this skill whenever the user asks to:

- visualize / explain / present a feature or system documented with the methodology
- build a "3P" / product-process-project view of a spec
- create an interactive or stakeholder-facing explainer from the Concept Note / Spec / Plan
- render the abstraction ladder of a specified system
- turn engineering docs into something non-readers of Markdown can navigate

## Bundled files

```
three-p-visualizer/
├── SKILL.md                      ← this file (always loaded)
└── references/
    ├── content-mapping.md        ← which doc sections feed which view (load in Step 2)
    └── page-scaffold.md          ← proven interaction patterns + code building blocks (load in Step 4)
```

All paths are relative to the skill directory.

## Workflow

### Step 1 — Locate and read the source documents

1. Find the feature folder (default: `docs/{feature-slug}/`) containing
   the methodology docs: `*_CONCEPT.md`, `*_SPEC.md`,
   `*_IMPLEMENTATION_PLAN.md` (or the project's equivalent naming).
   If the user pointed at a folder or file, start there.
2. **Read all three documents completely** before writing anything.
   Long plans may need paged reads — do not skip the tail sections
   (risks, rollout, open questions live there).
3. If a document is missing, proceed with what exists, but:
   - say so up front,
   - render the affected view in reduced form (e.g., no Plan ⇒ Process
     view shows only workstreams derivable from the Concept Note, and
     the Project view omits the branch timeline),
   - never fabricate the missing document's content. The sibling
     `staged-engineering-doc` skill can back-derive missing docs first
     if the user wants the full visualization.

### Step 2 — Build the 3P content model

Load `references/content-mapping.md`. It maps every section of the
three documents to its place in the visualization (view → level/section
→ source). Walk the mapping and extract, for each target, the **actual
content with its stable IDs** (`D-*`, `FR-*`, `NFR-*`, `TC-*`, `AC-*`,
`TD-*`, `S-*`, `R-*`, `OBS-*`, `IMP-*`, `OPEN-Q-*`).

**Complementary mappings.** Extension plugins may ship additional
extraction maps named `visualizer-mapping.md` that follow the same
table format and *extend* (never replace) this skill's base mapping.
If the feature folder contains documents from such an extension (e.g.
the `migration-methodology` plugin's Migration Charter / Parity Plan /
Cutover Plan), locate the extension skill's
`references/visualizer-mapping.md`, load it after the base mapping,
and walk both. Extension mappings may also append honesty rules; apply
those too.

Non-negotiable extraction rules:

- **Cite IDs everywhere.** Every card, node, and drawer panel shows the
  spec IDs it derives from. The page must be auditable against the docs.
- **Find the system's signature quirk.** Almost every system has one
  load-bearing behavioral subtlety (an evaluation-order rule, an
  idempotency twist, a legacy-compat oddity). It deserves the page's
  one **interactive simulator** (Step 4). If the Spec's edge-case
  scenarios (§9.2) highlight something, that's usually it.
- **Separate normative from illustrative.** Quantities the docs fix
  (SLAs, gate thresholds, record lengths) are rendered as facts.
  Anything you estimate to make a view legible (construction durations,
  relative effort sizes, qualitative costs) must be visually flagged
  with an explicit disclaimer ("illustrative estimate — the plan is
  gate-driven, not date-driven"). Never invent currency amounts.

### Step 3 — Choose a visual identity

Derive a **distinctive theme from the domain itself** — typography,
palette, texture, and a color narrative that carries meaning (e.g., for
a legacy-migration feature: one accent color = legacy path, another =
new path, so the migration is literally the color shifting). Avoid
generic AI aesthetics: no default system fonts, no purple-gradient-on-
white, no cookie-cutter dashboard. `references/page-scaffold.md` §1
gives the design-language rules.

### Step 4 — Build the page

Load `references/page-scaffold.md` and assemble one self-contained HTML
file (vanilla JS + CSS; web fonts are the only allowed external
dependency). Required structure:

- **Header** — feature name, one-paragraph framing, and three 3P cards
  that deep-link to the views.
- **Sticky tab bar** — `P1 Product · P2 Process · P3 Project`.
- **P1 Product** — an **abstraction ladder**: a sidebar of rungs
  (depth-indented, one accent color per level) driving a content panel.
  Default rungs — adapt names/count to the system, keep the
  top-to-bottom abstraction ordering:
  1. *System context* (C4-style pan-zoom diagram; actors; neighbors; boundary)
  2. *Operation & flows* (runtime modes as an interactive toggle; operational timeline)
  3. *Domain model* (entities; fixed-layout records as hoverable byte bars when applicable)
  4. *Containers & runtime* (deployable pieces; tech stack)
  5. *Data contracts* (frozen interfaces, rendered byte-precise when applicable)
  6. *Code architecture* (packages; design decisions `TD-*`)
  7. *Functions / rules* (the deepest level; hosts the signature-quirk **simulator**)
  After the ladder: **NFR lenses** — one chip per quantified NFR
  family; selecting a lens shows its analysis per ladder level.
- **P2 Process** — branch/phase pipeline diagram (pan-zoom, clickable)
  with human gates flagged; the per-branch cycle strip; the quality
  machine (verification layers + traceability meta-gates); a numbered
  rollout stepper with gated steps visually distinct.
- **P3 Project** — gate-driven timeline with milestones (estimates
  disclaimed); cost structure (qualitative, from the docs' dual-run /
  staffing / infra implications); sealed decisions `D-*` with
  reversibility chips; risk matrix (likelihood × severity, clickable);
  open questions table with what each blocks; success metrics;
  stakeholders / dependencies / assumptions.

Required interactions (all proven snippets in the scaffold reference):

- **Pan & zoom** on every SVG diagram (wheel zoom at cursor, drag pan,
  `+`/`−`/reset buttons) — this is what lets one page serve both the
  zoomed-out executive and the zoomed-in engineer.
- **Detail drawer** — clicking any diagram node / risk chip / branch
  opens a right-side panel with the full detail and source IDs.
- **One domain-specific simulator** for the signature quirk.
- **Hover tooltips** on byte-precise layouts.

### Step 5 — Verify in a real browser

1. Serve the folder over HTTP (`python3 -m http.server`) — `file:`
   URLs are often blocked for browser tooling.
2. Open with the browser tool. Check the console: **zero errors**
   (a missing favicon 404 is acceptable).
3. Screenshot each view and each interactive state you built (ladder
   levels, simulator with multiple failures toggled, mode toggle in
   every mode, drawer open, a zoomed diagram) and **look at the
   screenshots** — text overflow, dead controls, and unreadable
   contrast only show up visually.
4. Fix and re-verify. Then stop the server and delete temporary
   screenshots.

### Step 6 — Save

Default save path: alongside the source docs,
`docs/{feature-slug}/{FEATURE_NAME_SLUG}_3P.html`. Mirror the feature
folder's existing naming convention if it differs. Tell the user how to
open it (double-click, or `python3 -m http.server` if their browser
restricts local files).

## Operating principles

- **The docs are the single source of truth.** Every statement on the
  page traces to a doc section or carries an explicit
  estimate/disclaimer mark. When the docs conflict, surface the
  conflict to the user instead of picking silently.
- **Operation belongs to Product.** Runtime modes, schedules, SLAs and
  rollback behavior describe the delivered system, not the project
  plan. Keep them in P1.
- **Process is about construction.** Branches, gates, DoD, CI, rollout
  mechanics. A migration's traffic-shifting machinery is Product (it
  ships); the *sequence of steps the team executes* is Process.
- **Project is about management.** Time, money, risk, governance,
  unknowns, people. If the docs don't fix dates or amounts, the page
  says so — gate-driven beats date-driven, and an honest disclaimer
  beats an invented Gantt.
- **One file, no build step.** The deliverable must open from disk and
  survive being emailed. Vanilla HTML/CSS/JS; web fonts only.
- **Depth over decoration.** Every visual element must answer a reader
  question. If a diagram doesn't change what the reader understands,
  cut it.
- **English by default.** Write the page in English unless the user
  explicitly asks for another language; stable IDs and literal contract
  strings stay untranslated either way.
