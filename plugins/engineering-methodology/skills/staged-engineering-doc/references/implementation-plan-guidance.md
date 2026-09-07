# Implementation Plan authoring guidance

Use alongside `templates/IMPLEMENTATION_PLAN_TEMPLATE.md`. This file gives
section-by-section advice; it is **not** the template itself.

Two cross-cutting reference files apply to every doc type:

- `references/verification-protocol.md` — the MD-26 *Trust but verify*
  discipline: what to verify against per claim class, the
  `[UNVERIFIED — <reason>]` marker, how it differs from `[INFERRED]`
  and `[OPEN-Q-N]`.
- `references/review-passes.md` — the MD-21 two-pass consistency check
  (self-consistency, cross-consistency) run before saving.

## Tone & shape

- The Plan is the **agent-executable contract**. Imagine handing it to a
  competent contractor (or AI agent) who has never seen the codebase and
  has 5 working days. Could they ship without asking another question?
  If not, the Plan is not specific enough.
- The Plan is **what + where + in what order**, not the **why** (Concept
  Note) or the **what + how it should behave** (Spec).
- Length scales with the **branch arc** (§7.0), not with a single number.
  The template's own scaffolding is ~8,200 words before a placeholder is
  filled, and §7.2's nine subsections plus the closing `T-N.D1`–`T-N.D20`
  block are replicated **per branch** — so the arc, not the feature's
  ambition, is what sets the size:

  | Arc | Band |
  |---|---|
  | `refactor-1`, `single-branch` | 8,000–12,000 words |
  | `two-branch-backend-ui` | 10,000–16,000 words |
  | `three-branch-scaffold-core-rollout` | 12,000–19,000 words |
  | `five-branch-default`, `migration-5` | 15,000–25,000 words |

  Beyond the band for the declared arc, either the feature should be split
  or the arc was chosen too large. Check the arc first: an oversized Plan is
  more often a five-branch arc on a two-branch feature than a feature that
  needs splitting.

## What an agent actually needs

In priority order:

1. **Exact file paths.** Repo-rooted, never "the auth module".
   Glob patterns are okay for tests.
2. **Exact symbol names.** The new class, function, type, table, column,
   flag. Agents hallucinate names left underspecified.
3. **Function signatures, not bodies.** Prescribe inputs/outputs and side
   effects; let the agent author the body.
4. **Edit shape per file.** One of: `create`, `add function X`,
   `modify function Y to also do Z`, `delete`. Avoid "update X as needed".
5. **Per-task acceptance check.** A test that passes, a command that exits
   0, an endpoint that returns N.
6. **Dependency arrows.** Task B blocked-by Task A. `[P]` markers on
   parallelisable tasks so subagents can fan out.
7. **Spec anchors.** Every non-trivial choice cites the Spec section
   (`FR-005`, `NFR-003`, `TC-010`, `AC-10`, `S-12`) it satisfies.

What to **avoid** putting in the Plan:

- Full code blocks. Bloats context, traps the agent into stale
  implementations. Use signatures + invariants + tests.
- Open-ended "considerations". Either turn into a TD-* decision or move
  to §15 open questions.
- Re-derivations of Spec content. Cite, don't restate.

## Section-by-section tips

### §3 Architecture overview

One Mermaid diagram is **required** here (per MD-24 — ASCII art and
binary images are banned). Pick the type that fits the feature shape:

- **Agentic feature** (multiple specialised agents, orchestration, tool
  registry, decision loops): use **C4 Component** (`C4Component` or an
  annotated `flowchart`). Our methodology judgement is that
  Container-only views (C4 L2) under-represent multi-agent orchestration
  — go straight to Component (L3). (arXiv 2603.15021 itself retains
  L2 and calls to refine it; the skip-L2 stance is ours, not the
  paper's.) Annotate edges with method names / message labels
  (behavioural augmentation, arXiv 2506.00788, lifts downstream
  method generation).
- **Behavioural feature with few new modules** (a new endpoint that
  fans out to existing services): use **`sequenceDiagram`** showing
  the call path and the actors involved.
- **Structural feature with new modules** (a new service, library, or
  worker): use **`flowchart`** at component granularity, annotated
  with the entry-point method names.

≤15 elements per diagram (components for C4 Component; nodes for
`flowchart`; messages for `sequenceDiagram`). If the architecture is
genuinely larger, split into two diagrams (e.g. one for the write path,
one for the read path) — single 30-element diagrams exceed the
methodology's ≤15-element ceiling, and SADU's reported monotonic
accuracy decline with diagram size makes them unlikely to remain
comprehensible to current SOTA models (no specific element-count
threshold is claimed by the paper; ≤15 is our calibration).

### §3.1 Key design decisions

Atomic, ID'd `TD-*` (technical decisions). These are *new* decisions made
at Plan time, beyond the Concept Note's `D-*`. Each must cite a Spec
reference — if a TD does not satisfy any Spec requirement, it probably
does not belong in this feature.

### §4 Module map

The single most useful section for an agent. Include modules that are
**adjacent but unchanged** with status `untouched` — agents need to know
what they are *not* allowed to modify, not just what they should change.

### §5 Engineering rules / project conventions reference

Restate (don't link) the project's `AGENTS.md` / `CONTRIBUTING` /
style-guide rules that this Plan must comply with. Linking forces the
agent to do an extra fetch and risks the agent missing the file. Inline
the rules.

The `Commits` row is load-bearing: it dictates the format of every
`T-N.C*` task in §7.x.9. Capture whatever the project's AGENTS.md says
about commit style — Conventional Commits (`type(scope): subject`),
Angular, prefix-based, free-form, etc. If AGENTS.md is silent on
commits, **ask the user once** for the project's preferred style,
record the answer in AGENTS.md (so the next Plan inherits it), and
restate it here. Do not invent a style.

### §6 Definition of Done

Every checklist item must be **mechanically verifiable**. "Code is clean"
is not a check; "ruff passes" is. "Tests are good" is not; "all tests in
`tests/unit/x/` pass and coverage on `path/to/module` ≥ 80%" is.

**The most important authoring move for §6: replicate every
*non-externalised* DoD item as a discrete `T-N.D*` task at the close of
*each* branch's §7.x.9 task checklist.** Externalised items (CI-enforced,
pre-commit, PR-template gated — see *"Where possible, externalise the
gates"* below) get a brief `T-N.D*` task that *references* the external
gate rather than re-implementing it, so the agent still checkboxes the
verification step but doesn't re-run logic the platform already runs.

The §6 list alone is not enough — agents executing per-branch task
lists rarely re-load §6 mid-branch, and subagents fanning out from
`[P]` markers never see §6 at all. The fix is structural: turn DoD
items into specific, runnable, branch-local tasks the agent ticks off
just like any other.

The Branch 1 §7.2.9 in the template is the canonical example. Mirror
it for every branch — adjusted for that branch's command set (e.g.
test paths, lint scope). Don't collapse the block into a single "ensure
DoD is satisfied" line; that's exactly the pattern that fails.

**Where possible, externalise the gates.** A DoD item enforced by CI
(`pytest --cov=path --cov-fail-under=80`), a pre-commit hook
(`ruff check`), or a PR template (mandatory cross-ref section) is
gated at merge time and survives agent inattention. The Plan's DoD
should *reference* those gates rather than re-implement them. Items
that can't be externalised stay as `T-N.D*` tasks.

### §7 Branch / phase plan

The structure of the Plan that makes it agent-executable.

#### §7.0 Branch sizing — closed arc vocabulary + decision tree (MD-27)

**The number of branches in §7 is not fixed.** Per MD-27, Plans pick
one arc from a **closed vocabulary** based on Spec signals. The §7.1
tracker rows and §7.1 branch-graph shape derive from that choice. This
replaces the pre-MD-27 default of *always* using the five-branch
behavioural arc regardless of feature size — the observed pain being
that small features shipped with 5 PRs of overhead they didn't need.

**Closed arc vocabulary** (each carries a name that agents cite from
`Arc:` declarations — the same discipline as MD-22's `Variants:` kind
tags):

| Arc | Branches | Shape | When to pick |
|---|---|---|---|
| `refactor-1` | 1 | `{{prefix}}/refactor` | Refactor-only. 0 new behavioural FRs. No user-visible change. |
| `single-branch` | 1 | `{{prefix}}/feature` | Small behavioural feature. ≤3 FRs. Single-service. No migration. |
| `two-branch-backend-ui` | 2 | `{{prefix}}/backend` → `{{prefix}}/ui` | Backend + user-facing UI both touched. Naturally partitions reviewer scope. |
| `three-branch-scaffold-core-rollout` | 3 | `{{prefix}}/scaffolding` → `{{prefix}}/core` → `{{prefix}}/rollout` | Mid-complexity, or flag-gated with a progressive-rollout NFR (canary / percentage / kill-switch) but no cross-service change. |
| `five-branch-default` | 5 | `{{prefix}}/scaffolding` → `{{prefix}}/core-write` → `{{prefix}}/core-read` → `{{prefix}}/edge-cases` → `{{prefix}}/rollout` | Behavioural feature with a cross-service producer/consumer pair. The pre-MD-27 default; still correct for genuinely large behavioural features. |
| `migration-5` | 5 | `{{prefix}}/expand` → `{{prefix}}/dual-write` → `{{prefix}}/backfill` → `{{prefix}}/switch-reads` → `{{prefix}}/contract` | Data migration. Each phase has a distinct failure mode and rollback surface — collapsing phases means one PR carries two failure modes and the blast radius stops being partitioned. |

**Decision tree** (top-down, first-match-wins — check the signals
against the Spec in order):

1. **Refactor-only** — Spec §7 has 0 new behavioural FRs; the change is
   purely code-organisation, dependency-untangling, or naming.
   Signal: FR-count regex from the recap below returns 0.
   → `refactor-1`
2. **Migration present** — Spec §10 (Data model) mentions a schema
   change, or Plan §8 (Data model & migrations) will be populated.
   Signal: schema-change wording in Spec §10 / Plan §8 (see recap below
   for what to scan for).
   → `migration-5`
3. **Cross-service producer/consumer pair** — Spec §9.2 introduces a
   new producer/consumer pair (event publish/consume, RPC, queue
   contract), or Plan §9.2.1 is required per MD-24.
   → `five-branch-default`
4. **Progressive-rollout NFR** — Spec §8 carries a quantified NFR
   asserting safe rollout beyond simple flag-off/flag-on (canary,
   percentage-based enable, kill-switch verification).
   → `three-branch-scaffold-core-rollout`
5. **Backend + user-facing UI both touched** — Spec §7 has both
   API-shaped FRs and UI-shaped FRs (user-facing surface, not ops
   tooling like admin CLIs).
   → `two-branch-backend-ui`
6. **Small single-service feature** — ≤3 FRs, no migration, no
   cross-service edges.
   → `single-branch`
7. **Fallthrough** — mid-complexity feature that hit none of the above.
   → `three-branch-scaffold-core-rollout`

**Escape valve — `Custom arc: <N> — <reason>`.** If none of the six
named arcs fit, use the escape declaration. Legitimate reasons include
risk-zone overrides (auth / payments / PII wanting extra safety stages
even for a single-service feature), unusual rollout topology
(feature-flag experiment with A/B/C split needing its own branch), or
migration variants (columns-only expansion that doesn't need dual-write
+ backfill). The rubric grades `Custom arc: N — didn't feel like it`
🟡 — the reason must actually explain why no named arc fits.

**Per-arc walk-throughs** (tracker rows + Mermaid `flowchart LR` graph
you'd substitute into the template's §7.1):

*`refactor-1`* — single branch, no flag needed:
```
| # | Git branch | Base branch | Status | PR | Tests | Notes |
| 1 | {{prefix}}/refactor | {{trunk}} | Not started | — | — | Refactor-only per §7.0 |
```
Graph: `trunk --> Refactor` (2 nodes).

*`single-branch`* — single branch, flag gates the new behaviour:
```
| 1 | {{prefix}}/feature | {{trunk}} | Not started | — | — | Small feature per §7.0 |
```
Graph: `trunk --> Feature`.

*`two-branch-backend-ui`* — backend ships dark, UI lights it up:
```
| 1 | {{prefix}}/backend | {{trunk}} | Not started | — | — | API + service layer |
| 2 | {{prefix}}/ui       | {{trunk}} | Not started | — | — | UI consumes backend |
```
Graph: `trunk --> Backend --> UI` (3 nodes; `trunk` dotted to `UI` per MD-12).

*`three-branch-scaffold-core-rollout`* — safe first PR + guts + progressive enable:
```
| 1 | {{prefix}}/scaffolding | {{trunk}} | Not started | — | — | Flag wired, off |
| 2 | {{prefix}}/core        | {{trunk}} | Not started | — | — | Implementation behind flag |
| 3 | {{prefix}}/rollout     | {{trunk}} | Not started | — | — | Progressive enable, kill-switch tests |
```
Graph: 4-node line `trunk --> Scaffolding --> Core --> Rollout`.

*`five-branch-default`* — the pre-MD-27 template default, kept for
large behavioural features with cross-service coupling:
```
| 1 | {{prefix}}/scaffolding | {{trunk}} | Not started | — | — | Flag wired, off |
| 2 | {{prefix}}/core-write  | {{trunk}} | Not started | — | — | Producer side |
| 3 | {{prefix}}/core-read   | {{trunk}} | Not started | — | — | Consumer side |
| 4 | {{prefix}}/edge-cases  | {{trunk}} | Not started | — | — | Failure modes, retries, ordering |
| 5 | {{prefix}}/rollout     | {{trunk}} | Not started | — | — | Progressive enable |
```
Graph: 6-node line. This is the template's default scaffolding in
§7.2..§7.6.

*`migration-5`* — expand-migrate-contract, one phase per branch:
```
| 1 | {{prefix}}/expand        | {{trunk}} | Not started | — | — | New columns nullable, indexes online |
| 2 | {{prefix}}/dual-write    | {{trunk}} | Not started | — | — | Old + new writes; new column shadow-populated |
| 3 | {{prefix}}/backfill      | {{trunk}} | Not started | — | — | Idempotent, resumable backfill for historical rows |
| 4 | {{prefix}}/switch-reads  | {{trunk}} | Not started | — | — | Reads switch to new column behind flag |
| 5 | {{prefix}}/contract      | {{trunk}} | Not started | — | — | Drop old column + old write path after verification window |
```
Graph: 6-node line. Ships with the required §8.2 `stateDiagram-v2` per
MD-24.

**Signal detection recap** (grep + judgement mix — this is why MD-27
is structural + rubric, not mechanical):

| Signal | Detection method | Reliability |
|---|---|---|
| Refactor-only (0 new behavioural FRs) | `grep -cE '^\s*[-\|>* ]*\**\s*FR-[0-9]+' {{path/to/SPEC.md}}` returns 0. The regex counts FR **definitions** — left-anchored to a line beginning with a bullet (`- **FR-001** — …`, the SPEC_TEMPLATE default), a table cell (`\| FR-001 \|`), or a quote (`> FR-001`). Same ID-definition idiom as `references/review-passes.md` L40-42. Bold-in-prose *mentions* of an FR elsewhere in the doc are deliberately not counted — they're references, not definitions | Mechanical |
| Migration | Read Spec §10 / Plan §8 for schema-change wording (e.g. `expand`, `backfill`, `new column`, `ALTER TABLE`, an `erDiagram` introducing new entities per MD-24, or a populated §8.2 `stateDiagram-v2`) — prose signal, not a single regex | Prose |
| Cross-service producer/consumer | Spec §9.2 populated with a new producer/consumer pair OR Plan §9.2.1 `sequenceDiagram` required per MD-24 | Mostly mechanical |
| Progressive-rollout NFR | Read Spec §8 NFRs for canary / percentage / kill-switch phrasing that goes beyond simple flag-off/flag-on | Judgement |
| Backend + user-facing UI both touched | Read Spec §7 FR shapes — endpoint/response FRs alongside screen/action FRs (excluding ops CLIs like admin tools) | Judgement |
| ≤3 FRs, single-service | Same FR-count regex as row 1 returns a value between 1 and 3, AND Spec §9.2 has no new producer/consumer entries | Mechanical |

The judgement signals are why the rubric grades arc-vs-signal mismatch
🟡 not 🔴 — the author's read of the Spec's rollout NFR or UI surface
is defensible in ways a shell script can't verify. Missing declaration
(no `Arc:` or `Custom arc:` line at all) is still 🔴 because that's
structural.

> **Regex form matters.** The FR-count regex above is deliberately
> tolerant to *bullet, table, bold-in-prose, and quote* forms so it
> keeps working across project conventions — matching the idiom already
> used in `references/review-passes.md`. Substituting a shape-specific
> pattern like `^\| FR-` (table-only) would return 0 on any Spec that
> uses the SPEC_TEMPLATE's default bullet layout and silently
> mis-classify real work as refactor-only. Same MD-25 *"cite what
> actually exists"* + MD-26 *"trust but verify"* discipline the
> methodology applies to citations, applied to detection commands.

#### Branching topology — base each branch off trunk, not its predecessor

**Default:** every branch in the plan is based off the team's trunk
(`main` / `develop`). The feature flag keeps each branch safe to merge in
isolation, so the next branch can be cut from trunk after the previous
one merges — no stacking required.

The arrow diagrams above (and in §7.1 of the plan) describe **intended
merge order**, not the git-level base of each branch. Don't conflate
them. A common authoring mistake — and one the example doc that
inspired this template fell into — is to set "Base branch" in the
tracker to the previous feature branch. That bakes in a stacked-branch
topology with cascading rebases and discourages each branch from being
genuinely independently mergeable, which is the whole point of the
flag-gated arc.

**When stacking is justified:**

- Branch N genuinely cannot compile, type-check, or be tested without
  uncommitted code from Branch N-1, and the prior branch is *not yet*
  safe to merge.
- This is usually a smell. Ask: why isn't Branch N-1 mergeable yet? If
  the answer is "the flag isn't wired yet" or "tests aren't ready",
  fix that and merge Branch N-1 first.

**When you do stack, document it.** Override the `Base branch` cell in
the tracker, and put the reason in `Notes` (e.g. "stacked on Branch 2
because the API handler needs the new types not yet on trunk"). That
way a reviewer can challenge the choice instead of inheriting it
silently.

**Rule of thumb:** if the team's trunk-merge cadence is faster than the
plan's branch cadence, never stack. If the trunk-merge cadence is
slower (multi-day reviews), stacking *may* be justified for the very
next branch, but never for branches further out — the rebase pain
compounds.

#### Per-branch sub-structure

Mirror the §7.2 sub-structure (`.1` Design decisions, `.2` New types, `.3`
Constants, `.4` Config, `.5` Interfaces, `.6` Tests, `.7` Verification,
`.8` Files inventory, `.9` Task checklist) for **every** branch. Repeat
the pattern; do not consolidate. Predictable structure is what lets an
agent navigate by section number.

#### Task checklist conventions

- Flat, ordered, top-to-bottom executable.
- One file or one symbol per task; never "update everything".
- `[P]` after the task ID marks tasks parallelisable with the previous one
  (no shared file, no shared state).
- Every task has a verifiable outcome (a file exists, a test passes, a
  command exits 0).
- **Group implementation tasks into atomic commits with `T-N.C*` tasks.**
  Without explicit commit tasks, agents batch every change into a single
  closing commit, which destroys `git bisect` and review readability.
  See "Commit hygiene" below for grouping heuristics.
- **Closing tasks must enumerate the DoD.** Each branch ends with a
  `T-N.D1`–`T-N.D*` block that turns every §6 DoD item into a discrete,
  runnable task. The very last task is "Open PR" — but only after every
  preceding `T-N.D*` is checked. Together with `T-N.C*`, this is what
  turns the DoD and commit hygiene from advisory to gated.
- **When fanning out to subagents**, hand each subagent the relevant
  `T-N.C*` *and* `T-N.D*` tasks alongside the implementation tasks —
  subagents don't see §5 or §6 unless you put them in the prompt.

#### Commit hygiene (the `T-N.C*` pattern)

Why this pattern exists: agents executing a per-branch task list will
otherwise complete every implementation task and `git add . && git commit`
once at the end. That single commit is unbisectable, hard to review,
and impossible to back-derive. Explicit commit tasks fix it.

**Grouping heuristics:**

- **Same purpose → same commit.** Types and the constants they
  reference go together; a config class and its loader go together.
- **Different layers → different commits.** Production code in one
  commit; tests in the next (unless the team explicitly prefers
  impl+tests bundled — defer to §5 `Commits`).
- **Renames vs. behaviour changes → always split.** `git` tracks renames
  poorly when behaviour changes too; reviewers can't see what's changed.
- **DoD-fix work → its own commit.** A lint fix or a test gap discovered
  during DoD verification becomes a follow-up `fix(...)` or `chore(...)`
  commit — never silently folded into a prior commit.
- **Each commit must compile and pass lint independently.** That's what
  enables `git bisect`. If a commit can't stand alone, it's grouped
  wrong.

**Commit-message format** is taken from §5 `Commits` (which restates
AGENTS.md). The `T-N.C*` task lines show example messages that match
that format, including Spec ID citations (`(FR-001, NFR-002)`) so
commits link to the requirements they implement.

**Squash policy** is project-specific. If the team squashes on merge,
the per-commit hygiene above still matters for the review window. If
the team preserves history, it matters permanently. Either way, write
the commits well.

### §8 Data model & migrations

If the feature touches a database, this section is mandatory. The
expand-migrate-contract sequence with one phase per branch is the
default. State **reversibility** explicitly per phase — forward-only
migrations need an explicit data-loss blast-radius statement and a
recovery procedure.

**§8.2 migration state diagram (per MD-24).** When a migration is
present, ship a Mermaid `stateDiagram-v2` over the
expand → dual-write → backfill → switch-reads → contract states. Each
state maps to a branch in the §8.2 table. The diagram makes the
phase-per-branch mapping mechanical for the agent executing the Plan —
it sees which state the current branch is implementing rather than
inferring it from prose.

Skip the state diagram when there are no DB changes (the diagram would
have nothing meaningful in it).

### §9 API & contract changes

For each new/modified endpoint, give:
- exact method + path
- auth requirement
- request shape
- response shape
- status codes (including the 4xx and 5xx, not just 200)
- which Spec FR it satisfies

For internal contracts (queue events, shared types), the same: source,
destination, payload shape, version.

**§9.2.1 cross-service sequence diagram (per MD-24).** When the feature
introduces ≥1 new producer/consumer pair (event publish/consume, queue,
RPC contract), ship a Mermaid `sequenceDiagram` showing the new edge
end-to-end — actors as lanes, ordered messages, error/timeout arrows
where they exist. Skip when no new cross-service contracts are
introduced. Mirrors the §8.2 migration-state-diagram gate: the diagram
makes the producer/consumer pairing mechanical for the agent
implementing the Plan rather than inferring it from prose.

### §10 Configuration & feature flags

Every feature behind a flag. Default `false` everywhere. Owner per flag.
Kill-switch behaviour explicit. If multiple flags, state precedence.

### §11 Observability

Each row is an `OBS-NN` with a closed-vocabulary `Type`
(metric / log / trace / alert / dashboard) and an explicit *Binds to*
column that references the Spec ID(s) the signal serves (typically
an `NFR-*`, sometimes an `S-*` or `R-*`). Without this section the
operator on call cannot diagnose a regression — and without the
*Binds to* column, the methodology has no way to check that the
NFRs the Spec quantified are actually being measured in production.

That last check is `AC-54` in Spec §11.5: every quantified `NFR-*`
must have at least one `OBS-*` whose *Binds to* column embeds the
NFR ID. The Plan-side gate is `T-N.D16`, which runs `comm -23`
between the Spec's quantified NFRs and the §11 NFR mentions and
expects empty output.

Risks (§14) and impact rows (§12.2) reference `OBS-*` IDs by name
when an observability signal is the detection mechanism for a risk
or the monitoring channel for an impact. Keep `OBS-*` numbering
sequential for readability.

### §12 Test plan

Roll up across branches. Add new test types if introduced (contract
tests, load tests, e2e). Each entry has a path and a one-line scope.
Agents are noticeably better at writing tests when given the path and
scope; they are worse at deciding *whether* a test is needed.

**§12.1 *Scenario Traceability Matrix* is the gate that catches
functional gaps.** It is a Requirements Traceability Matrix (RTM —
IEEE/ISO/IEC/IEEE 29148) restricted to behavioural scenarios. Every
Spec scenario `S-NN` in Spec §9 must appear as a row with a runnable
test path. A blank `Test` cell is the same kind of bug as a blank
cell in §16 AC coverage — caught by Spec `AC-50`. The empirical
pattern we are designing against: features that pass unit tests but
miss enumerated scenarios because no test was bound to the scenario.

**Pick the test level per scenario / variant** using the decision
tree below. Apply it independently to each row in §12.1 — a parent
scenario `S-04` (the happy walk) and its variants `S-04a`, `S-04b`,
… legitimately ship at different levels (a `[boundary]` variant may
be a unit test while the parent ships as an e2e walk).

**Variant kind tags** (the closed set from MD-22): each variant row
in §12.1 carries one of `[boundary]` / `[failure]` / `[concurrency]` /
`[property]`. The **parent** scenario row carries **no tag** — the
parent IS the happy path by construction; a `[happy]` tag would only
duplicate it. Do not invent new kind tags; if a variant doesn't fit,
it usually isn't a variant of *this* scenario and should be a
separate `S-NN`.

The decision tree, top-down (stop at the first match):

1. **Inter-service contract?** Does the scenario exercise a producer
   ↔ consumer boundary between two independently deployable
   services? → add a **contract** test (Pact / Spring Cloud Contract
   / Postman / equivalent), *in addition* to whatever else the
   scenario needs at the level below.
2. **Invariant across many inputs?** Does the scenario test a
   property that should hold for *all* valid inputs (e.g. "every
   parsed document round-trips", "the sort is stable", "no input
   ever throws")? → add a **property-based** test
   (Hypothesis / fast-check / QuickCheck), in addition to one
   concrete-input test below. This is where the `[property]`
   variant tag lives.
3. **Real external systems needed to be meaningful?** Does the
   scenario require a real DB, queue, file system, or network call
   to test what it actually claims? → **integration**.
4. **Crosses internal module boundaries?** Does the scenario walk
   through two or more modules whose interaction is the thing under
   test? → **integration**.
5. **User-visible flow start-to-finish?** Does the scenario describe
   a full path through the system as a user would walk it? → **e2e**
   (or smoke, if pre-rollout).
6. **Otherwise — pure logic with mockable dependencies** → **unit**.

A few corollaries:

- **Happy-path unit tests alone are not sufficient for §12.1.** The
  scenario's test must exercise the path the scenario describes,
  not a slice of it. A scenario that crosses three modules cannot
  be covered by a unit test on the middle one — that's a different
  test, valuable, but not the scenario's evidence.
- **Variants of one scenario may ship at different levels.** A
  `[boundary]` variant testing "max size + 1 → 422" might be a unit
  test on the validator; the parent scenario (the happy walk) might
  be the full e2e. Each row in §12.1 picks the level that exercises
  *that* row's path — parent or variant.
- **`[concurrency]` variants almost always need integration or
  higher.** Race / interleaving / idempotency claims rarely
  reproduce under unit-test mocks; they need real schedulers, real
  queues, real connections.

**No fixed pyramid ratio is prescribed.** The classic 70 / 20 / 10
(unit / integration / e2e) is a heuristic from a different era and
modern guidance (2025–2026 test-pyramid literature) explicitly
moves away from rigid ratios toward per-scenario decisions based on
risk, deployment cadence, and how much code is AI-generated. The
shape of the suite is what falls out of applying the decision tree
above to every scenario / variant — not something to declare up
front. Don't paste a target ratio into §12.

**Test-level vocabulary in §12.1.** The `Level` column accepts:
`unit`, `integration`, `contract`, `e2e`, `property`. A row may
list more than one (`unit + property`, `integration + contract`)
when a scenario or variant warrants belt-and-braces coverage.

**Tag-based binding (don't skip this).** Every test that satisfies a
scenario embeds the scenario ID in its name or as a framework-native
tag. Pick one convention per project and record it in §5 of the Plan
(under the `Tests` row). The matrix becomes a *derived* artefact —
a `grep` anchored to that convention yields the covered IDs, and the
`T-N.D8` DoD task compares this to the IDs in the Spec via `comm -23`.
Table-only matrices drift; tags travel with the test.

**Anchor the test-side regex.** A loose `grep -rEho "S-[0-9]+" tests/`
will report a scenario as "covered" by any incidental mention in a
comment (e.g. `# edge case similar to S-04 but different`). That
makes the `T-N.D8` gate silently report green when real coverage is
missing. Always anchor the regex to a structural position determined
by the §5 convention — function names, framework marks, or
describe/it strings. Example:

```bash
# Variant A (string/mark/annotation bindings — recommended):
TS_RE='(scenario\("|nfr\("|tc\("|it\(["'"'"']|t\.Run\("|test_case\(")S-[0-9]+[a-z]*'
grep -rEho "$TS_RE" tests/ | grep -oE "S-[0-9]+[a-z]*" | sort -u

# Variant B (function-name bindings — see Plan template §12.1 for the
# normalising sed pipeline; function identifiers cannot contain
# hyphens, so Variant A's literal-hyphen regex silently reports
# function-name bindings as uncovered. Project picks one per §5.)
```

The `[a-z]*` suffix is what catches variant IDs (`S-04a`, `S-04b`, …,
and multi-letter rollovers like `S-04aa` when a parent scenario has
more than 26 variants) added by MD-22. Plans on v0.2.0 (pre-variants)
that hard-code the older `S-[0-9]+` regex will silently miss every
variant row and the `T-N.D8` gate will report green when real breadth
coverage is missing.

The same anchoring applies to two other companion gates that share
this section's mechanical pattern:

- **`T-N.D9`** — gates `AC-51` (every quantified Spec NFR has a
  measurement test). Regex: `NFR-[0-9]+` (no variant suffix; NFRs
  don't have variants).
- **`T-N.D10`** — gates `AC-52` (every Spec TC is verified). Regex:
  `TC-[0-9]+`. Heterogeneous: mechanically verifiable TCs (dependency
  audit, lint, integration test) get a runnable verification with the
  TC ID embedded; non-mechanically verifiable TCs (architectural
  standards, prose conventions) get a named reviewer / review-checklist
  citation. The `T-N.D10` check is a real shell pipeline:
  `comm -23 <(grep -oE 'TC-[0-9]+' SPEC.md | sort -u) <(sed -n '/^## 12\./,/^## 13\./p' PLAN.md | grep -oE 'TC-[0-9]+' | sort -u)`
  returns empty when every Spec `TC-NN` appears in Plan §12 in either
  form (runnable verifications OR reviewer/checklist citations) —
  because the reviewer-checklist path is the only valid form for TCs
  that aren't amenable to grep-checking.

`T-N.D8` and `T-N.D8b` (variant-block presence) cover the scenario
side; together with `T-N.D9` and `T-N.D10` they form the full RTM
mechanical-gating layer.

The tag pattern is borrowed from BDD (Cucumber `@tag` syntax) and
adopted by AI-spec plugins like `swingerman/atdd` and Paul Duvall's
ATDD-driven AI development pattern. It's the difference between
"traceability claimed in prose" and "traceability mechanically
verifiable".

### §12.2 Impact Traceability

The structural answer to the question coding agents reliably skip:
*what does this change actually affect?* Each row is an `IMP-NN`
with a closed-vocabulary `scope` (`code` / `system` / `business` /
`external`), the triggering Spec ID(s), the bound risk and
observability signal (if any), and the mitigation task.

Spec `AC-53` is recorded at **feature granularity**: the change must
have at least one `IMP-*` row for every materially-affected scope —
not one row per scenario. A single `IMP-*` may be *triggered by*
several `S-*` / `FR-*`; list them all in the *Triggered by* column.
Plan-side gate: `T-N.D15`, which checks that §12.2 is non-empty and
that every scope the change materially touches is represented. (An
early per-scenario draft demanded one row per scenario — 20 rows for
a 20-scenario feature; feature-level keeps the discipline without the
ceremony.) The single-family + `scope`-field design is deliberate
(`MD-20`); resist the urge to split into four prefixes
(`IMPC`/`IMPS`/`IMPB`/`IMPE`) because that triples the gating
complexity without buying filterability that `grep -F "scope=external"`
doesn't already give you.

**Resolving the *Mitigation task* column.** `IMP-*` rows live in the
global §12.2 matrix, but the `T-N.*` tasks they cite live in
per-branch §7.x.9 checklists. A cited task ID must resolve to a task
defined in *some* branch's §7.x.9 — the gate scans every branch's
checklist, not just the current one, so an impact mitigated by a task
in a later branch still resolves. When an impact has no single
mitigating task (e.g. a `scope=external` commitment handled by the
whole branch arc), reference the branch's closing `T-N.D*` block or
leave the cell `—` with a one-line note rather than inventing a task.

When in doubt about whether an impact is `system` or `external`: if
the affected party shares your deploy cadence, it's `system`; if
they ship on their own schedule (mobile app, partner API,
documentation site, support runbooks), it's `external`. The two
have very different rollout consequences.

Keep `IMP-*` numbering sequential for readability.

**Greenfield projects.** In a greenfield (no pre-existing code or
system to regress), `IMP-*` is *not* skipped — its character just
shifts from retroactive to forward-looking. `scope=code` rows
become rare (nothing to break yet); the other three scopes are as
relevant as ever:

- `scope=system` — how the new service plugs into existing infra
  (auth, observability, deploy pipelines, queues).
- `scope=business` — the capability you are committing to deliver.
  In greenfield, this *is* the feature; spelling it out as an
  `IMP-*` row forces explicit naming of who depends on it.
- `scope=external` — the API shape, event schema, or contract you
  are shipping is a forward-looking commitment to future consumers.
  Once it's out, breaking it has cost.

The gate (`AC-53`) is left mandatory deliberately: the discipline
of forcing the change to name its commitments per scope is exactly
the value of `IMP-*`, even — maybe especially — on a fresh codebase.

### §13 Rollout plan

The operational sequence to enable the feature. Should reference §10
flags and §7 branches by name. Progressive rollout (5% → 25% → 50% →
100%) is the default; instant flip is the exception and needs
justification.

### §14 Risks & rollback

Each row is an `R-NN` with likelihood / severity / detection signal /
mitigation path / **exact rollback procedure** (flip flag X, revert PR
Y, run command Z). Worst-case blast radius stated explicitly. If the
answer is "we cannot rollback once Z runs", say so loudly.

Two structural anchors:

- **Detection signal** should reference an `OBS-*` ID in §11 whenever
  the signal is observable post-deploy. Free-form text is allowed
  when the detection is a manual check, but `OBS-*` is preferred —
  it lets a reviewer confirm the signal actually exists.
- **Mitigation path** must be one of three things, so that no risk is
  left with no recorded plan: (a) a `T-N.*` task in the per-branch
  §7.x.9 checklists (the default — a risk you intend to actively
  mitigate); (b) `accepted (rationale: …)` when the team consciously
  accepts the risk; or (c) `monitored only — see OBS-NN` when the
  plan is to watch a signal rather than pre-empt. The `T-N.D17` gate
  verifies that every `R-*` row's *Mitigation task* cell is non-empty
  and that any `T-N.*` it cites resolves to an actual task in §7.x.9
  (the `accepted` / `monitored only` forms satisfy the non-empty
  check without needing a task reference).

Keep `R-*` numbering sequential for readability.

### §15 Open questions & assumptions

Two sub-tables: §15.1 for `OPEN-Q-*` (carried forward from Spec or
discovered at Plan time, with target resolution branch), §15.2 for
`A-NN` assumptions specific to the Plan ("we assume vendor X indexing
latency < 60 s"). Don't mix them in one table — the lifecycle is
different.

### §16 Acceptance criteria coverage

Map every Spec `AC-*` to the branch that satisfies it AND to the test
that verifies it. The `Test` column was added deliberately — an AC
without a referenced test is "claimed satisfied" without proof. A
blank cell in either column is a gap and must be addressed before the
Plan is approved.

The Spec-side meta-ACs (`AC-50`..`AC-55` from §11.5) are gates
verified mechanically:

- `AC-50` — §12.1 *Scenario Traceability Matrix* (every `S-*` has a test) → `T-N.D8`.
- `AC-51` — §12.8 / §12.4 (every quantified `NFR-*` has a measurement test) → `T-N.D9`.
- `AC-52` — §11.3 + §12 (every `TC-*` has a compliance verification entry) → `T-N.D10`.
- `AC-53` — §12.2 *Impact Traceability* (an `IMP-*` per affected scope, feature-level) → `T-N.D15`.
- `AC-54` — §11 *Observability* (every quantified `NFR-*` has an `OBS-*`) → `T-N.D16`.
- `AC-55` — §5 `Supply-chain` token names the lockfile (or declares `none`); `T-N.D20` scans it clean, and any accepted advisory is an `R-*` row in §14 → `T-N.D20` (`MD-31`).

They are typically satisfied across multiple branches; note the
branch where the *last* gap closes. With the tag-based binding
convention in §12.1 and the matrix patterns in §11/§12.2, the entire
§16 table can be largely auto-derived from `grep` over the Spec, the
Plan, and the test suite.

### §17 Change log

Append-only. One row per material change after the Plan is first
approved. Skip nits; record substantive changes (branch added, scope
shifted, tasks restructured).

## Bidirectional derivation

- **Plan → Spec (back-derivation).** §7 per-branch behaviour and §16
  AC coverage are the primary signal source for FRs. §10 flags + §11
  observability + §14 risks inform NFRs. Library/vendor/architecture
  choices in §3.1 (TD-*) and §4 module map that look externally
  mandated translate to Spec TCs (when in doubt, ask the user). §12
  tests inform scenarios. Flag every back-derived FR/NFR/TC `[INFERRED]`
  for human validation.
- **Plan must respect Spec.** Every Spec `FR-*`, `NFR-*`, `TC-*`, `AC-*`
  should be traceable to a branch in §7 and confirmed in §16. Gaps
  invalidate the Plan.

## Common authoring smells

- **"The auth module".** Never. Use the path.
- **One huge branch.** Split into 3+ branches behind a flag, even if the
  feature is small.
- **Tasks like "implement X".** Decompose into file-level tasks.
- **No verification per task.** Add a check that exits 0/1.
- **No rollback procedure.** Add one even if it is "flip flag to false".
- **Missing §16 mapping.** Always fill the AC coverage table.
- **Code blocks longer than 5 lines.** Replace with signature + tests.
