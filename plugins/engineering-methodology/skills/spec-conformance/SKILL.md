---
name: spec-conformance
description: Audit a feature's actual codebase against its committed Spec and report where the two have drifted apart. Sweeps forward (every FR-*, NFR-*, TC-*, S-*, AC-* → code, with file:line evidence at a pinned SHA) and backward (code behaviour no ID sanctions). Every ID gets one verdict — IMPLEMENTED, PARTIAL, ABSENT, DIVERGENT, UNVERIFIABLE — plus UNSPECIFIED-BEHAVIOUR findings from the reverse sweep. Triggers on "does the code match the spec", "what's not implemented", "find implementation gaps", "audit the implementation against the spec", "check for spec drift", "is this feature actually built", "which requirements are missing". Read-only: it reads the feature's bound tests to confirm they exist, but never runs them and never executes the feature — anything only a run could settle is reported UNVERIFIABLE with the command named for a human. Not for answering questions from the docs (see spec-answers), authoring them (see staged-engineering-doc), or rendering them (see three-p-visualizer).
---

# Spec conformance — audit the code against the Spec

This skill measures a feature's **implementation** against the **Spec** that was
agreed for it, and reports the distance between them.

Its one invariant is **two-sided grounding**: every verdict names both the Spec
ID it judges *and* the `file:line` in a pinned checkout it was judged against.

The output flows in two directions. `ABSENT` and `PARTIAL` are work for the
Implementation Plan. `DIVERGENT` and `UNSPECIFIED-BEHAVIOUR` are work for the
**Spec** — they are how a document that has fallen behind its own code gets
caught.

Phase 2 **runs the methodology's own DoD gates** — `T-N.D8`, `D8b`, `D9`,
`D10`, `D15`–`D20`, backed by `AC-50`–`AC-55` — rather than reinventing them.
(`T-N.D20` / `AC-55` is the supply-chain gate: `spec-conformance` is read-only
and never re-runs the scanner, so it settles `AC-55` by *reading* the recorded
`T-N.D20` checkbox, the Plan §5 `Supply-chain` token, and the §14 `R-*` waiver
rows — see the `AC-` row in the obligation table and `mechanical-gates.md`.)
(`D11`, `D12` and `D14` are build-process gates: commit hygiene, PR description,
PR opened. They say nothing about conformance and are not run. `D13` is the
template's project-specific slot — `{{self-review skill / coverage /
accessibility audit / …}}` — so it is a hole rather than a fixed gate: read what
the audited project put there, and run it only if what it holds is a conformance
check. A coverage or accessibility gate is; a second commit-hygiene lint is not.) Why a skill is still needed on
top of gates that already exist — and why this is a separate skill from
`spec-answers` — is `MD-30`.

## When to invoke

Use this skill when the user wants to know **whether the code matches the
documents**:

- which requirements are implemented, partially implemented, or missing
- whether the feature is actually built, or only planned
- where the code and the Spec have drifted apart
- what the code does that the Spec never sanctioned
- a pre-release or post-hoc audit of a feature against its contract

Do **not** use it to answer questions *from* the documents — that is
`spec-answers`. Do not use it to draft, derive, or critique them — that is
`staged-engineering-doc`. Do not use it to render them — that is
`three-p-visualizer`.

## Bundled files

```
spec-conformance/
├── SKILL.md                      ← this file (always loaded)
└── references/
    ├── mechanical-gates.md       ← the grep/comm pipelines (load in Phase 2)
    ├── grounding-contract.md     ← per-ID evidence contract + reverse sweep (Phases 3–4)
    └── report-shape.md           ← JSON schema + markdown matrix (load in Phase 5)
```

All paths are relative to the skill directory.

## The obligation set

### Families this skill drives

| Family | Spec section | What conformance means |
|---|---|---|
| `FR-` | §7 Functional requirements | The EARS obligation is realised in code on a reachable path. |
| `NFR-` | §8 Non-functional requirements | The quantified target is met, or a mechanism exists that could meet it plus a measurement proving it. |
| `TC-` | §4 Technical & architectural constraints | The constraint holds across the code it constrains — a constraint is violated by one counterexample, not satisfied by one conforming case. |
| `S-` / `S-NNa` | §9 System behaviour & scenarios | The Given/When/Then walk, and every enumerated variant, is realisable and covered. |
| `AC-` | §11 Acceptance criteria | The stated verification exists and passes. Meta-ACs `AC-50`–`AC-55` (§11.5) are settled by Phase 2's gates — two of them are conjunctions, so see `references/mechanical-gates.md` before assigning a verdict. `AC-55` (supply-chain) is on its own **third axis**: its evidence is neither `file:line` nor `document §section` but the Plan's *recorded* `T-N.D20` state — the checkbox, the §5 `Supply-chain` token, and any §14 `R-*` waiver rows. Read that record; never re-run the scanner (the audit is read-only, and this keeps the verdict reproducible at the pinned SHA). |

**Extension methodologies add their own families.** When Phase 0 finds an
extension's requirement-tier documents, its obligation-bearing IDs join the
denominator on equal terms — `migration-methodology`, for instance, defines
`W-`, `INV-`, `PAR-`, `FF-`, `CST-`, `GAP-` and `DEF-` across its Migration
Charter, Parity Plan and Cutover Plan. Discover them rather than hardcoding
them: read the extension's templates (in its skill directory, alongside the
`staged-migration-doc` equivalent) and take the ID prefixes its sections
define, exactly as this table takes the base Spec's.

Two rules carry over unchanged. Anchor any prefix that ends another before
grepping (`references/mechanical-gates.md`), and give each extension family its
own section in the report. **If an extension document is present but its
families are not enumerated, say so and exclude it from the denominator
explicitly** — silently auditing a migration feature against the base Spec
alone reports clean on obligations that were never examined.

**Worked example — `migration-methodology` present.** Phase 0 finds a
`*_MIGRATION_CHARTER.md` and a `*_PARITY_PLAN.md` beside the Spec. Locate the
extension's templates under its `staged-migration-doc` skill's `templates/`
directory, and for each, take the ID prefix each obligation-bearing section
defines — the Parity Plan's parity rows give `PAR-`, its invariants give `INV-`,
the Charter's constraints give `CST-`, the Cutover Plan's flags give `FF-`.
Prefixes naming *gaps* rather than obligations (`GAP-`, `DEF-`) are recorded as
context, not scored, for the same reason `OPEN-Q-*` never receives a verdict:
they document what is known missing, so an `ABSENT` verdict would restate the
document rather than audit it. A `PAR-07` then flows through Phase 3 exactly
like an `FR-*` — one verdict, `file:line` in the pinned worktree — and appears
under its own *Parity* heading in the report, with the Spec families untouched
beside it.

The anchoring rule earns its keep here, in the opposite direction from usual: it
is the *base* prefixes that get swallowed by the extension's. `R-` sits inside
`PAR-` and `T-` sits inside `CST-`, so over a migration feature a bare
`grep -oE "R-[0-9]+"` reads `PAR-07` as a risk `R-07` that was never written.
Re-derive the collision set per run — it is a property of whichever templates
are present, not a fixed list.

### Families this skill does not drive

`D-` (Concept §10), `US-` (Spec §5.2), `A-` (§14), §15 Risks and `OPEN-Q-`
(§16) — none is an implementable obligation. `D-` and `US-` reach the code
through the `TC-*`/`FR-*` they produced, which are driven; auditing both would
double-count.

**`OPEN-Q-*` is surfaced as context, never as a verdict.** Where an open
question overlaps a driven ID, conformance there is *undefined* — the Spec has
not decided. Attach the quote to that ID's note and mark its verdict
provisional.

### The denominator: the whole Spec, always

Every driven ID is held against the code **regardless of build state**, so a
half-merged feature reports a large `ABSENT` count and that is the intended
reading. The Plan §7.1 *Branch tracker* is a self-report and never filters the
denominator (`MD-30`).

The report carries a **Plan attribution** column for readability — which branch
or task claimed each ID. It is **context only: never a filter, an excuse, or a
downgrade**. No Plan, no column; nothing else changes.

## Verdict vocabulary

Closed sets, for the same reason `MD-22`'s kind-tags and `MD-24`'s diagram
vocabulary are closed: "the code doesn't do this" must be a checkable outcome,
not a hedge the model rephrases each run.

### Forward sweep — exactly one verdict per driven ID

- **IMPLEMENTED** — evidence at `file:line` satisfies the obligation. Cite the
  path, the line, and what it does.
- **PARTIAL** — part of the obligation landed and the remainder was verified
  missing. **Name both halves**; "partially done" without the split is not a
  finding anyone can act on.
- **ABSENT** — no implementation found. Name where it would live, so the gap is
  actionable rather than merely reported.
- **DIVERGENT** — the code implements something **contrary** to the ID, not
  merely additional. Quote the ID's normative clause and cite the contradicting
  code. This is the verdict that most often means the *Spec* is wrong.
- **UNVERIFIABLE** — reading cannot settle it: visual, runtime-only,
  environment- or credential-blocked. **Never guessed.** Mark it and name the
  check a human would run to settle it.

### Reverse sweep — one finding per undocumented behaviour

- **UNSPECIFIED-BEHAVIOUR** — public behaviour inside the feature's code
  surface that no `FR-*`/`NFR-*`/`TC-*`/`S-*` sanctions. Name the proposed home
  in the Spec (section + ID family).

`DIVERGENT` is anchored to an ID the code contradicts; `UNSPECIFIED-BEHAVIOUR`
has no anchor at all. They stay separate terms because that is the difference
between fixing code and amending a Spec (`MD-30`).

### Precedence when more than one verdict could apply

Take the first that matches:

1. Code contradicts the ID → `DIVERGENT`.
2. Evidence fully satisfies it → `IMPLEMENTED`.
3. Evidence satisfies part of it, the rest verified missing → `PARTIAL`.
4. Reading cannot settle it — it needs measurement, execution, or credentials
   you do not have → `UNVERIFIABLE`. Bound tests are **read, never run**: this
   skill never executes the audited feature.
5. Nothing implements it → `ABSENT`.

`UNVERIFIABLE` sits above `ABSENT` on purpose: "I could not check" must never
be reported as "it is not there."

### Three determinism rules

The ladder settles a *single* claim about an *unambiguous* subject. Most
obligations are neither, and without these three rules the same Spec against
the same SHA produces different
verdicts on different runs — measured at **20 % verdict churn** across two runs
of the same feature before they existed.

**1. Clause combination — the worst clause sets the verdict.** Split a
multi-clause obligation into its clauses, status each one, then take the worst:

| Any clause… | ID verdict |
|---|---|
| contradicted | `DIVERGENT` |
| else, unmet with the rest satisfied | `PARTIAL` |
| else, unsettleable by reading alone (needs measurement, execution, or credentials) | `UNVERIFIABLE` |
| else (all satisfied) | `IMPLEMENTED` |
| no clause has any implementation at all | `ABSENT` |

A clause quoting a literal the code does not contain is **contradicted**, not
merely unmet — the Spec names a string that does not exist, so anyone acting on
it gets nothing. Report every clause's status in the note regardless of which
one won.

**2. Clause scope — judge the literal subject, report the rest separately.** A
clause governs the thing it names. If it says "the secondary saga", its domain
is that function; if it says "log lines emitted by X", its domain is X's lines.
**Behaviour outside the literal subject never changes the verdict** — even when
it undermines the clause's purpose. It has two possible homes, and they are not
interchangeable:

- **No ID sanctions it** → a reverse-sweep finding (`UNSPECIFIED-BEHAVIOUR`).
- **It bears on *this* clause under a wider reading of its subject** → an
  `alternate_reading` on this row (Rule 3).

The note names the reading used either way.

This is the same separation `DIVERGENT` and `UNSPECIFIED-BEHAVIOUR` already
make: a contradicted obligation is one thing, an unsanctioned neighbour is
another. Widening a clause's domain to swallow its neighbours is how two
readers reach two verdicts from identical evidence.

**3. Ambiguous subjects — record both readings.** Taking
the narrow reading and moving on is not enough: narrowing a subject can make a
clause *satisfied*, so it never reaches the combination step above, and Rule 1
is silently neutralised. Observed: one requirement produced three different
verdicts across three runs of the same feature — `DIVERGENT`, `PARTIAL`,
`IMPLEMENTED` — because each run resolved its implicit subject differently.

So when two readings a competent reader could defend yield **different**
verdicts:

- **The narrow reading is the reported verdict.** It is the one mechanically
  derivable from the clause's own words, so the counts stay stable and
  comparable across runs.
- **The broad reading is recorded beside it** in `alternate_reading`, with its
  own verdict and evidence.
- **The ID appears in the Gaps roll-up** regardless of which verdict won. A
  requirement that means two different things is a defect in its own right, and
  it is the *Spec* that needs fixing.
- Raise the ambiguity as a Spec-quality finding too, naming both readings.

If both readings yield the same verdict there is no ambiguity worth recording —
say nothing. This is the same instinct as `DIVERGENT`, which presents both
remedies and picks neither: carry the disagreement into the report rather than
resolving it invisibly.

## Authorization

Everything here is read-only unless it appears in this table. Stated once; the
phases do not restate it.

| Action | Rule |
|---|---|
| Create a worktree in the audited repo | ask, or take a Phase 0 read-only alternative |
| Write any file inside the audited repo | ask — the scratchpad is the default |
| Run the feature's bound tests | never: name the command, do not run it |
| Exercise the feature live | never: name the check, do not run it |
| Amend a document, file an issue, change code | never: offer and stop |

**This skill never executes the audited feature** — not its tests, not its
entrypoints, not a build of it. The distinction is the *subject*: the skill runs
plenty of its own read-only shell (`git`, `grep`, `comm`, `sed` over the
documents and the pinned checkout), and that is authorised. What it never runs
is the code under audit. An obligation that only execution could settle is
`UNVERIFIABLE` with the command named for a human — that is the finished answer,
not a deferral to a later phase.

**Everything else proceeds without asking** — reading the documents, reading
code at the pinned SHA, reading the bound tests, running the Phase 2 gates,
launching the Phase 3 fan-out, and writing the report to the scratchpad. Do not
pause for confirmation on work this table already authorises.

## Workflow

**Recommended effort per phase.** These are defaults, not requirements —
re-sweep them on your own evals, and ignore them entirely if your harness has no
effort control.

| Phase | Effort | Why |
|---|---|---|
| 2 — mechanical gates | `low` | deterministic shell; no judgement |
| 3 — grounding fan-out | `high` (`xhigh` for constraint-heavy clusters) | the hardest judgement in the skill |
| 4 — reverse sweep | `high` | open-ended search over a bounded frontier |
| 5 — render from JSON | `low` | mechanical transformation |

### Phase 0 — Pin both sides

Neither side is a moving target once this phase ends. Every citation in the
report resolves against the pins recorded here.

**The documents** — run the sibling `spec-answers` skill's **Step 0** as
written: feature-folder discovery, never guessing between candidates, and the
pinning rule (path + `git log -1`, header `Status:`, the **last** Change-log
row, `+ uncommitted edits` when `git status --porcelain` is non-empty,
`uncommitted (working tree)` when untracked). Four deltas, all this skill's:

1. **List the whole folder.** Extension methodology documents (a Migration
   Charter, Parity Plan, Cutover Plan) carry obligations and are swept alongside
   the Spec — see *The obligation set* above.
2. **The Spec is required.** With no Spec there is no denominator — say so and
   offer `staged-engineering-doc` to back-derive one. Never reconstruct a
   denominator from the implementation: a Spec read out of the code trivially
   conforms to it, which measures nothing.
3. **Read the Spec completely; read the Concept selectively.** The Spec is the
   denominator. This skill drives no Concept family, so from the Concept take
   only §14 *Out of scope / deferred*, §15 *Open questions*, and the `D-`
   enumeration `T-N.D19` needs.
4. **Read the Plan if one exists** — §4 *Module map* seeds the reverse-sweep
   frontier, §5 carries the test-binding convention, §7.1 supplies the Plan
   attribution column, §12.1/§16 carry the matrices Phase 2 checks. While it is
   open, extract the §7.1 branch→ID map so Phase 5 does not re-read it per row.
   The Plan is **never a source of obligations**.

**The code** — follow `issue-triage`'s Phase 0:

5. Identify the code repo (not always the same repo as the docs) and detect its
   default branch as `issue-triage` Phase 0 does — do not assume `main`. Ask
   whether the audit should target a branch other than the default.
6. **Name the code repo in every git command** (`git -C <code-repo>`) — docs
   and code may live in different repositories, and a bare `git worktree add`
   resolves against the current directory.

   ```bash
   git -C <code-repo> fetch origin <branch>          # first — local refs go stale
   git -C <code-repo> worktree add <code-repo>/.claude/worktrees/spec-conformance-<slug> \
       origin/<branch> --detach
   ```

   Record the SHA; every code claim in the report cites it.
   - Worktree path is **relative to the code repo**, under `.claude/worktrees/`.
     **Never under `/tmp`** — macOS purges those mid-run.
   - A worktree writes to the audited repository, so there are two read-only
     alternatives — prefer whichever fits:
     - **Clean tree at the target revision** — read in place, pin its HEAD.
     - **Dirty tree** (the common case) — read in place *only if* the modified
       paths do not overlap the frontier. Pin `<sha> + uncommitted edits` and
       state in the provenance header which paths are dirty and that they fall
       outside it. If a dirty path *does* overlap, you are auditing something
       that is neither the pinned commit nor a coherent revision: take the
       worktree, or stop.
   - **Nested checkouts are not part of the tree you are auditing.** A working
     repo often contains worktrees of itself (`.claude/worktrees/`), sibling
     clones, or vendored trees. Enumerate candidate files with `git ls-files` at
     the pinned SHA — never a bare recursive walk. One observed repo held 35
     nested worktrees, turning a single function into 147 grep hits across six
     branches.
   - Record evidence as **repo-relative path + line + pinned SHA**, never as a
     worktree-absolute path. The citation must still resolve after the worktree
     is removed.
7. If the working tree is dirty or the audit is being run against uncommitted
   work, say so and pin `<sha> + uncommitted edits` on the code side too. The
   report's provenance header carries both sides.

### Phase 1 — Extract the obligation set

Enumerate every driven ID from the Spec. **This list is the denominator**; its
count is asserted against the report in Phase 5, and a mismatch is a bug in the
run, not a rounding difference.

- Grep by family and section: `FR-` (§7) · `NFR-` (§8) · `TC-` (§4) ·
  `S-[0-9]+[a-z]*` (§9, parents *and* letter-suffixed variants per `MD-05`) ·
  `AC-` (§11). Use `mechanical-gates.md`'s
  `spec_ids` helper — **never a bare prefix grep**, which inflates the
  denominator with IDs that do not exist.
- Record each ID with its **verbatim normative text**. The audit judges the
  clause as written; a paraphrase quietly changes what is being measured.
- **Resolve every domain term through Spec §6 *Glossary* first.** A term with a
  narrow in-feature definition changes what you are even looking for in the
  code — the single most common way this skill can be confidently wrong, and
  the same trap `spec-answers` guards.
- Note which `NFR-*` carry **quantified** targets: only those are gated by
  `AC-51`/`AC-54`, and only those can be verified by measurement rather than by
  reading.
- **Enumerate the extension families too**, when Phase 0 found extension
  documents — same treatment, same denominator, their own report sections. If
  you cannot establish an extension's ID families, exclude that document from
  the denominator *out loud* rather than letting it fall silently out of scope.
- Collect `OPEN-Q-*` from Spec §16 and Concept §15 and map each to the driven
  IDs it touches, for the provisional-verdict note above.

### Phase 2 — Mechanical tier

Load `references/mechanical-gates.md` and run the methodology's own gates
against the real repository at the pinned SHA.

Cheap, deterministic, and it produces the **binding layer**: which IDs have a
test bound to them, which matrices are populated, which cross-document
references resolve. Phase 3 then has to believe or refute it.

That file carries the rules that govern the output and they are not restated
here — the interpretation rule, test-suite scoping, ID anchoring, file
enumeration, and the requirement that every gate gets a row.

**Phase 2 also emits Spec-quality findings**, not just gate results: scenarios
with no `Variants:` block, NFRs with no quantified target, requirements no
scenario exercises, dangling cross-document IDs. They are findings about the
*document*; they never enter the verdict counts, and together with Phases 3 and
4's they make up the report's Spec-quality section.

### Phase 3 — Forward grounding fan-out

> **The contract is the requirement; the fan-out is an optimisation.** Parallel
> sub-agents are a Claude-Code-style capability, and everything else in this
> skill is portable shell. Decide once, here: if the environment cannot spawn
> agents, run the identical per-ID contract inline, cluster by cluster, and
> nothing about the report changes. Check before partitioning rather than
> discovering it at launch — the test is simply whether you can dispatch a
> sub-agent in this environment; if you cannot, or are unsure, go inline.

Partition the obligation set by capability — Spec §7's capability clusters are
the natural boundary, with `NFR-*`/`TC-*` grouped by the cluster they most
constrain — and launch **one read-only agent per cluster, all in a single
message**.

Each agent's prompt carries: the worktree path and pinned SHA, its ID list with
verbatim normative text, the Phase 2 binding results for those IDs, and the
per-ID contract from `references/grounding-contract.md`. Load that file before
launching.

Build the normative text mechanically with `spec_clause`
(`references/mechanical-gates.md`) rather than transcribing clauses by hand —
hand-assembly is the step that gets skipped under load, and skipping it makes
every agent re-read the whole Spec.

**Collect what the agents return besides verdicts.** Each reports a
`cross-cluster` section (evidence bearing on an ID another cluster owns) and a
`spec-quality` section (defects in the *document*). Route every cross-cluster
observation to the owning cluster **before verdicts are fixed** — an agent that
saw the deciding evidence but did not own the ID is the cheapest correction
available. Spec-quality findings accumulate into the report's own section and
never enter the verdict counts.

**Verify the partition: cluster sizes plus the IDs Phase 2 already settled
(`AC-50`–`AC-55`) equal the Phase 1 denominator.** An ID that falls between
clusters is silently unaudited, which is the one failure mode a conformance
report cannot survive. Phase-2-settled IDs are excluded from the fan-out — do
not ship them to an agent that is then told not to re-derive them.

The partition check applies just as much to the inline path at the top of this
phase — running cluster by cluster does not relax it.

**Scale ladder.** Up to ~40 driven IDs, run exactly as written. ~40–120:
coarser clusters, more IDs per agent. Beyond ~120: batch the fan-out and report
per-batch progress. Only the fan-out *shape* scales — **what each agent is
given never shrinks**. Dropping the verbatim normative text to save prompt size
is a false economy: the agent then re-reads the whole Spec to recover a clause
the orchestrator already had, once per agent.

### Phase 4 — Reverse sweep

Find what the code does that no ID sanctions — the half nothing else in the
methodology covers, and the half that flows back into the Spec.

`references/grounding-contract.md` (already loaded for Phase 3) defines the
frontier, the enumeration protocol, the exclusions and the severity ordering.
The frontier is bounded — Plan §4's module map, Phase 3's cited files,
feature-attributable commits, and one public-surface hop. **State the resulting
frontier in the report**; a sweep that expands without limit stops being an
audit of *this feature*.

**Absolute cap.** The four bounds are principled but they compose: a wide module
map crossed with a wide public surface can still produce a frontier no honest
sweep covers. Enumerate the frontier *before* sweeping it, and if it exceeds
**60 files**, stop and report `UNVERIFIABLE — reverse-sweep frontier too wide
(<N> files), needs manual scoping`, naming the two or three widest contributors
so a human can narrow them. Do not silently sample it: a partial sweep reported
as a complete one is the failure this whole phase exists to prevent, and
"`UNSPECIFIED-BEHAVIOUR`: none found" over a frontier that was never read is a
false clean bill. The number is a backstop, not a target — most features come in
far under it.

**Reconcile before Phase 5.** The reverse sweep reclassifies any finding that
contradicts a specific ID as `DIVERGENT` against it — and that ID usually
already has a Phase 3 verdict. When the two tiers disagree:

Two cases, and they resolve **differently**. Tell them apart by asking whether
a cluster agent, looking only at the clause's literal subject, could have seen
the same evidence:

- **It could have — the sweep found something the cluster missed inside the
  subject.** That is a correction: the sweep's verdict wins, and `revised_from`
  records the superseded one so a reader sees the disagreement rather than
  inheriting its resolution.
- **It could not — the evidence lies outside the subject, and the sweep is
  reading the clause more widely.** That is not a correction, it is Rule 3: the
  narrow verdict **stands**, and the sweep's verdict becomes the row's
  `alternate_reading`. Do not overwrite. Observed: a requirement for "a single
  info log line" is satisfied against the saga's own line and unmet against the
  system's two — one row, both readings, no winner.
- **A contradiction against an ID no cluster owned** means the partition was
  wrong. Add the ID, re-check the denominator, and say so.

### Phase 5 — Persist, then render

1. Write **`spec-conformance-data.json`** — the canonical artefact, in the
   schema in `references/report-shape.md`. Every rendering derives from it,
   every re-run diffs against it.
2. **Derive** the markdown report from that JSON. Never hand-write it: a
   hand-written twin drifts from the data on the first correction.
3. Assert before handing off: the per-ID row count equals the Phase 1
   denominator; every `IMPLEMENTED`/`PARTIAL`/`DIVERGENT` row cites a
   resolvable `file:line`; every non-`IMPLEMENTED` row appears in the Gaps
   roll-up.

Default report path
`docs/{feature-slug}/{FEATURE_NAME_SLUG}_CONFORMANCE_{YYYY-MM-DD}.md`, mirroring
the feature folder's naming. The scratchpad is the default: the audit must not
be the thing that dirties the tree it is measuring.

**Re-runs.** Diff against the previous `spec-conformance-data.json`: re-verify
every ID whose cited files changed between the two pinned SHAs, plus every
`ABSENT`, `UNVERIFIABLE` and `PARTIAL` (their absence is not pinned to a file
that can be diffed). Carry the rest forward, and mark in the report which rows
were re-verified and which were carried.

**Always re-verify a control sample, even when nothing moved.** Take at least 5
IDs, or 10 % of the carried set, whichever is larger, spread across families,
and re-ground them from scratch. Report the **agreement rate** in the report
header.

This exists because carry-forward assumes the grounded tier is deterministic,
and it is only as deterministic as the three determinism rules make it. Without a
control sample a re-run confirms its own previous answer by construction: no
file moved, so nothing is re-checked, so nothing can disagree. Measured churn
before the determinism rules was 20 %.

- **Agreement below ~90 %** means the carry-forward is not trustworthy. Say so,
  re-ground the whole set, and record which rule the disagreements turned on —
  a clause-combination or clause-scope call that the rules do not yet settle is
  a defect in *this skill*, and belongs in the report as one.

### Phase 6 — Close the loop

Report first, then **offer**:

- **`ABSENT` / `PARTIAL`** → Implementation Plan work. Name the Spec ID and the
  Plan section (§7 branch plan, §12.1 matrix, §16 AC coverage) that would carry
  it.
- **`DIVERGENT`** → a decision the user must make: fix the code, or amend the
  Spec. **Name both options; pick neither.** Which is right depends on intent
  the documents do not record.
- **`UNSPECIFIED-BEHAVIOUR`** → a Spec amendment. Hand off to
  `staged-engineering-doc`'s iterate-on-existing-draft path with the proposed
  section and ID family; it preserves existing IDs and appends a Change-log row.
- **`UNVERIFIABLE`** → a named human check. Give the exact command or steps, the
  file the bound test lives in, and what result would settle the ID. Hand it
  over; do not run it.

**Never write the missing content** — not into the Spec, not into the code, not
as a "reasonable default", not as an illustration (`MD-10`). **Never author a
test** to close a gap either: that is implementation work, and an audit that
writes the test it then counts is grading its own homework. A gap surfaced is
worth more than a gap filled by guess.

## Operating principles

- **Two-sided grounding.** No evidence, no verdict.
- **A gate pass is not an implementation.** The mechanical tier finds bindings;
  only the grounded tier finds behaviour.
- **`UNVERIFIABLE` beats a guess**, and one verdict per ID from the closed set.
  Reproducibility is the goal the three determinism rules serve — it is not
  automatic, and the Phase 5 control sample is what tells you whether it held.
- **Divergence is reported, not resolved.** Name both remedies — fix the code,
  or amend the Spec — and let the user decide which side is wrong.
- **No numeric confidence and no conformance percentage as a headline** — the
  verdict counts are the only quantisation (`MD-23`). A "87 % conformant" line
  invites reading the number instead of the gaps.
- **The audited feature is never executed** (see *Authorization*) — its tests
  are read, not run — and the missing content is never written (`MD-10`).
- **Answer in the user's language**, but keep stable IDs, section numbers,
  file paths and quoted normative clauses untranslated — they are literal keys
  into the docs and the code.
