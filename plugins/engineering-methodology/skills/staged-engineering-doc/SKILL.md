---
name: staged-engineering-doc
description: Produce or derive any of the three engineering methodology documents — Concept Note, Spec, or Implementation Plan — for a software feature. Triggers when the user wants to start a new feature doc, turn a concept note into a spec, generate an implementation plan from a spec, back-derive an upstream document, or fill gaps in an existing draft. Guides the user through targeted Q&A and codebase research instead of one-shot generating. Templates, references, and question sets are bundled inside this skill.
---

# Staged Engineering Methodology Documents

This skill helps the user produce any of three documents in the team's
3-stage AI-assisted feature methodology:

1. **Concept Note** — *why* and *what direction* (problem, vision, alternatives, decisions, PoC findings).
2. **Spec** — *what the system shall do, how it shall behave, and which solutions are admissible* (FRs in EARS, NFRs, TCs, scenarios in Given/When/Then, acceptance criteria).
3. **Implementation Plan** — *what to build, where, and in what order* (module map, file paths, signatures, branch plan, test plan, rollout).

Each document stands on its own. From any one, the previous or the next
should be derivable by a competent reader (human or AI).

## When to invoke

Use this skill whenever the user asks to:

- draft / write / create a Concept Note, Spec, or Implementation Plan
- turn / convert / promote one of these into the next (Concept Note → Spec, Spec → Implementation Plan)
- back-derive an upstream doc from a downstream one (Plan → Spec, Spec → Concept Note)
- start a new feature using the methodology
- review / improve / fill gaps in an existing draft against the template
- iterate on a previously approved document (add a change-log row)
- **critique** / cross-doc consistency-check a finished doc (or set of docs) against the methodology rubric (Step 7 — *Critique pass*)

## Bundled files

This skill is self-contained. Everything it needs is inside the skill
directory:

```
staged-engineering-doc/
├── SKILL.md                ← this file (always loaded)
├── templates/              ← the artefact structure (load when drafting)
│   ├── CONCEPT_NOTE_TEMPLATE.md
│   ├── SPEC_TEMPLATE.md
│   └── IMPLEMENTATION_PLAN_TEMPLATE.md
├── references/             ← authoring craft / quality coaching + critique rubric (load on demand)
│   ├── concept-note-guidance.md
│   ├── spec-guidance.md
│   ├── implementation-plan-guidance.md
│   └── critic-rubric.md         ← Step 5 *self-critique* + Step 7 *independent critique* normative rubric
└── question-sets/          ← interview checklists (load when gathering context)
    ├── concept-note-questions.md
    ├── spec-questions.md
    └── implementation-plan-questions.md
```

All paths below are relative to the skill directory. Do **not** invent
absolute paths or assume files live elsewhere.

**Roles of the three supporting-file types** (see DESIGN_RATIONALE.md
MD-13 in the methodology root if it ships alongside the skill):

- A **template** tells you *what to produce* (artefact structure).
- A **reference** tells you *how to produce it well* (craft knowledge).
- A **question set** is a **checklist**, not a script — *how to elicit the content*.

Load each only when needed; keep working context tight.

## Workflow

The skill has two **invocation modes** with shared rubric machinery:

- **Authoring mode** (default) — produce or derive a doc. Steps 1–6.
- **Critique mode** — score an already-written doc (or set of docs) against `references/critic-rubric.md`. Step 1 routes here, then Step 7 runs standalone — Steps 2–6 (template loading, gathering, drafting, self-critique, saving) are skipped since the doc already exists.

Step 1 routes between the two. Don't skip Q&A in either mode —
one-shot generation produces shallow, generic docs; one-shot critique
misses the high-value findings.

### Step 1 — Identify the task

Ask, briefly, only the things not already obvious:

1. **Mode.** Authoring (draft / derive / iterate) or critique (score against the rubric)? If critique, skip to Step 7.
2. **Which document** are we producing or critiquing? (Concept Note, Spec, or Implementation Plan.)
3. **Starting point** (authoring mode). From scratch? From an existing upstream doc? From an existing downstream doc (back-derivation)? From a partial draft? *Iterating on an approved doc?* (If iterating, you'll add a change-log row in Step 6.)
4. **Source materials.** If the user mentioned source documents, **collect all of them** before drafting — multiple sources are common (e.g., approved Concept Note + a partial Spec the user is filling in). Read each before asking the user anything.

If a feature name was not given, ask. If multiple source docs disagree
with each other, surface the conflict and ask the user how to resolve
before drafting anything.

### Step 2 — Load the template + guidance

Read the matching template from `templates/`. Read the matching guidance
file from `references/`. Do not paraphrase the template — produce the
final document by replacing `{{PLACEHOLDERS}}` and filling sections with
real content; preserve the section order and IDs unless the user
explicitly asks to deviate.

### Step 3 — Ground and gather context

**Per MD-25, Step 3 is a numbered *Research Process*, not a soft
suggestion.** Run the three Research Process sub-steps (3.1–3.3) below, plus 3.4 question-set fill, *before* Step 4 drafting.
Findings from each sub-step populate the doc's `Sources & Origins`
section. The **Concept Note carries the master §6.5** ledger with the
three sub-lists; **Spec and Plan** don't add a dedicated section — they
carry a short MD-25 pointer callout near the Purpose/Summary that links
back to Concept §6.5 and expect stage-specific citations *inline* where
they introduce new grounding evidence (Spec: codebase locations pinning
each FR/NFR/TC; Plan: modules/files each branch will touch). Empty
sub-lists are expressed as `<sub-list> evidence: none — <one-line reason>` (e.g. `Codebase evidence: none — greenfield feature`) — the **explicit declaration matters, silent absence does not**.

#### Step 3.1 — Codebase Analysis

If a codebase exists:

- Search for similar/adjacent features: read the top hits before asking the user.
- Identify reference files: existing modules the new feature will call, extend, or resemble. Cite them as `<repo>/path/to/file.ts:LN` (line-anchored when a specific function/pattern matters, module-level otherwise).
- Note conventions: naming, layering, error-handling, logging, feature-flag, migration patterns already in the code.
- Check test patterns: how existing similar features are tested (fixture conventions, RTM tag convention per MD-17, Variant enumeration per MD-22).
- Record what each cited file *told you* — a one-line "what this pinned" note next to each citation, so a downstream reader can back-derive why the FR/NFR/TC was shaped that way.

If no codebase exists (greenfield): declare `Codebase evidence: none — greenfield feature` in §6.5 explicitly.

#### Step 3.2 — Industry-Standard Analysis

Identify standards the feature must respect. Three classes to enumerate:

- **Regulatory** — HIPAA / GDPR / PCI / SOC 2 / regional data-residency / accessibility (WCAG 2.1 AA) / any sector-specific (aviation, medical, finance).
- **Architectural** — 12-factor, DDD, microservices, event-driven, CQRS, OAuth / OIDC, REST / gRPC / GraphQL convention, and (per CPRE §4.2) an `ISO/IEC/IEEE 25010` quality-model check when the feature has non-trivial quality requirements.
- **Style / project convention** — `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `CODEOWNERS`, any `docs/**/*.md` policy files present in the repo; company-specific playbooks the team follows.

If external web-search is warranted (e.g. checking the current wording of a standard, or the state of an evolving best practice), do it before asking the user. Cite the source URL or standard section. If nothing applies, declare `Industry-standard evidence: none — no applicable regulatory/architectural/style constraints beyond default project conventions` in §6.5 explicitly.

#### Step 3.3 — Prior-Art Analysis

Peer products, prior features in this codebase, papers/frameworks. Two moves:

- Ask "has this been tried here before?" — look for prior Concept Notes / Specs / Plans in the same repo or sibling repos that solved something adjacent. Cite them by path.
- Ask "how do peer products or the literature handle this?" — competitor / OSS analog; academic paper or industry write-up if the feature is in a well-studied area. Cite by URL or DOI. Verify arXiv IDs against the actual paper's abstract page (per `MD-26` — fabricated citations are a real failure mode we've observed).

If neither applies, declare `Prior-art evidence: none — <one-line reason>` in §6.5 explicitly.

#### Step 3.4 — Question-set fill (question sub-steps that Sources didn't answer)

*After* the Research Process runs, use the matching `question-sets/*.md`
file as a **checklist** for whatever the three sub-steps above did not
close. For each remaining unanswered question:

- If a source document (project doc, AGENTS.md, etc.) answers it, extract the answer and **cite the source section** in your draft.
- If the codebase now obviously answers it (existing module names, current API shapes surfaced by Step 3.1), extract and cite.
- If it remains unanswered, ask the user — batch questions (3–7 per turn), use `AskUserQuestion` for constrained/multiple-choice, use a numbered list otherwise.

Do not invent answers. If after Steps 3.1–3.4 something is still
unresolved, leave it as `[OPEN-Q-N]` in the draft and add it to the
doc's Open Questions section. Surfacing unknowns is better than
fabricating.

> **`*** CRITICAL — DO NOT PROCEED TO STEP 4 UNTIL SOURCES & ORIGINS IS POPULATED ***`**
>
> Per MD-25, drafting before grounding produces docs that invent
> conventions the codebase already implements, miss applicable
> standards, and rediscover prior-art conclusions. If any §6.5 sub-list
> is neither cited-and-populated nor explicitly declared as
> `<sub-list> evidence: none — <reason>` (e.g. `Codebase evidence: none — greenfield feature`),
> do not advance to Step 4 — return to Step 3.1–3.3 or ask the user
> which sub-list needs an `evidence: none — <reason>` declaration.

#### Iterating on an existing draft

If the user is filling gaps in an existing draft (rather than producing
a fresh document):

1. Read the current draft completely first.
2. Identify which sections are populated, which are empty, and which contain `[OPEN-Q-N]` markers.
3. Walk only the unpopulated / unresolved subset of the question set.
4. Preserve existing IDs verbatim (`FR-007` already in the draft must remain `FR-007`).
5. **Step 5 self-critique prompt still applies** — after the iteration is drafted, ask the user whether to run the rubric-based self-critique pass on the updated doc (Step 5's standard opt-in flow). Skipping is fine; silently bypassing the prompt is not.
6. Add a row to the doc's Change log (§18 of the Concept Note, §18 of the Spec, §17 of the Plan) describing what was added or resolved, including the Step 5 result (`Self-critique: skipped` or `Self-critique: passed (N🔴 / N🟡 / N🔵)`).

### Step 4 — Draft section by section

Produce the document **in sections**, not as one giant blob. After each
major section (or every 2–3 minor sections), pause for user review unless
the user has explicitly said "draft the whole thing, I'll review at the
end".

While drafting:

- **Concept Note** — keep it exploratory; alternatives + decision rationale are the highest-signal sections. Tag every decision `D-NN`. Solution-space decisions (must use vendor X, must reuse system Y, must remain backend-pluggable) will become `TC-*` in the Spec — make them explicit and atomic in §10. **§5.1 Mermaid `C4Context` is required (per MD-24) when the feature crosses ≥2 system boundaries**; optional otherwise. **§9.4 comparison flowchart** is optional for ≥3 alternatives sharing a decision tree.
- **Spec** — defines what the system shall do, how it shall behave, **and which solutions are admissible**. Every functional requirement uses EARS phrasing and gets an `FR-NNN` ID. Every NFR is quantified and gets an `NFR-NNN` ID. Every technical / architectural constraint (solution-space mandate) gets a `TC-NNN` ID and lives in §4 — never in FRs or NFRs. Every scenario is Given/When/Then and references the FRs it exercises. Cite Concept Note `D-*` decisions wherever the Spec is encoding one. Design pattern choices (Strategy, Repository, …) do **not** belong in the Spec — they are Plan-level `TD-*`. **§11.5 *Test & traceability obligations* is mandatory**: six meta-ACs (`AC-50`–`AC-55`) — the first three gate every scenario, every quantified NFR, and every TC to having a verification reference in the Plan (runnable test for scenarios / quantified NFRs / mechanical TCs; reviewer or review-checklist citation for non-mechanical TCs), and `AC-53`/`AC-54`/`AC-55` extend the same gate-it-or-declare-it discipline to impact (`IMP-*`), observability (`OBS-*`), and supply-chain (clean lockfile scan). **§9 *Variants* are mandatory per scenario**: enumerate the meaningful input/state shifts of each scenario as letter-suffixed sub-IDs (`S-NNa`, `S-NNb`, …) with a kind tag from the closed set `[boundary] / [failure] / [concurrency] / [property]` (the parent scenario IS the happy path — no `[happy]` tag). If a scenario genuinely has only one path, declare it explicitly: `Variants: none — single-path scenario`. Silent absence is the most common test-breadth gap in real runs. Without §11.5 the Spec is a list of requirements without enforcement; without §9 Variants the tests Plan will ship will cover the happy path and nothing else. **§10.1.1 Mermaid `erDiagram` is required (per MD-24) when ≥1 new entity is introduced**. **§9 scenario diagrams** (Mermaid `sequenceDiagram` for multi-actor; `stateDiagram-v2` for stateful) are optional but encouraged where prose would be awkward.
- **Implementation Plan** — use exact paths and exact symbol names (no "the auth module"). Phase work into branches behind a feature flag. **Default `Base branch` for every branch is the team's trunk (`main`/`develop`), not the previous feature branch** — the arrow diagram describes intended merge order, not git topology. Stack only when a branch genuinely cannot compile/test without uncommitted code from a predecessor; document the reason in the tracker's Notes column when you do. Each task in the per-branch checklist must be verifiable in CI or by a single command. Cite Spec `FR-*` / `NFR-*` / `TC-*` / `AC-*` on every non-trivial choice. Skip per-branch sub-sections that don't apply (a rollout branch usually has no new types). **Every branch's task checklist must contain two structural patterns:** (a) `T-N.C*` commit tasks that group implementation tasks into atomic commits — message format from §5 `Commits` (sourced from AGENTS.md); (b) closing `T-N.D*` DoD verification block enumerating each §6 DoD item as a discrete, runnable task. Never collapse either into a single line. **§12.1 *Scenario Traceability Matrix* is mandatory**: every Spec `S-NN` from §9 *and every enumerated variant `S-NNa`/`S-NNb`/…* gets a row with a test path and a `Level` from `unit / integration / contract / e2e / property` (multi-value rows allowed when warranted). Pick the level per row using the decision-tree in `references/implementation-plan-guidance.md` §12 — top-down: inter-service contract → property/invariant → real external systems → cross-module → user-visible flow → otherwise unit. **Do not declare a target pyramid ratio**; the shape of the suite falls out of per-row decisions. Tests embed the Spec ID via a tag convention recorded in §5 *Engineering rules* (Tests row); `T-N.D8` (scenarios + variants → tests), `T-N.D8b` (Variants-block structural presence via awk lint), `T-N.D9` (NFRs), and `T-N.D10` (TCs) verify coverage mechanically via `grep` / `awk` / `comm` (the `T-N.D8` regex is `S-[0-9]+[a-z]*` to catch variants; `T-N.D8b` greps every §9 `Scenario S-NN` heading for a following `Variants:` line or `Variants: none` declaration since `comm -23` cannot detect a missing block). Skipping §12.1 — *or filling it with rows that all say `unit`* — is the most common observed methodology failure: features pass unit tests but miss enumerated requirements and their boundary/failure/concurrency variants. **Required diagrams (per MD-24)**: §3 Mermaid architecture (C4 Component for agentic features; otherwise `flowchart` for structural shape or `sequenceDiagram` for behavioural shape); §7.1 Mermaid `flowchart`/`gitGraph` branch graph (replaces the legacy ASCII arrow diagram); §8.2 Mermaid `stateDiagram-v2` for expand-migrate-contract phases when migrations are present; §9.2.1 Mermaid `sequenceDiagram` when a new producer/consumer pair is introduced. ≤15 elements per diagram (precise unit per type — nodes for `flowchart`, components for C4 Component, messages for `sequenceDiagram`, states for `stateDiagram-v2`); ASCII art banned.

#### When drafting reveals a gap in an upstream document

If, while drafting the Plan, you realise the Spec is missing something
needed (e.g., an FR is too vague to map to a module, a TC is
unverifiable, a scenario is missing) — *stop*. Surface the gap to the
user, propose the upstream amendment, and wait for confirmation before
continuing. The same applies to Spec drafts that surface Concept Note
gaps. Do not silently invent the missing content downstream.

### Step 5 — Self-critique pass *(opt-in — prompt the user)*

Before saving, **ask the user** whether to run the rubric-based
self-critique:

> *"Want me to run the self-critique pass against the rubric? It
> scores the doc against the per-doc dimensions (Accuracy /
> Consistency / Completeness / Clarity / Methodology-invariants) and
> surfaces 🔴 Blocking / 🟡 Should-fix / 🔵 Suggestion findings. It's
> the same rubric an independent Step 7 critic would use, but run by
> the same model that authored the doc — so it catches the structural
> floor (vocabulary, missing sections, methodology-invariant
> violations) but misses the bias-shaped gaps (vague NFRs the author
> thinks are clear because they wrote them). Skip if you'll run an
> independent Step 7 pass next, or proceed if you want a structural
> check now. (y/n)"*

If the user **declines**: skip Step 5 entirely, proceed to Step 6
(Save). Record `Self-critique: skipped` in the Change-log row for
the audit trail.

If the user **accepts**: load `references/critic-rubric.md` and score
the doc against its **per-doc** half. Produce findings using the
rubric's *Findings format* and severity buckets. Resolve every 🔴
Blocking finding before saving in Step 6. 🟡 Should-fix findings
either get resolved or recorded in the doc's "Open questions" section
(lowercase "q" — matches the template heading; case-sensitive
automations and `grep` over the doc rely on this) with owner +
target stage. 🔵 Suggestions are optional. Record
`Self-critique: passed (N🔴 / N🟡 / N🔵)` in the Change-log row.

> **Honest framing.** Self-preference bias is documented (~10% on
> GPT-4, larger on capable models): the same model that wrote the doc
> will rate it more favourably than an independent reader would. Step 5
> catches the structural floor. It does **not** catch the bias-shaped
> gaps. Those are Step 7 territory. Don't conflate the two — and don't
> use a clean Step 5 result as a substitute for Step 7.

For derivation tasks, the rubric's **cross-doc** half also applies —
if the user accepts the self-critique, load it alongside the per-doc
half and score against both. Cross-doc findings cover decision
propagation, behaviour coverage, AC coverage, silent drift, and
reverse-derivability.

For derivation tasks specifically:

- **Concept Note → Spec.** Every Concept Note `D-*` should appear in the Spec — either as an inherited constraint in §3.3 (when it's a settled decision the Spec carries forward) or as a new `TC-*` in §4 (when it's a solution-space mandate the Spec encodes for the first time). Every Concept Note OPEN-Q targeting "Spec" should be either resolved in the Spec or carried forward into Spec §16.
- **Spec → Implementation Plan.** Every Spec `AC-*` must be mapped to a branch in §16 of the Plan, **with the `Test` column populated for each AC**. Every Spec `S-NN` must appear in Plan §12.1 *Scenario Traceability Matrix* with a runnable test path. The change's consequences must be enumerated in Plan §12.2 *Impact Traceability* as `IMP-*` rows — one per materially-affected scope, at feature granularity (`AC-53`). Every quantified Spec `NFR-*` must be mapped to a measurement test in Plan §12.8 (or §12.4) **and** to at least one `OBS-*` row in Plan §11. The test-tag convention required by Spec §11.5 must be recorded in Plan §5 *Engineering rules*, as must the `Supply-chain` token (lockfile path, or `none — <reason>`) that `AC-55` reads. Every Spec OPEN-Q targeting "Plan" must be resolved in the Plan or carried into Plan §15.1. The Plan must respect every `FR-*` / `NFR-*` / `TC-*` / `AC-*` (including `AC-50`/`AC-51`/`AC-52`/`AC-53`/`AC-54`/`AC-55` from §11.5) and is free to choose design patterns and module layout within those constraints.
- **Plan → Spec (back-derivation).** Reverse-engineer FRs from the Plan's per-branch behaviour, NFRs from Plan §10 (config), §11 (observability — each `OBS-*` typically hints at the NFR it binds to), §14 (risks — `R-*` often surfaces an implicit NFR or scenario). Reverse-engineer TCs from the Plan's library / vendor / architecture choices in §3.1 (TD-*) and §4 (module map) that look externally mandated — when in doubt, ask the user. **Reverse-engineer scenarios from Plan §12.1 *Scenario Traceability Matrix*** when present — each row is a behavioural scenario; populate Spec §9 with the corresponding `S-NN`. **Reverse-engineer expected impact / risk / observability obligations from §12.2 / §14 / §11** — if these are populated, infer §11.5 `AC-53`/`AC-54` test obligations from their existence. Flag every back-derived FR / NFR / TC / S `[INFERRED]` so the human reviewer can validate them.
- **Spec → Concept Note (back-derivation).** Reverse-engineer the problem statement, vision, alternatives, and decision rationale from the Spec's §14 (assumptions), §3.3 (inherited constraints), §4 (technical constraints), and any "why" prose in §1/§2. Flag invented motivation as `[INFERRED]`.

### Step 6 — Save and update cross-links

#### Default save paths

Confirm with the user before writing:

- `docs/{{feature-slug}}/{{FEATURE_NAME_SLUG}}_CONCEPT.md`
- `docs/{{feature-slug}}/{{FEATURE_NAME_SLUG}}_SPEC.md`
- `docs/{{feature-slug}}/{{FEATURE_NAME_SLUG}}_IMPLEMENTATION_PLAN.md`

`FEATURE_NAME_SLUG` is `SCREAMING_SNAKE_CASE`; the folder slug is
`kebab-case`. **Read `docs/` first** — if the project already has a
feature-folder convention, mirror it (naming, casing, sub-folders) and
use that instead of these defaults.

#### Cross-link procedure

After saving, update the header block of every related document in the
same feature folder so the cross-links are accurate:

1. List the files in `docs/{{feature-slug}}/` (or the project's
   equivalent).
2. For each file matching the methodology naming pattern
   (`*_CONCEPT.md`, `*_SPEC.md`, `*_IMPLEMENTATION_PLAN.md`), read its
   header block.
3. Update the `Concept note:` / `Spec:` / `Implementation plan:` lines
   to point to the correct sibling files (or `*not yet written*` when
   the sibling does not exist).
4. Show the user the diffs before writing, unless the user has said
   "just save the cross-link updates".

#### Change log — fresh docs and iterations

Every save adds a row to the doc's Change log (§18 Concept Note /
§18 Spec / §17 Plan). For a **fresh** doc, seed the *initial* row at
save time — without it, Step 5's `Self-critique: skipped|passed` audit
trail has nowhere to land. For an **iteration**, append a new row.

The Change-log tables in all three templates have three columns:
`Date | Author | Change`. Each row carries:

- **Date** — today's date in `YYYY-MM-DD` form (resolve "today" / "yesterday" / similar relative references to the absolute date the skill is currently running; use the date the agent has access to from its environment, not a hard-coded example)
- **Author** — the author name (ask the user if not obvious)
- **Change** — a one-line summary of the change (`Initial draft.` for fresh docs) **with the Step 5 self-critique result appended as a trailing clause**: `Initial draft. Self-critique: skipped (first-run baseline).` or `Added FR-007; resolved OPEN-Q-03. Self-critique: passed (0🔴 / 2🟡 / 1🔵).` — the clause is always present, never omitted, even for skipped runs, so the audit trail stays continuous without requiring a fourth column in any template.

#### Suggest Step 7 follow-up

After confirming the save, ask the user:

> *"Saved. Want me to set you up for an independent Step 7 critique?
> That requires invoking the skill in a separate session running a
> **different model family** from this one (the whole point — a same-model
> critique collapses to a strong self-review per the self-preference
> bias literature). Skip if you'll lean on PR review for cross-model
> independence; opt in if this doc is high-stakes enough to want a
> rubric-based independent pass. (y/n)"*

If yes, give the user the exact invocation hint (e.g. *"in a new
Claude Code session with `/model` switched to a different family —
Opus → Sonnet at minimum, Opus → GPT/Gemini for high-stakes Specs —
ask the skill to 'critique `{{path}}` against the rubric'"*). Do not
attempt to run Step 7 yourself in the same session — that defeats the
cross-model guarantee.

If no, end the authoring run. Step 7 can be re-invoked later from a
different session.

### Step 7 — Critique pass *(opt-in, cross-model, standalone invocation)*

Step 7 runs only when invoked explicitly — either at the user's
request after Step 6, or as a fresh skill invocation in critique mode
(Step 1 routes here). It runs the **same** per-doc rubric in
`references/critic-rubric.md` as Step 5, but in a different invocation
**with a different model from the author's**. Self-preference bias
makes a same-model critique collapse into a strong self-review, not
an independent one — the whole point of Step 7 is to break that loop.

#### Step 7.0 — Confirm model independence (gate)

Before loading any document, ask the user **two questions** and gate
on the answers — the only paths forward after the gate are (a) abort
and re-invoke in a different-family session (default and recommended),
or (b) the user explicitly opts in to continue knowing the output will
be labelled as a Step-5-equivalent self-review:

1. **What model is running this critique pass?** (Family + size, e.g.
   `claude-sonnet-4-6`, `gpt-4o-mini`, `gemini-2.5-pro`,
   `claude-haiku-4-5`.) If the user doesn't know, instruct them to
   check `/config` (Claude Code) or their runtime equivalent.
2. **What model authored the doc being critiqued?** (Same format.)
   The doc's header / change log may record this; check first, ask if
   absent.

Compare:

- **Same model family** (e.g. both `claude-opus-4-x`) → **STOP.** Tell
  the user: *"This is a same-family critique, which collapses to a
  strong self-review. Step 5 already does that. Either (a) abort and
  re-invoke this skill in a session running a different model family,
  or (b) explicitly continue knowing the report will be labelled as a
  self-equivalent pass and the cross-model gap stays open."* Wait for
  the user's choice. Default to (a).
- **Different family, same provider** (e.g. `claude-opus-4-x` author,
  `claude-haiku-4-5` critic) → **PROCEED with caveat.** Provider mix
  is a proxy for error-profile diversity; same-provider critics
  catch most bias-shaped findings but may share residual training-data
  bias. Note this in the report header.
- **Different provider** (e.g. `claude-*` author, `gpt-*` / `gemini-*`
  critic) → **PROCEED.** Strongest independence. Note in header.

The user's answers go into the critique report's header verbatim —
this is the audit trail that proves cross-model independence was
actually achieved.

#### Step 7.1 — Pick the mode

Ask whether this is a **per-doc** critique (one document) or a
**cross-doc** critique (a pair or the full Concept ↔ Spec ↔ Plan
triple). The rubric file is divided into per-doc and cross-doc halves;
load only the half that applies. Don't try to run both modes in one
pass — keeps context tight and findings interpretable.

#### Step 7.2 — Load the rubric + inputs

- Read `references/critic-rubric.md` end-to-end.
- Read the document(s) under critique end-to-end. For cross-doc mode,
  read every sibling in scope before producing any finding (the
  rubric's cross-doc dimensions require holding all docs in context
  at once — partial reads will miss decision propagation gaps).

#### Step 7.3 — Score against the rubric

Walk each dimension in order (per-doc: Accuracy → Consistency →
Completeness → Clarity → Methodology-invariants; cross-doc: Decision
propagation → Behaviour coverage → AC coverage → No silent drift →
Reverse-derivability). Produce findings using the rubric's *Findings
format* — one block per finding with Where / What / Why / Evidence /
Confidence / Severity / Suggested fix.

Methodology-invariant violations (rubric Dim 5) are almost always 🔴
Blocking — these are the gates the methodology exists to enforce.

#### Step 7.4 — Produce the critique report

Write a single Markdown file at the path the user specifies (default:
`docs/{{feature-slug}}/{{FEATURE_NAME_SLUG}}_CRITIQUE_{{YYYY-MM-DD}}_{{critic-model-short}}.md`)
using the *Critique report shape* in the rubric. The header carries
the critic and author model identifiers from Step 7.0 — non-negotiable;
that's the audit trail.

The critique report is **read-only output**: the critic does not
rewrite the source document. The author decides what to act on. This
preserves the author's authority and avoids the loop where the critic
"fixes" something the author intended.

#### Step 7.5 — Recommend a verdict

The Verdict goes at the **top of the report** (matches the rubric's
*Critique report shape* — right after the header and before the
findings sections; see `references/critic-rubric.md`). One paragraph,
deterministically derived from severity counts: APPROVED / COMMENT /
CHANGES REQUESTED, based on:

- **CHANGES REQUESTED** if any 🔴 Blocking findings.
- **COMMENT** if only 🟡 Should-fix or 🔵 Suggestion findings.
- **APPROVED** if none.

If the model-comparison gate in Step 7.0 yielded *same family*, append
the caveat: *"Self-equivalent critique — cross-model gap still open."*

## Operating principles

- **Templates are normative.** Do not invent new sections or reorder existing ones unless the user explicitly approves. Section IDs and headings are the agent-readable backbone.
- **Cite, don't paraphrase.** When pulling content from an upstream doc, cite the source section (`Concept Note §4.5`, `Spec FR-006`) so the cross-references survive.
- **Surface unknowns.** `[OPEN-Q-N]` and `[INFERRED]` markers are first-class outputs. A doc with honest unknowns beats a doc with confident fabrication.
- **Surface upstream gaps.** If the source document is missing what you need, stop and propose an upstream amendment. Do not silently invent content downstream.
- **One document per invocation.** If the user asks for two or three at once, do them sequentially with a checkpoint between each — not in parallel.
- **Long-running derivation runs as a Workflow.** When the user wants the chain produced autonomously (left running unattended), materialize it as a Workflow: one phase per document in dependency order, each phase's drafting agent reading the templates/guidance from this skill directory, followed by mechanical consistency-pass phases (self + cross) and an optional 3P-visualization phase. The interactive checkpoint discipline is preserved by the workflow journal — each phase's output is reviewable there. Extension artefacts (Parity/Cutover Plans from the `staged-migration-doc` skill) interleave per that skill's rule 13 ordering.
- **Match the existing project's conventions.** If `docs/` already contains feature folders, mirror their layout, naming, and cross-link style.
- **DoD items are gating tasks, not advisory checklists.** When drafting an Implementation Plan, the DoD in §6 must be replicated as concrete `T-N.D*` tasks at the bottom of every branch's task checklist (one task per DoD item, each with a runnable verification command). When the user later runs the Plan, those tasks are executed like any other — not skipped, not collapsed, not deferred. **If you fan implementation tasks to subagents (for `[P]` parallelism), pass each subagent the DoD tasks too** — subagents do not see §6 unless you give it to them. Where possible, recommend that the user lift DoD checks into CI / pre-commit / PR-template gates so they're enforced at merge, not just by agent discipline.
- **Commits are gating tasks too.** Same pattern: implementation tasks in §7.x.9 are grouped into atomic, logical commits with explicit `T-N.C*` tasks between groups. Without these, agents batch every change into a single closing commit, which destroys `git bisect`, makes review hard, and breaks back-derivation. Commit-message format is taken from §5 `Commits` row, which itself is restated from the project's AGENTS.md (or equivalent). If AGENTS.md is silent on commits, ask the user once, record the answer in AGENTS.md *and* §5, then use it consistently. Subagents must receive the relevant `T-N.C*` tasks alongside implementation tasks.
- **Test & traceability obligations are gating tasks too.** Same pattern: §11.5 *Test & traceability obligations* in the Spec declares the meta-ACs (`AC-50` scenarios → tests, `AC-51` NFRs → measurement tests, `AC-52` TCs → §12 evidence, `AC-53` impact enumerated per affected scope → `IMP-*`, `AC-54` quantified NFRs → `OBS-*`, `AC-55` lockfile → clean supply-chain scan); the Plan enforces each one mechanically — §12.1 *Scenario Traceability Matrix* (`AC-50`), §12.4/§12.8 (`AC-51`), §11.3 + §12 (`AC-52`), §12.2 *Impact Traceability* (`AC-53`), §11 *Observability* (`AC-54`), §5 `Supply-chain` token + §14 `R-*` waivers (`AC-55`); tests bind to Spec IDs via a tag convention recorded in Plan §5 *Engineering rules* (`test_S_04_…`, `@pytest.mark.scenario("S-04")`, `it("S-04: …")`, etc.); DoD `T-N.D8` / `T-N.D9` / `T-N.D10` plus the appended `T-N.D15` (`AC-53`), `T-N.D16` (`AC-54`) and `T-N.D20` (`AC-55`) verify each gate mechanically via `grep` + `comm` (and, for `T-N.D20`, a scanner exit code). `T-N.D10` accepts both forms of TC evidence (runnable test path *or* reviewer / review-checklist citation) because TCs are heterogeneous — some are CI-checkable (vendor lock, lint rules), others are review-only (architectural standards). Without this layer, the methodology's most common observed failure is features that pass unit tests but miss enumerated requirements, ship without an observability signal for their NFRs, or surprise downstream consumers because no impact was enumerated. Treat the matrix and the tag-convention row as non-negotiable in every Plan.
- **Observability, risk, and impact are first-class ID'd entities.** Plan §11 *Observability* uses `OBS-NN` rows with explicit *Binds to* references (typically an `NFR-*`); §14 *Risks* uses `R-NN` rows with explicit `T-N.*` mitigation-task references and `OBS-*` detection-signal references where available; §12.2 *Impact Traceability* uses `IMP-NN` rows with a closed-vocabulary `scope` (`code` / `system` / `business` / `external`). These three sections form the operational layer of the Plan and must not regress to free-form prose. The greenfield case does not exempt them — `IMP-*` rows shift from retroactive ("we broke X") to forward-looking ("we're committing to API shape Y for future consumers"), but the gate stays mandatory.
- **Consistency passes are gating tasks too.** Before saving any document, run the two passes in `references/review-passes.md`: self-consistency (within the doc — every referenced ID resolves to a definition, OPEN-Q book-keeping, no orphan sections) and cross-consistency (between docs — no dangling references to sibling docs). The Plan gates them as `T-N.D18` and `T-N.D19`. Both are mechanical (`grep` + `comm`); do not substitute prose review. They enforce *referential integrity*, **not** gap-free numbering — the methodology's own templates use non-contiguous IDs deliberately, so a contiguity check would be wrong. The cost of skipping them is *dangling references* — typos, stale IDs from a renumbering, OPEN-Qs resolved in one doc but still listed in another's handoff — which silently corrupt the Concept → Spec → Plan → code chain. When iterating on an existing draft (Step 3's "iterating" path) these passes are especially load-bearing, because reference drift is the dominant failure mode there.
- **Diagrams follow a closed vocabulary (MD-24).** Diagrams are Mermaid text only — no PNG / SVG / external image links; no ASCII art. One diagram type per section per doc; the matrix is in MD-24 (Concept §5.1 `C4Context`, Concept §9.4 `flowchart`, Spec §9 `sequenceDiagram` / `stateDiagram-v2`, Spec §10.1.1 `erDiagram`, Plan §3 C4 Component (agentic) / `flowchart` (structural) / `sequenceDiagram` (behavioural), Plan §7.1 `flowchart`/`gitGraph`, Plan §8.2 `stateDiagram-v2`, Plan §9.2.1 `sequenceDiagram`). **Required** diagrams: Concept §5.1 `C4Context` when the feature crosses ≥2 system boundaries; Spec §10.1.1 ER when ≥1 new entity; Plan §3 architecture; Plan §7.1 branch graph; Plan §8.2 migration state (if migrations present); Plan §9.2.1 cross-service sequence (if new producer/consumer pair). Everything else is optional. ≤15 elements per diagram (precise unit per type — nodes for `flowchart`, entities for `erDiagram`, messages for `sequenceDiagram`, states for `stateDiagram-v2`) — split if larger (methodology-imposed ceiling informed by SADU's reported monotonic accuracy decline with diagram size). **Banned**: `activityDiagram` (worst comprehension, overlaps `sequence`/`state`); Container-only views (C4 L2) for agentic features; binary images. Prose stays canonical when diagram and prose disagree — diagrams are visual indexes, not the contract.
- **Critique is opt-in, separate, and the critic must be a different model (MD-23).** Both Step 5 (self-critique) and Step 7 (independent critique) are **opt-in** — prompt the user at the start of Step 5 and at the end of Step 6; do not run silently. `references/critic-rubric.md` is the single rubric driving both passes. The rubric is the same; the *invocation context* is different. Step 5 self-pass (if accepted) catches the structural floor — vocabulary, missing sections, methodology-invariant violations the rubric explicitly names by `MD-NN` ID. Step 7 cross-model pass catches the bias-shaped gaps Step 5 misses — vague NFRs the author thinks are clear because *they* wrote them; assumptions the author overloaded. Self-preference bias in 2026 LLM-as-judge research is large (~10% on GPT-4; up to +90% on ArenaHard) and grows with model capability, so Step 7 with the **same model family** as the author collapses to a strong self-review, not an independent critique. **Step 7.0 gates this**: ask the user for both the critic model and the author model before loading any content; if same family, default to abort and re-invoke from a different-family session. Record both models in the critique report header verbatim — that's the audit trail proving cross-model independence was actually achieved. When the user skips Step 5, record `Self-critique: skipped` in the Change-log row. When they skip the Step 7 follow-up, the authoring run ends cleanly without a Step 7 artefact — the absence is the audit signal. Provider mix (Claude → GPT / Gemini) strengthens independence but is a *proxy* for error-profile diversity, not the goal — same-provider, different-family critics (e.g. Opus author, Sonnet critic) are an acceptable middle tier. Do not score the doc (no numeric ratings — calibration drift makes them meaningless); produce findings + severity buckets (🔴 Blocking / 🟡 Should fix / 🔵 Suggestion) per the rubric's *Findings format*.
- **Trust but verify (MD-26).** Every external or internal claim in any of the three docs is either verified against a primary source before citation, or tagged `[UNVERIFIED — <one-line reason>]`. `[UNVERIFIED]` is parallel to but distinct from MD-10's `[INFERRED]` (back-derived from other docs, not primary-source verified) and `[OPEN-Q-N]` (unknown, deferred to a downstream stage) — same marker family, different semantic category. See `references/verification-protocol.md` for the per-claim-class enumeration (arXiv/DOI, paper findings, CLI flags, syntax forms, peer-framework quotes, standard-clause text, `<repo>/path:LN`, cross-doc references), the legitimate-vs-illegitimate reason list, and the empirical grounding (LLM self-preference-bias research — LLMs cannot self-verify reliably at any granularity, so external verification is the only reliable pattern). If unsure whether a claim needs verification, err toward tagging it — the marker is cheap; the fabrication cost is high.
- **Security posture (MD-31).** Security is a design consideration in the trifecta, scoped to the software being specified — not to the agent running the methodology. Concept §5.2 declares the posture in three lines (feature exposure / data sensitivity / deployment surface), and those lines select which CWE Top 25 categories the Spec's §4.5 *Security constraints* must address. Spec §4.5 turns each applicable category into a `TC-*` row citing the CWE verbatim (`defends CWE-XX <name>`) or an explicit ruling (`CWE-XX — not applicable; §5.2 rules out …`); Spec §11.5 gains meta-`AC-55` for supply-chain integrity. Plan `T-N.D20` runs the CVE lockfile audit at DoD time (`osv-scanner --lockfile=…` or a language-native equivalent — the scanner **exits non-zero on any advisory**, so the gate fails on any finding and severity judgement lives in the waiver: accepted advisories become `R-*` rows in Plan §14 with a rationale; a branch with no lockfile declares `Supply-chain: none — <reason>` in Plan §5 and passes vacuously; offline environments add `[UNVERIFIED — offline; advisory DB unreachable]` to §15.1 to grade 🟡 not 🔴). Structural floor, not ceiling — threat modeling / secure design patterns / penetration testing / SAST / DAST / secret scanning / AI-agent hardening all remain legitimate additions above the floor per feature complexity, declared in Concept §5.2 or as additional §4.5 TCs. See `references/security-protocol.md` for the retrieve-live-at-runtime discipline (no security-standard snapshots embedded in the plugin — the CWE Top 25, ASVS release, SLSA level ladder, and CVE advisory database are all fetched live at authoring / review / gate-run time from their canonical URLs), the outside-Top-25 escape (mirrors MD-27's `Custom arc: <N> — <reason>` shape), and the full rubric scoring buckets (`critic-rubric.md` Dim 5 row).
