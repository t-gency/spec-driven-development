# Engineering Methodology

> **Status:** Experimental ·

A three-stage AI-assisted feature methodology for software engineering
projects:

1. **Concept Note** — *why* and *what direction* (problem, vision, alternatives, decisions, PoC findings).
2. **Spec** — *what the system shall do, how it shall behave, and which solutions are admissible* (FRs in EARS, NFRs, TCs, scenarios in Given/When/Then, acceptance criteria).
3. **Implementation Plan** — *what to build, where, and in what order* (module map, file paths, signatures, branch plan, test plan, rollout).

Each document stands on its own. From any one, the previous or next can
be derived by a competent reader (human or AI). The methodology is
designed to be consumed by AI coding agents — every cross-reference uses
stable IDs (`D-*`, `FR-*`, `NFR-*`, `TC-*`, `AC-*`, `TD-*`, `S-*` and
`S-NN[a-z]*` variants, `T-*` and compound task IDs like `T-3.D8b`,
`OPEN-Q-*`) so agents can cite without paraphrasing.

A Requirements-Traceability + breadth/depth layer binds every
behavioural scenario, scenario variant, quantified NFR, and technical
constraint to a verification entry — a runnable test for scenarios,
variants, quantified NFRs, and mechanically verifiable TCs; a reviewer /
review-checklist citation for inherently non-mechanical TCs
(architectural standards, prose conventions). Spec §11.5 declares the
meta-ACs (`AC-50`/`AC-51`/`AC-52`); Plan §12.1 *Scenario Traceability
Matrix* maps every `S-NN` *and every variant `S-NNa`/`S-NNb`/…* to a
test, with the `Level` chosen per row from `unit / integration /
contract / e2e / property` via the decision-tree in
`skills/staged-engineering-doc/references/implementation-plan-guidance.md` §12 (no fixed pyramid
ratio prescribed); tests bind to Spec IDs via a tag convention recorded
in Plan §5; DoD `T-N.D8` + `T-N.D8b` (scenarios + Variants-block
presence), `T-N.D9` (NFRs), and `T-N.D10` (TCs) verify mechanically via
`grep` / `awk` / `comm`. This is the layer that closes the two most
common AI-agent failure modes — (a) features that pass unit tests but
miss enumerated requirements, and (b) scenarios that ship with one
happy-path test and no boundary / failure / concurrency / property
variant coverage.

## Install

### Claude Code (recommended)

In your Claude Code prompt, type:

```
/plugin marketplace add <owner>/<repo>
/plugin install engineering-methodology@<marketplace-name>
```

**The repository that hosts this plugin declares both values** — see its
root `README.md` for the two lines to copy. They are deliberately not
hardcoded here: this directory is mirrored between repositories, and an
install path baked into a mirrored file is wrong in every copy but one.

These are slash commands handled by the Claude Code client (not the
model), so an AI agent running inside Claude Code cannot run them on
your behalf — the human user has to type them.

### Other install paths

For Claude Code manual install (scripting / air-gapped) or for using
this procedure with other tools (Cursor, Aider, GEAI, …), see the
repo's [installation guide](../../README.md#installing-a-procedure).
After install, the `staged-engineering-doc`, `three-p-visualizer`,
`spec-answers`, and `spec-conformance` skills are auto-discovered inside
this plugin.

## Usage

Four skills, one per stage of a feature's life. Pick by what you want to do:

| You want to… | Skill | Needs |
|---|---|---|
| write or derive a methodology document | [`staged-engineering-doc`](#authoring--staged-engineering-doc) | nothing |
| explain the feature to stakeholders | [`three-p-visualizer`](#presenting--three-p-visualizer) | any methodology document — views degrade |
| ask what the docs say about the feature | [`spec-answers`](#querying--spec-answers) | any methodology document |
| check whether the code matches the Spec | [`spec-conformance`](#verifying--spec-conformance) | a Spec, plus the code |

Every skill is invoked in plain language — there are no slash commands. Say
what you want and the right one loads.

### Authoring — `staged-engineering-doc`

```
"Draft a concept note for {feature}."
"Turn this concept note into a spec."
"Generate an implementation plan from the spec."
"Back-derive the spec from this implementation plan."
"Fill the gaps in this draft spec."
```

- **What it does** — walks you through guided Q&A, reads the codebase for
  context, and produces or updates the document section by section.
- **Direction** — works both ways: forward (Concept → Spec → Plan) and
  backward (Plan → Spec → Concept), because each document stands alone.
- **Unknowns** — surfaced as `[OPEN-Q-N]` or `[INFERRED]` rather than guessed.

### Presenting — `three-p-visualizer`

```
"Visualize this spec as product, process and project."
"Build the 3P view of {feature}."
"Render the abstraction ladder for this system."
"Turn these engineering docs into an interactive explainer."
```

- **Output** — one self-contained HTML file, no build step.
- **Product** — what is built and how it operates, navigated as an
  abstraction ladder with NFR lenses.
- **Process** — the construction workflow: branch pipeline with gates,
  per-branch cycle, quality machine, rollout.
- **Project** — gate-driven timeline, cost structure, decisions, risk
  matrix, open questions, stakeholders.
- **Grounding** — every element cites the stable IDs it derives from.
- **Prerequisites** — all three documents give the fullest view, but a
  missing one is not a blocker: it says so up front and renders the
  affected view in reduced form (no Plan ⇒ the Process view shows only
  what the Concept Note supports, and the Project view omits the branch
  timeline). It never fabricates the missing document's content.

### Querying — `spec-answers`

```
"Does the feature support bulk upload?"
"Why did we pick queue-based ingestion over polling?"
"What's the latency budget for the extraction step?"
"Is multi-tenant isolation in scope?"
"Have we decided how retries interact with the dedup key?"
```

- **Sources** — the **Concept Note and Spec**: the contract, not the code.
  The Plan and the code are fallbacks, and any answer drawn from them is
  labelled `OUT-OF-SPEC` and reported as a probable Spec gap.
- **Status** — every answer carries exactly one, from a closed set:
  `ANSWERED`, `DERIVED`, `OPEN` (recorded as an unresolved `OPEN-Q-*`),
  `CONFLICTING` (two sources that should agree don't), `OUT-OF-SPEC`, or
  `NOT-SPECIFIED`. A precedence ladder decides which applies when several
  could, so the same question lands on the same status every time.
- **Gaps** — every status except `ANSWERED` and `DERIVED` is reported as a
  gap naming the section and ID family the missing content belongs to,
  plus an offer to hand off to `staged-engineering-doc`. It never edits
  what it reads.
- **Prerequisites** — no single document is mandatory. With only a Concept
  Note, behavioural questions come back `OUT-OF-SPEC` or `NOT-SPECIFIED`,
  and those gap notes become the inventory of what a back-derived Spec
  would have to cover. Given *no* methodology documents it declines rather
  than reading the code and presenting that as the contract.
- **Output** — conversational by default. A written Q&A report with pinned
  source commits is produced only on request, saved beside the documents
  it cites at `docs/{feature-slug}/{FEATURE}_QA_{YYYY-MM-DD}.md`.

A conflicting answer looks like this — both sides shown, neither picked:

```
The two documents disagree — this is not settled.

- Status: CONFLICTING
- Sources: Spec §7.1 `FR-012`, Concept §10 `D-04`
- Gap note: §18 Change log records neither as superseding the other, so
  the contradiction is live. `staged-engineering-doc` can reconcile them.
```

### Verifying — `spec-conformance`

```
"Does the code match the spec for {feature}?"
"Which requirements aren't implemented yet?"
"Audit the implementation against the spec."
"Find the implementation gaps in {feature}."
"What does the code do that the spec never sanctioned?"
```

- **Forward sweep** — every `FR-*`, `NFR-*`, `TC-*`, `S-*` (variants judged
  separately) and `AC-*` gets exactly one verdict from a closed set:
  `IMPLEMENTED`, `PARTIAL` (both halves named), `ABSENT` (with where it
  would live), `DIVERGENT` (the code contradicts the clause), or
  `UNVERIFIABLE` — ranked above `ABSENT`, so "couldn't check" is never
  reported as "isn't there". Each cites a `file:line` at a pinned SHA.
- **Reverse sweep** — behaviour in the feature's code surface that no ID
  sanctions is reported as `UNSPECIFIED-BEHAVIOUR` with its proposed Spec
  home. Nothing else in the methodology looks for this.
- **Denominator** — the whole Spec, never the subset the Plan's branch
  tracker claims shipped: a Plan wrong about what it shipped is exactly
  what the audit exists to catch. Which branch claimed an ID appears as
  context and never excuses a verdict.
- **Mechanical tier** — Phase 2 runs the methodology's *own* DoD gates
  (`T-N.D8`/`D8b`, `D9`, `D10`, `D15`–`D20`) rather than a parallel set,
  under the rule that a gate failure is evidence of a gap but a **gate
  pass is not evidence of an implementation**.
- **Prerequisites** — a Spec is required; it is the denominator. Without
  one the skill says so and offers `staged-engineering-doc` to back-derive
  it, rather than reconstructing a denominator from the implementation —
  a Spec read out of the code agrees with that code by construction.
- **Output** — a canonical `spec-conformance-data.json` plus a markdown
  matrix derived from it, so re-runs diff against the baseline. Both are
  written to the agent's scratchpad by default, not into the audited repo.
- **Read-only** — the audited feature is **never executed**: its bound
  tests are *read* to confirm they exist, never run, and an obligation only
  a run could settle is reported `UNVERIFIABLE` with the command named for
  a human. `DIVERGENT` findings name both remedies (fix the code, or amend
  the Spec) without picking one.

The matrix rows carry the evidence, one verdict each:

```
| FR-001 | IMPLEMENTED | `src/upload/service.py:142` — validates size before persisting |
| FR-004 | PARTIAL     | retry present at `service.py:210`, dead-letter path missing     |
| FR-010 | ABSENT      | would live in `src/upload/quota.py`; no quota logic anywhere    |
```

## Components

- **Skills:** (listed in lifecycle order — author, present, query, verify)
  - `staged-engineering-doc` — produces or derives any of the three
    methodology documents (Concept Note, Spec, Implementation Plan)
    through guided Q&A and codebase research.
  - `three-p-visualizer` — renders the three documents as an interactive
    Product / Process / Project HTML explainer.
  - `spec-answers` — answers questions about a documented feature from its
    Concept Note and Spec, with cited IDs, an explicit answer status, and
    pinned source provenance.
  - `spec-conformance` — audits the codebase against the Spec, forward
    (every obligation → `file:line` evidence, one verdict each) and
    backward (code behaviour no ID sanctions), pinning both sides.
- **Commands:** none.
- **Agents:** none.
- **Hooks:** none.
- **MCP servers:** none.

### Extensions

Extension plugins specialize this methodology without forking it: they cite
this plugin's stable IDs and add their own requirement-tier documents. Two
skills accept a complementary mapping file that **extends, never replaces**
the base:

- `three-p-visualizer` — loads an extension's `visualizer-mapping.md`
  alongside its own `content-mapping.md` (SKILL Step 2).
- `spec-answers` — loads an extension's `answers-routing.md` on the same
  terms. None ships one yet, so extension documents are answered from their
  own section titles rather than reported as unspecified.

A third needs no mapping file:

- `spec-conformance` — sweeps an extension's requirement-tier documents
  alongside the Spec, on the same discovery rule.

**Known extension:**
`migration-methodology` — legacy
migrations (Migration Charter, Parity Plan, Cutover Plan, execution
Workflows).

## Configuration

None. `staged-engineering-doc` reads project conventions from `AGENTS.md`
(or equivalent) at runtime. `spec-answers`, `spec-conformance`, and
`three-p-visualizer` locate the feature folder by convention
(`docs/{feature-slug}/`, or whatever layout the project's `docs/` already
uses) — point them at the folder directly if it lives elsewhere.
`spec-answers` also reads the git history of the documents it consults to
pin each answer's provenance; uncommitted drafts still work, and are
reported as `uncommitted (working tree)` rather than as a commit.

`spec-conformance` pins both sides, so it additionally creates a detached
git worktree of the code repo at the audited revision — under a repo-local
persistent path such as `.claude/worktrees/`, never under `/tmp`, which
macOS purges. Evidence is cited as repo-relative path + line + SHA, so the
citations survive the worktree's removal. It reads Plan §5 for the project's
test-binding convention (`@pytest.mark.scenario("S-04")`, `it("S-04: …")`,
…) and infers it if §5 does not record one. The audited feature is never
executed: its bound tests are *read* to confirm they exist, never run, and an
obligation only a run could settle is reported `UNVERIFIABLE` with the command
named for a human.

**The documents and the code may live in different repositories.** They often
do — a docs repo beside a service repo. `spec-conformance` pins each side
separately, so tell it which repo holds the code if it is not the one you are
working in; the worktree is created there, not next to the documents.

**Where the output goes.** `spec-conformance-data.json` and the rendered
markdown are written to the **agent's scratchpad by default, not into the
audited repository** — an audit should not dirty the tree it is measuring.
Ask for them somewhere specific if you want them kept; writing any file inside
the audited repo is a step the skill asks about first.

## Design

See [`DESIGN_RATIONALE.md`](DESIGN_RATIONALE.md) for the methodology's
design decisions (`MD-01`–`MD-32`), research summary,
and the rationale behind every structural choice. Onboard new
contributors with that document.

## Changelog

| Version | Date | Change |
|---|---|---|
| 0.15.0 | 2026-08-17 | Added a **closed-set consistency gate** (`MD-32`) — promoted from `EVO-08`. The four skills (`staged-engineering-doc`, `three-p-visualizer`, `spec-answers`, `spec-conformance`) enumerate two coupled closed sets — the meta-ACs (`AC-50`..`AC-<max>`) and the DoD gates (`T-N.D1`..`T-N.D<max>`) — and when one gains a member, every enumeration site across the skills must move together. Adding `MD-31`'s `AC-55` / `T-N.D20` missed or half-did that propagation in **three consecutive review rounds**, the third time inside the commit fixing the second; *"a half-propagated closed set is worse than an un-propagated one"* because a skill declaring a member its own sibling reference doesn't know about reads as a silent pass. New `scripts/closed-set-consistency.sh` reads the canonical maxima from the two templates and asserts **currency** (any enumeration reaching the penultimate member also reaches the newest; any `<N> meta-ACs:` count matches) and **presence** (the load-bearing sites — spec-conformance's gate table / partition / verdict-source list / citation axes, the visualizer meta-gates card, the two guidance AC→gate maps — carry the newest member). Intentional subsets opt out with an inline `closed-set:subset` marker (declared-none-visible, per `MD-25`). Written **test-first**: passes on the current tree, catches all four drift classes on a deliberately-broken copy — and the build re-learned the `MD-28` BSD-portability lesson (a first-draft GNU-only `\b` silently matched nothing and let injected drift pass; the test caught it). Records as `MD-32` in `DESIGN_RATIONALE`; closes `EVO-08` in §6. Version bumped 0.14.0 → 0.15.0. |
| 0.14.0 | 2026-08-03 | Added **Security as a design consideration in the trifecta** (`MD-31`) — a three-touchpoint discipline that shapes the design of the software being specified (not the agent running the methodology). New Concept Note **§5.2 *Security posture*** with three lines (feature exposure / data sensitivity / deployment surface) that shape the design and select which CWE categories the Spec must address. New Spec **§4.5 *Security constraints*** for security-shaped `TC-*` rows citing `CWE-XX` verbatim (e.g. `defends CWE-22 Path Traversal`) — these are constraints on the solution, not just tests to run — plus new meta-**`AC-55`** for supply-chain integrity. New Plan **`T-N.D20`** — mechanical CVE gate via `osv-scanner --lockfile={{path/to/lockfile}}` (or language-native equivalents `npm audit`, `pip-audit`, `cargo audit`, `govulncheck`, `bundle audit`) — the mechanical floor beneath the design work. It gates on the scanner's **exit code** (non-zero on *any* advisory, which is what all these tools do natively); **severity judgement lives in the `R-*` waiver**, not a gate threshold. A branch with no lockfile declares `Supply-chain: none — <reason>` in Plan §5 (the `MD-28` `Binding:`-token shape) and passes vacuously; an *undeclared* token is 🔴. `AC-55` is settled by `spec-conformance` on a **third citation axis** (the Plan's recorded gate state — checkbox + §5 token + §14 `R-*` — read, never re-run, which keeps the verdict reproducible at a pinned SHA even though `T-N.D20` is the one deliberately time-varying gate). **Structural floor, not ceiling** — MD-31 mandates one closed vocabulary (CWE) and one gate (CVE lockfile). Threat modeling / secure design patterns / penetration testing / SAST / DAST / secret scanning / AI-agent hardening all remain legitimate additions above the floor per feature complexity, declared in Concept §5.2 or as additional §4.5 TCs. **No security-standard snapshots embedded** — the doctrine's URLs (`cwe.mitre.org/top25/`, `owasp.org/www-project-application-security-verification-standard/`, `csrc.nist.gov/pubs/sp/800/218/final`, `slsa.dev/spec/`, `genai.owasp.org/llm-top-10/`) resolve to current-stable and are retrieved live over HTTPS at authoring / review / gate-run time; a `[UNVERIFIED — offline; last known <standard> as of <date>]` marker per `MD-26` is 🟡, not 🔴. Backed doctrinally by NIST SSDF `PW.1` (title verbatim: *"Design Software to Meet Security Requirements and Mitigate Security Risks"* — the verb is *design*) and `PW.1.1` (*"Use forms of risk modeling – such as threat modeling, attack modeling, or attack surface mapping – to help assess the security risk for the software"*), OWASP ASVS's chapter × requirement × 3-level pattern, Threat Modeling Manifesto's 4 questions, and empirically by the CWEval benchmark (arXiv `2501.08200`) showing AI-authored code has a measurable, class-distributed security deficit. Peer-methodology gap verified: none of OpenSpec / GitHub Spec Kit / AWS Kiro / BMAD-METHOD / Coleam00 PRP bakes security into core artifacts as of 2026. New shared reference file `skills/staged-engineering-doc/references/security-protocol.md`. `critic-rubric.md` Dim 5 extended with a *Security posture (`MD-31`)* row whose clauses are each scoped to the doc they apply to (a Spec/Plan critiqued alone is never docked for a Concept's missing §5.2): missing Concept §5.2 🔴, in-scope CWE with no §4.5 TC and no ruling 🔴, Plan `T-N.D20` unchecked with no waiver / no offline marker / no `Supply-chain: none` token 🔴, posture drift 🟡, disclosed-offline `[UNVERIFIED — offline; …]` marker 🟡 per `MD-26`. Scope declared explicitly: this MD is about the software being specified, not about the agent running the methodology — the distinction lives verbatim at the top of `security-protocol.md`. Also bumps two stale `T-N.D1–T-N.D19` range references in the Plan template to `T-N.D1–T-N.D20`. Records as `MD-31` in `DESIGN_RATIONALE`. Version bumped 0.13.0 → 0.14.0 on top of PRs #23 / #22 / #21 (`MD-28` / `MD-29` / `MD-30`) which landed just before this. |
| 0.13.0 | 2026-08-03 | Added the `spec-conformance` skill (`MD-30`) — audits a feature's **code** against its committed **Spec**, closing the last open direction of the methodology (authoring = `staged-engineering-doc`, presentation = `three-p-visualizer`, query = `spec-answers`, verification = `spec-conformance`). Its invariant is **two-sided grounding**: every verdict names both the Spec ID it judges and the `file:line` in a pinned checkout it was judged against — borrowing `issue-triage`'s no-verdict-without-evidence rule and pointing it at `FR-*`/`AC-*` rows instead of GitHub issues. **Forward sweep**: every `FR-*`, `NFR-*`, `TC-*`, `S-*` (variants judged separately per `MD-22`) and `AC-*` gets exactly one verdict from a **closed five-term set** — `IMPLEMENTED` / `PARTIAL` (both halves named) / `ABSENT` (with the section it would live in) / `DIVERGENT` (code contradicts the clause) / `UNVERIFIABLE` — settled by a precedence ladder that ranks `UNVERIFIABLE` **above** `ABSENT`, so "could not check" is never reported as "is not there". **Reverse sweep**: behaviour inside a bounded code frontier (Plan §4 module map + Phase 3 evidence + feature-attributable commits + one public-surface hop) that no ID sanctions is `UNSPECIFIED-BEHAVIOUR` with its proposed Spec home — the only place in the methodology that looks for a Spec falling behind its own code. `DIVERGENT` and `UNSPECIFIED-BEHAVIOUR` stay distinct terms because one is anchored to a contradicted ID and the other has no anchor at all — the difference between fixing code and amending a Spec. The **denominator is the whole Spec, unconditionally**: restricting it to what Plan §7.1's branch tracker claims merged would let the Plan grade its own homework, and a Plan wrong about what it shipped is precisely the condition being detected — branch attribution therefore appears as a context column that never filters or excuses a verdict. Phase 2 **runs the methodology's own DoD gates** (`T-N.D8`/`D8b`, `D9`, `D10`, `D15`–`D19`, `AC-50`–`AC-54`) rather than a parallel set that would drift from them, under the governing rule that a gate *failure* is evidence of a gap but a **gate *pass* is not evidence of an implementation** — and the gate table marks which gates measure Spec ↔ code versus Spec ↔ *Plan*, since three of them never read code. Records that `FR-*` has **no mechanical gate anywhere in the methodology** (`AC-50`/`51`/`52` cover `S-*`/`NFR-*`/`TC-*` only), making the largest family entirely dependent on the grounded tier. Canonical output is `spec-conformance-data.json` with the markdown matrix derived from it — `triage-data.json`'s role — so re-runs diff against the baseline and re-verify only IDs whose cited code moved. **Read-only**: the audited feature is **never executed** — bound tests are *read* to confirm the binding exists (that is what the DoD gates measure), never run, and an obligation only a run could settle terminates in `UNVERIFIABLE` naming the command a human would run; `DIVERGENT` names both remedies and picks neither; no numeric conformance percentage (`MD-23`). **Evidence integrity** (both added after a measured failure): candidate files come from `git ls-files` at the pinned SHA rather than a recursive walk — one audited repo held 35 nested worktrees, turning a single function into 147 grep hits across six branches — and every ID enumeration uses one anchored form, because a bare prefix grep matches inside a longer one (`FR-` inside `NFR-`, `S-` inside `US-`/`OBS-`, `D-` inside `TD-`/`MD-`), which both invents IDs and hides real ones. **Determinism**: two runs of the same feature at the same SHA first disagreed on 20 % of verdicts, so three rules were added — the **worst clause** sets a multi-clause verdict (a clause quoting a literal absent from the code is *contradicted*, not merely unmet), a clause is judged on its **literal subject**, and where two defensible readings disagree the narrow one is the verdict with the broad one recorded in `alternate_reading`. Residual drift fell to 4 %, and the rows still carrying an `alternate_reading` proved to be Spec self-contradictions rather than auditor noise. Reproducibility is a goal the rules serve rather than a claim: every re-run re-verifies a **control sample**, since a carry-forward otherwise confirms its own previous answer by construction. Gate results form their own closed set (`pass` / `fail` / `unscoped-pass` / `no-convention` / `not-applicable`) so an unscopeable gate never renders as a tick. Purely additive: no template, gate, or existing skill changes. |
| 0.12.0 | 2026-08-03 | Added the `spec-answers` skill (`MD-29`) — answers questions about a documented feature by reading its committed **Concept Note and Spec** back, closing the read side of the methodology (authoring = `staged-engineering-doc`, presentation = `three-p-visualizer`, query = `spec-answers`). Concept + Spec are **authoritative**; the Implementation Plan and the code are permitted fallbacks but every answer sourced from them is labelled `OUT-OF-SPEC` and reported as a probable Spec gap — this preserves the `MD-01` / Spec §17 what-vs-how division instead of flattening all three docs into one corpus. Every answer cites section + stable ID and carries exactly one status from a **closed seven-term set**: `ANSWERED` / `DERIVED` (inference shown, both endpoints named) / `OPEN` (quotes the recorded `OPEN-Q-*`) / `CONFLICTING` (both sides shown, neither picked) / `OUT-OF-SPEC` / `PLAN-TERRITORY` (not a spec question at all — module layout, build order, shipped-state; the Spec is *correctly* silent, so no gap is raised) / `NOT-SPECIFIED`. Closed for the same reason as `MD-22`'s kind-tags and `MD-24`'s diagram vocabulary — "the docs don't say" must be a checkable outcome, not a hedge; `NOT-SPECIFIED` is first-class output, the read-side application of `MD-10`. Sources are **pinned** at read time (path + last-touching commit, flagged when the working tree is dirty, + the *latest* Change-log row — rows are appended, so the newest is the bottom one) so a stale answer is visibly stale — borrowed from the sibling `issue-triage` procedure's grounding invariant. The skill is **read-only**: for `NOT-SPECIFIED` / `OUT-OF-SPEC` / `CONFLICTING` / `OPEN` it names the exact home for the missing content ("an `FR-*` in Spec §7", "a `TC-*` in §4") and *offers* the handoff to `staged-engineering-doc`'s iterate-on-existing-draft path, acting only on explicit go-ahead — matching `MD-23`'s "the critic does not rewrite the doc". No numeric confidence scores (`MD-23` calibration argument). Conversational by default; a written report with a provenance header and a *Gaps surfaced* roll-up only on request. Bundles `references/question-routing.md` (18-row question-intent → doc-section → ID-family map with nine resolution rules — glossary first, follow the cross-reference chain, Spec wins for behaviour and Concept for rationale, check §18 before declaring a conflict) and `references/report-shape.md`. Extension plugins may ship a complementary `question-routing.md` that extends — never replaces — the base map, same mechanism `three-p-visualizer` uses for `visualizer-mapping.md`; none ships one yet, so extension documents are answered from their own section titles rather than reported as unspecified. Purely additive: no template, gate, or existing skill changes. |
| 0.11.0 | 2026-08-03 | Corrected the mechanical DoD gates so they verify what their acceptance criteria claim (`MD-28`). **`T-N.D19` and `review-passes.md` Passes 1 and 2 now enumerate IDs with a left-anchored regex.** A bare `grep -oE "<PREFIX>-[0-9]+"` matches *inside* a longer prefix, so `D-` hit `TD-`/`MD-`, `S-` hit `US-`/`OBS-`, and `FR-` hit `NFR-`. Run over the shipped templates the old recipe reported `D-12`/`D-27` as dangling Concept decisions (they are `MD-12`/`MD-27`) and `S-03` as a dangling scenario (it is `OBS-03`) — and `T-N.D19` is a **merge gate**, so every Plan citing methodology decisions or carrying `OBS-*` rows failed against fabricated IDs. It went unnoticed because for `FR-` the phantoms appear on both sides of the `comm` and cancel. **New `T-N.D10b`** gates `AC-52`'s second conjunct (every `TC-*` in Spec §4 also has a §11.3 compliance check); `T-N.D10` checked only the Plan §12 half, so a Spec with an empty §11.3 passed while reporting its traceability intact. **`AC-50`'s §16 clause is relaxed to reviewer-checked** rather than gated — it cannot be mechanised, because §16 legitimately cites scenario *ranges* (`covers S-01..S-09`) and a `comm` against enumerated IDs fails the template's own example; the defect was an AC promising enforcement that could not exist. **Plan §5 gains a closed `Binding:` token** (`variant-a` / `variant-b` / `none`) that `T-N.D8`/`D9` read to select their regex — the two variants are not interchangeable, and running the wrong one silently reports *every* scenario as uncovered, yet the choice was previously recorded in unparseable prose. Additive and non-breaking: no ID scheme changes, no existing Plan or Spec invalidated; old Plans gain one unchecked DoD box and one §5 row. Version bumped 0.10.0 → 0.11.0. The `none` token is given semantics rather than left merely declarable: it means the branch has **nothing to bind** (no in-scope scenarios, no quantified NFRs), so `T-N.D8`/`D9` stay mechanical and pass vacuously. It is **not** an opt-out from binding — Spec `AC-50`/`AC-51` require a structurally-anchored binding and Spec §17 lists both as non-relitigable, so a branch with scenarios that declares `none` fails `T-N.D8`. Migrating an existing Plan means picking the token its tests *already* use. `T-N.D10b`'s section range is matched heading-level-agnostically (`sed -nE '/^#{2,4} +11\.3/,…'`, portable to BSD `sed`) so a future renumbering cannot empty the range and fail the gate against a compliant Spec. |
| 0.10.0 | 2026-07-23 | Added **Trust but verify** (`MD-26`) — promoted from `EVO-06` after the pattern recurred 6+ times on subsequent features. Introduces the `[UNVERIFIED — <one-line reason>]` marker parallel to `MD-10`'s `[INFERRED]` / `[OPEN-Q-N]` markers: every external claim (arXiv IDs, DOIs, paper findings, CLI flags, syntax forms, peer-framework quotes, standard-clause text) and every internal claim (`<repo>/path:LN` citations, cross-doc references) must be either verified against its primary source at authoring time or explicitly tagged `[UNVERIFIED]` with a legitimate reason. New shared reference file `skills/staged-engineering-doc/references/verification-protocol.md` documents what to verify per claim class, legitimate-vs-illegitimate `[UNVERIFIED]` reasons, and how the marker differs from `[INFERRED]` and `[OPEN-Q-N]`. Critic-rubric Dim 5 extended with a *Trust but verify (MD-26)* row scoring fabricated citations 🔴, un-flagged unverifiable claims 🔴, illegitimate `[UNVERIFIED]` reasons 🔴 (treated as if the marker were absent, per verification-protocol.md), missing handoff citation 🟡. Enforcement is structural (marker convention) + rubric (Dim 5 row), deliberately not mechanical — no shell gate can distinguish a fabricated arXiv ID from a real one without a live HTTP fetch. Extends MD-25 §6.5's arXiv-verification check symmetrically to all citations. Records as `MD-26` in DESIGN_RATIONALE §5 and closes `EVO-06` in §6. Version bumped 0.9.0 → 0.10.0 (skipping planned 0.7.0) since PR #16 (`MD-27`) merged first out of order and took 0.8.0; 0.6.0 and 0.7.0 slots remain intentionally unused. |
| 0.9.0 | 2026-07-23 | Added mandatory grounding-discipline layer (`MD-25`). New Concept Note §6.5 *Sources & Origins* section with three closed sub-lists (**Codebase evidence** — repo paths read + one-line "what this pinned" notes; **Industry-standard evidence** — regulatory/architectural/style standards checked; **Prior-art evidence** — peer products, prior features, papers). Empty sub-list must be declared explicitly as `<sub-list> evidence: none — <reason>` (e.g. `Codebase evidence: none — greenfield feature`); silent absence is disallowed. SKILL.md Step 3 restructured into a numbered *Research Process* — 3.1 Codebase Analysis, 3.2 Industry-Standard Analysis, 3.3 Prior-Art Analysis, 3.4 Question-set fill — with an ALL-CAPS `*** CRITICAL — DO NOT PROCEED TO STEP 4 UNTIL SOURCES & ORIGINS IS POPULATED ***` barrier before drafting. Spec/Plan cite stage-specific grounding evidence inline and reference Concept §6.5. Critic-rubric extended with a Grounding-evidence row (all-docs Dim 5) and a §6.5 Sources & Origins row (Concept-specific Dim 5.1). Enforcement is structural + rubric — deliberately not mechanical, since no peer framework or 2025-2026 paper implements a shell-level grounding gate. Backed by CPRE Foundation v3.2 §4.1 (L3 "apply"), SWEBOK v4 §2.1 *Requirements Sources*, ISO/IEC/IEEE 25010 (via CPRE §4.2), pre-RS traceability lit (Gotel & Finkelstein 1994; Mucha et al. Springer RE 2024), Spec Kit constitution.md template-directive pattern, and PRP framework Research Process + CRITICAL barrier. Records as `MD-25` in DESIGN_RATIONALE. Version bumped 0.5.1 → 0.9.0 (skipping planned 0.6.0) after PR #16 (`MD-27`) merged first out of order, taking 0.8.0. 0.6.0 and 0.7.0 slots remain intentionally unused; 0.9.0 keeps semver monotonic above main. |
| 0.8.0 | 2026-07-17 | Added right-sized Implementation Plan §7.0 *Branch sizing* (`MD-27`) — promotes `EVO-05`. Plan §7 now opens with an `Arc:` declaration picked from a **closed arc vocabulary** — `refactor-1` / `single-branch` / `two-branch-backend-ui` / `three-branch-scaffold-core-rollout` / `five-branch-default` / `migration-5` — plus an explicit escape declaration `Custom arc: <N> branches — <reason>` for legit outliers (following MD-22's `Variants: none — <reason>` pattern). Arc picked from a top-down first-match-wins decision tree keyed off Spec signals (refactor-only → `refactor-1`; migration → `migration-5`; cross-service producer/consumer pair → `five-branch-default`; progressive-rollout NFR without cross-service change → `three-branch-scaffold-core-rollout`; backend + user-facing UI → `two-branch-backend-ui`; ≤3 FRs + single-service + no migration → `single-branch`; fallthrough → `three-branch-scaffold-core-rollout`). §7.1 tracker + branch-graph shapes derive from the arc choice, not fixed at 5 branches. `MD-06` (branch-with-flag), `MD-12` (base off trunk), `MD-15` (DoD-as-tasks), `MD-16` (commits-as-tasks) unchanged — only the branch count Plans default to changes. Rubric extended with a `Branch sizing (MD-27)` row: missing declaration or off-vocabulary arc → 🔴; arc-vs-signal mismatch → 🟡. Enforcement is **structural + rubric** — signals are semi-mechanical; shell gate would produce false positives at the "backend + UI" and "progressive-rollout NFR" boundaries. Existing Plans authored before v0.8.0 keep their current arc — grandfathered. Version jumps from 0.5.1 → 0.8.0 to leave 0.6.0 / 0.7.0 reserved for pending PRs #14 (grounding discipline `MD-25`) and #15 (trust but verify `MD-26`). Records as `MD-27` in `DESIGN_RATIONALE`; closes `EVO-05` in §6. |
| 0.5.1 | 2026-06-10 | `three-p-visualizer` now loads **complementary mappings** from extension plugins (SKILL Step 2): an extension may ship a `visualizer-mapping.md` in the same table format that extends — never replaces — the base `content-mapping.md`, including extra honesty rules. Documented the extension mechanism in README §Extensions; first known extension is `migration-methodology`. |
| 0.5.0 | 2026-06-10 | Added the `three-p-visualizer` skill — derives an interactive, single-file HTML explainer from the three methodology documents, organized as the 3 Ps of software engineering: **Product** (abstraction ladder from system context down to functions/rules, plus NFR lenses cutting across levels — runtime operation is part of the Product), **Process** (branch pipeline with human gates, per-branch cycle, quality machine, rollout stepper), and **Project** (gate-driven timeline, qualitative cost structure, sealed decisions, risk matrix, open questions, stakeholders). Bundles `skills/three-p-visualizer/references/content-mapping.md` (doc-section → view extraction map) and `skills/three-p-visualizer/references/page-scaffold.md` (browser-verified interaction building blocks: pan-zoom SVG, detail drawer, ladder, byte bars, simulators). |
| 0.4.0 | 2026-06-02 | Added a mandatory two-pass consistency check to SKILL.md Step 5 (`MD-21`) — self-consistency (`T-N.D18`) and cross-consistency (`T-N.D19`), appended at the tail so the operational gates keep their IDs. Recipes live in `skills/staged-engineering-doc/references/review-passes.md` (kept out of SKILL.md per `MD-13`). The passes enforce *referential integrity* (every referenced ID resolves to a definition; no dangling cross-doc references) and explicitly **not** gap-free numbering, since the templates use non-contiguous IDs by design. Plan DoD now `T-N.D1`–`T-N.D19`. |
| 0.3.0 | 2026-05-30 | Added operational-traceability layer. Plan §11 *Observability* promoted to `OBS-NN` rows binding to NFRs/scenarios/risks (`MD-19`); §14 *Risks* promoted to `R-NN` rows with a mandatory mitigation path — task, `accepted`, or `monitored only` (`MD-18`); new §12.2 *Impact Traceability* with `IMP-NN` rows and closed-vocabulary `scope` field, recorded at feature granularity (`MD-20`); Spec §11.5 expanded with `AC-53` (impact per affected scope) and `AC-54` (NFRs → observability); new DoD gates appended at the tail — `T-N.D15` (impact) / `T-N.D16` (observability) / `T-N.D17` (risk) — so the existing `T-N.D11`–`T-N.D14` cleanup gates keep their IDs. Plan DoD now `T-N.D1`–`T-N.D17`. |
| 0.5.0 | 2026-06-17 | Added closed diagram vocabulary — Mermaid-only text diagrams with per-doc per-section type assignments. **Required** diagrams: Concept §5.1 `C4Context` (when the feature crosses ≥2 system boundaries); Spec §10.1.1 `erDiagram` (when ≥1 new entity); Plan §3 architecture (C4 Component for agentic features, otherwise `flowchart` for structural or `sequenceDiagram` for behavioural); Plan §7.1 branch graph (`flowchart`/`gitGraph`, replaces the legacy ASCII arrow diagram); Plan §8.2 migration `stateDiagram-v2` (when migrations are present); Plan §9.2.1 cross-service `sequenceDiagram` (when a new producer/consumer pair is introduced). **Optional** diagrams: Concept §9.4 comparison `flowchart`; Spec §9 scenario `sequenceDiagram` / `stateDiagram-v2`. **Banned**: PNG/SVG/external images, ASCII art, `activityDiagram` (worst comprehension; overlaps `sequence`/`state`), Container-only C4 L2 for agentic features. ≤15 elements per diagram (precise unit per diagram type — nodes for `flowchart`, entities for `erDiagram`, messages for `sequenceDiagram`, states for `stateDiagram-v2`; methodology ceiling informed by SADU's reported monotonic accuracy decline with diagram size). Critic-rubric Dim 5 extended with per-doc diagram-conformance rows. Records as `MD-24` in DESIGN_RATIONALE. |
| 0.4.0 | 2026-06-11 | Added critic-eval layer — single normative rubric (`skills/staged-engineering-doc/references/critic-rubric.md`) drives both Step 5 *self-critique* (author's model, pre-save) and a new Step 7 *independent critique* (different model family, standalone invocation). The skill now has two **invocation modes** routed at Step 1: *authoring* (Steps 1–6) and *critique* (Step 7 standalone, skips Steps 2–6 since the doc already exists). **Both passes are opt-in**: the skill prompts the user at the start of Step 5 and at the end of Step 6; runs only on explicit acceptance. Step 7.0 gates model independence by prompting the user for both critic and author models and defaulting to abort on same-family. Rubric has a per-doc half (Accuracy / Consistency / Completeness / Clarity / Methodology-invariants — with doc-type-specific check tables) and a cross-doc half (Decision propagation / Behaviour coverage / AC coverage / No silent drift / Reverse-derivability). Findings + severity buckets (🔴/🟡/🔵); no numeric scores. Records as `MD-23` in DESIGN_RATIONALE. |
| 0.3.0 | 2026-06-10 | Added test breadth + depth coverage — Spec §9 *Variants* sub-block per scenario (parent scenario IS the happy path; letter-suffixed variant IDs `S-NNa`, `S-NNb`, … with the closed four-tag set `[boundary] / [failure] / [concurrency] / [property]` for shifts away from the parent); Plan §12.1 *Level* vocabulary extended to `unit / integration / contract / e2e / property` (multi-value rows allowed) with a top-down per-scenario decision-tree in `skills/staged-engineering-doc/references/implementation-plan-guidance.md` §12; `T-N.D8` regex extended to `S-[0-9]+[a-z]*` so variants are mechanically gated. No fixed pyramid ratio prescribed. Records as `MD-22` in DESIGN_RATIONALE. |
| 0.2.0 | 2026-05-14 | Added Requirements-Traceability layer — Spec §11.5 *Test obligations* (`AC-50`/`AC-51`/`AC-52`), Plan §12.1 *Scenario Traceability Matrix*, §16 AC matrix `Test` column, tag-binding convention, and mechanical DoD gates (`T-N.D8` scenarios / `T-N.D9` NFRs / `T-N.D10` TCs). Records as `MD-17` in DESIGN_RATIONALE. |
| 0.1.0 | 2026-05-06 | Initial release — migrated from `sw-engineering-docs-methodology` repo. |
