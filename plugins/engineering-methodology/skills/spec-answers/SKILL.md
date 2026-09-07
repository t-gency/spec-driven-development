---
name: spec-answers
description: Answer questions about a feature that was specified with the engineering methodology, from its committed Concept Note and Spec. Every answer cites the stable IDs it rests on (D-*, FR-*, NFR-*, TC-*, S-*, AC-*) and carries an explicit status — including NOT-SPECIFIED when the docs genuinely do not answer. Triggers on questions about a documented feature — "what does the spec say about X", "does it support Y", "why did we decide Z", "what happens when …", "is X in scope", "how fast / how secure must it be", "what are the acceptance criteria", "has X been decided yet". Not for authoring or critiquing the docs (see staged-engineering-doc) or rendering them (see three-p-visualizer).
---

# Spec answers — query a feature's Concept Note and Spec

This skill answers questions about a feature documented with the 3-stage
methodology (Concept Note → Spec → Implementation Plan, see the sibling
`staged-engineering-doc` skill) using the **Concept Note and Spec** as the
authoritative sources.

Its one invariant is **grounded answers**: no claim without a citation to a
document section or stable ID, and an explicit status on every answer. A Spec
nobody can query becomes a write-only artefact; a Spec answered from memory or
from the code becomes a different contract than the one that was agreed.

**Why Concept + Spec and not the Plan.** The Spec is the behavioural contract
(*what shall it do*), the Concept Note is the rationale (*why this way*). The
Implementation Plan is *how it gets built* — a different question with a
different answer. The division is `MD-01`'s three-document chain, made concrete
by Spec §17 *Handoff*, which lists what the Plan must respect and what it has
freedom to decide. The Plan and the code are permitted **fallbacks**, but an
answer sourced from them is always labelled `OUT-OF-SPEC`, never presented as a
spec commitment.

## When to invoke

Use this skill whenever the user asks a **question about a feature** that has
methodology docs in the repo:

- what the system must do, or what happens in a given situation
- why a direction was chosen, or what alternatives were rejected
- what quality bar applies (latency, availability, security posture)
- what is in or out of scope
- what a domain term means in this feature's vocabulary
- what the acceptance criteria are
- whether some question has been decided yet

Do **not** use it to draft, derive, iterate on, or critique the documents —
that is `staged-engineering-doc`. Do not use it to render them — that is
`three-p-visualizer`.

## Bundled files

```
spec-answers/
├── SKILL.md                    ← this file (always loaded)
└── references/
    ├── question-routing.md     ← question intent → doc §/ID family (load in Step 2)
    └── report-shape.md         ← written-report format (load in Step 6, only on request)
```

All paths are relative to the skill directory.

## Answer-status taxonomy

Every answer carries exactly one status from this **closed set**. The set is
closed for the same reason the variant kind-tags of `MD-22` and the diagram
vocabulary of `MD-24` are closed: "the docs don't say" must be a checkable
outcome, not a hedge the model rephrases differently every time.

**Authoritative sources** are the Concept Note, the Spec, and — when the
feature uses an extension methodology — that extension's equivalent
requirement-tier documents (e.g. `migration-methodology`'s Migration Charter,
Parity Plan, Cutover Plan). They state what was agreed. The Implementation Plan
and the code are **non-authoritative**: they state what gets built.

- **ANSWERED** — stated in an authoritative document. Cite every ID the answer
  rests on.
- **DERIVED** — not stated verbatim, but entailed by cited authoritative
  content. Show the reasoning and every endpoint it passes through, so the
  reader can check each hop.
- **OPEN** — an authoritative document records this as unresolved. Quote the
  `OPEN-Q-*` verbatim, **qualified by its document**, with its target stage and
  owner.
- **CONFLICTING** — two sources that should agree do not: the Concept Note
  against the Spec, two sections of the *same* document, or an authoritative
  document against the Plan or the code. Present every side with citations.
  Never pick one silently, and never let one side's phrasing (an explicit
  exclusion, say) settle it on its own.
- **OUT-OF-SPEC** — the answer exists, but only in the Implementation Plan or
  the code. Name the source, state plainly that it is an implementation fact
  rather than a commitment, **and raise it as a gap** (Step 5) — a behavioural
  fact living only downstream means the Spec is incomplete.
- **PLAN-TERRITORY** — the question is not a Spec question at all. Module
  layout, build order, branch sequence, and whether something is shipped yet
  belong to the Implementation Plan and the code *by design* — Spec §17
  *Handoff* grants the Plan freedom over "module layout, internal class
  structure, file paths, design pattern choices". Answer it from the Plan or the
  code, name the source, and say plainly that the Spec is **correctly** silent.
  If the Plan does not answer either, say so — it is still `PLAN-TERRITORY`,
  never a Spec gap. This is the one non-`ANSWERED` status that raises **no** gap
  note.
- **NOT-SPECIFIED** — absent from every source consulted, authoritative or not.
  Name the section and ID family where the answer *would* belong.

Two statuses are first-class answers rather than failures: `NOT-SPECIFIED`,
and `OUT-OF-SPEC`. Both feed Step 5.

`OUT-OF-SPEC` and `PLAN-TERRITORY` are the pair most easily confused, and the
distinction is the whole point of the split: `OUT-OF-SPEC` is a **behavioural
commitment** that leaked downstream and therefore a real Spec gap;
`PLAN-TERRITORY` is an **implementation fact** that was never the Spec's to
hold. Routing the second into the first manufactures "the Spec is incomplete"
notes against documents that are correct.

**Precedence when more than one status could apply** — take the first that
matches:

1. Any authoritative source contradicts another source **that this question
   required** → `CONFLICTING`. Scope this to the sources consulted for the
   question at hand, not everything loaded for the batch: if the Spec answers
   it, the Plan was never needed and a Plan disagreement does not make it
   `CONFLICTING`, even when an earlier question in the same session had a
   legitimate reason to read the Plan. Otherwise the same question over the
   same documents would land on a different status depending on what was asked
   before it, which is exactly what the ladder exists to prevent.
2. An authoritative document states it → `ANSWERED`.
3. An authoritative document entails it → `DERIVED`.
4. An authoritative document records it unresolved → `OPEN`.
5. The routing table marks the question as *not a spec question* (rows 16, 17)
   → `PLAN-TERRITORY`, whether or not the Plan answers it.
6. Only the Plan or the code answers → `OUT-OF-SPEC`.
7. Nothing answers → `NOT-SPECIFIED`.

Rung 5 sits above rung 6 deliberately: without it, every "which module?" or
"is this shipped?" over a *compliant* Spec would land on `OUT-OF-SPEC` and
generate a gap note demanding the Spec absorb content Spec §17 hands to the Plan.
Rungs 2–4 still outrank it, so a question that an authoritative document does
happen to answer is answered, not deflected.

This ladder is what makes the set checkable: the same question over the same
documents must land on the same status every time.

## Workflow

**Recommended effort per step.** Defaults, not requirements — re-sweep them on
your own evals, and ignore them if your harness has no effort control.

| Step | Effort | Why |
|---|---|---|
| 0 — locate and pin | `low` | file discovery and `git log`; mechanical |
| 2–4 — route, chain, compose | `high` | the reasoning: glossary resolution, following cross-references, composing a cited answer |
| 6 — written report | `low` | renders answers Step 4 already composed |

### Step 0 — Locate and pin the sources

1. **Find the feature folder.** Default `docs/{feature-slug}/` containing
   `*_CONCEPT.md` and `*_SPEC.md`; mirror the project's actual convention if it
   differs (same discovery rule the sibling skills use). If the user pointed at
   a folder or file, start there. **List the whole folder** — if it also holds
   an extension methodology's requirement-tier documents (a Migration Charter,
   Parity Plan, or Cutover Plan), those are authoritative too: read and pin
   them alongside the Concept Note and Spec. Note the Implementation Plan's
   path if present, but do not read it yet — it is consulted only when Step 2
   falls through to it.
2. **Never guess between features.** If more than one feature folder could
   match the question, list the candidates and ask. Answering from the wrong
   feature's Spec is worse than asking.
3. **If there are no methodology documents at all, stop.** Say the repo has no
   Concept Note / Spec for this feature, and offer `staged-engineering-doc` to
   create them. **Do not fall through to the code** and answer anyway: an
   answer read out of the implementation and framed as a spec finding is worse
   than no answer, and the "probable Spec gap" note would be meaningless where
   no Spec was ever intended. This skill has nothing to say about an
   undocumented codebase — declining is the correct output.
4. **Pin what you read.** For **every document you actually read** — including
   the Plan, if Step 2 later falls through to it — record: the path, its
   last-touching commit (`git log -1 --format='%h %ad' -- <path>`), the header
   `Status:` line, and the **last** row of its Change log (§18 in the Concept
   Note and Spec, **§17 in the Implementation Plan**; rows are *appended*, so
   the newest entry is at the bottom and the top row is the original draft).
   This is the answer's provenance, and it is what makes a stale answer visibly
   stale.
   - Then check whether what you read is what that commit contains:
     `git status --porcelain -- <path>`. **Any output means the file has
     uncommitted edits**, so the sha alone is a false trail — record it as
     `<sha> + uncommitted edits` and caveat every answer drawn from the
     document. A reader who checks out that sha would see different text, which
     is precisely the discrepancy this step exists to prevent.
   - If `git log` returns **empty output**, the document is untracked. Record
     `uncommitted (working tree)` — never an invented sha.
5. **Read both documents completely** before answering anything. Long Specs may
   need paged reads — **do not skip the tail**. The tail is where "not decided
   yet" is recorded, and skipping it turns an `OPEN` into a wrong
   `NOT-SPECIFIED`. The two documents number their tails differently:
   **Spec** §16 *Open questions* / §17 *Handoff*; **Concept Note** §15 *Open
   questions* / §16 *Handoff to the Spec* (§17 is the Appendix). Route by
   section *title*, not by number, when a project's docs deviate.
6. If one of the two documents is missing, say so up front and answer from
   what exists. A question in the missing document's territory (rationale if
   the Concept Note is absent; behaviour if the Spec is absent) is **not
   automatically `NOT-SPECIFIED`** — run the normal precedence ladder: if the
   Plan or the code answers it, that is `OUT-OF-SPEC` with a gap note; only if
   nothing answers is it `NOT-SPECIFIED`. A missing Spec makes the
   `OUT-OF-SPEC` gap notes *more* load-bearing, not less — they are the
   inventory of what a back-derived Spec would have to cover. Never invent the
   absent document's content. `staged-engineering-doc` can back-derive it if
   the user wants full coverage.

### Step 1 — Classify the question

Accept a single question or a batch. **Each question gets its own status and
its own citations** — never collapse a batch into one verdict or one status.

Split compound questions ("does it support X, and how fast?") into their parts;
they routinely land on different statuses.

### Step 2 — Locate the evidence

Load `references/question-routing.md` and route the question to its primary
source and ID family.

**If Step 0 found extension methodology documents**, also look for a
complementary routing table in the extension plugin's skill directory
(`skills/*/references/answers-routing.md`), load it after the bundled map, and
walk both — the same way `three-p-visualizer` locates and loads an extension's
`visualizer-mapping.md`. No extension ships one today; when none is found, route
by the extension documents' own section titles instead. Their content is
authoritative either way (see the taxonomy above) — a missing routing table is a
gap in this map, never grounds for `NOT-SPECIFIED`.

Then work the map's resolution rules in order — glossary first, follow the
cross-reference chain, check §18 before calling anything a conflict.

The routing map does not carry the ID index, so it lives here:

- **Grep by ID family, then by section, then by term.** The IDs are the index.
  Each family is defined in one document and section (`MD-05`) — **except
  `OPEN-Q-`, which exists independently in both documents and restarts its
  numbering in each**, so a bare `OPEN-Q-02` is ambiguous. Always qualify it
  (`Spec OPEN-Q-02`), and when the two documents both have one, check which is
  meant before answering: a Spec open question may explicitly inherit a Concept
  Note one under a different number.
  - **Spec** — `FR-` (§7) · `NFR-` (§8) · `TC-` (§4) · `S-`/`S-NNa` (§9) ·
    `AC-` (§11) · `US-` (§5.2) · `A-` (§14 Assumptions) · `OPEN-Q-` (§16)
  - **Concept Note** — `D-` (§10 Key decisions) · `OPEN-Q-` (§15)
  - **Plan only** (so a hit here means `OUT-OF-SPEC`) — `TD-`, `R-`, `OBS-`,
    `IMP-`, `T-`
  - **No IDs at all** — Concept §9 Alternatives (prose `§9.x Alternative A`),
    Concept §11 and Spec §15 Risks (un-IDed tables), Spec §6 Glossary, and the
    scope sections. Locate these by section, not by grep, and never expect an
    ID to exist there.

### Step 3 — Assign a status

Pick exactly one status from the taxonomy above. Before settling on
`NOT-SPECIFIED`, confirm you checked the tail sections (§16 / §17) and the
Concept Note's §14 *Out of scope* and §15 *Open questions* — an explicit
exclusion is an `ANSWERED` "no", not a gap.

### Step 4 — Compose the answer

- **Answer first**, in one or two sentences. Then the citations. Then the
  status. Never lead with the label or with meta-commentary about searching.
- **Cite, don't paraphrase.** Quote the normative clause verbatim when the
  exact wording *is* the answer — EARS functional requirements, Given/When/Then
  clauses, quantified NFRs. Paraphrasing a normative clause is how obligations
  drift.
- **Cite precisely**: `Spec §7.1 FR-003`, `Concept §10 D-02`, `Spec §9.1 S-01c
  [failure]`. Where the section *has* IDs, a section number without one (or an
  ID without its section) is half a citation. Where the section has **no IDs
  by design** — Concept §9 Alternatives, both Risks tables, the Glossary — the
  citation is the section plus a verbatim quote of the row. **Never invent an
  ID to complete a citation** — an ID the reader cannot find in the document
  defeats the whole point of citing (routing map, rule 9).
- **Never mix normative and inferred content** in one sentence without marking
  which is which.
- **Correct false premises first.** If the question assumes behaviour the docs
  explicitly exclude, say so and cite §3.2 *Out of scope / non-goals* or the
  Concept Note's §4 *Non-goals* before answering the rest.
- **Flag stale provenance — but only when it is informative.** Every template
  ships `Status: Draft` and nothing in the methodology promotes a document out
  of it, so `Draft` alone says nothing and must **not** trigger a caveat; a
  warning that fires on every answer trains the reader to skip it. Caveat only
  on a real signal: the document has uncommitted edits (Step 0.4), the cited
  content carries an `[INFERRED]` or `[UNVERIFIED — <reason>]` marker (`MD-26`;
  `[UNVERIFIED]` is the stronger signal of the two — the author tried to check
  the claim against a primary source and could not), the document was last touched well
  before substantial code churn in the feature's area, or the project actually
  uses the `Status:` field and has set it to something other than approved.

**What a good answer looks like.** `CONFLICTING` is the hardest status, so it
is the one worth showing:

```markdown
The two documents disagree — this is not settled.

> Spec §7.1 FR-012 — "When a run completes, the system shall retain its
> extraction artefacts for 90 days."
> Concept §10 D-04 — "Retain artefacts for 30 days" (rationale: "bounds
> storage cost at the expected ingest rate").

- Status: CONFLICTING
- Sources: Spec §7.1 `FR-012`, Concept §10 `D-04`
- Gap note: §18 Change log records neither as superseding the other, so the
  contradiction is live. `staged-engineering-doc` can reconcile them — say the
  word and I will hand it over.
```

Note what it does **not** do: pick the Spec because it is downstream, average
the two, split the difference, or bury the disagreement in prose. Both sides are
quoted verbatim with a full `§`+ID citation, and the reader decides.

### Step 5 — Handle the gap

For `NOT-SPECIFIED`, `OUT-OF-SPEC`, `CONFLICTING`, and `OPEN` — every status
except `ANSWERED`, `DERIVED`, and `PLAN-TERRITORY`:

1. **Name the home.** Say exactly where the missing or contested content
   belongs — "this would be an `FR-*` in Spec §7", "a `TC-*` in §4", "a `D-*`
   in Concept §10", "an `NFR-*` in §8".
2. **Offer the handoff**, do not take it. `staged-engineering-doc` has an
   iterate-on-existing-draft path (its Step 3) that amends the document,
   preserves existing IDs, and adds a Change-log row. Offer it; act only on an
   explicit go-ahead.
3. **Never invent the missing content** — not in the answer, not as a
   "reasonable default", not as an illustration (`MD-10`). A gap surfaced is
   worth more than a gap filled by guess.

### Step 6 — Optional written report

Only when the user asks for one (a batch of questions, or something to hand to
a stakeholder). Load `references/report-shape.md` and write a single Markdown
file. Default path
`docs/{feature-slug}/{FEATURE_NAME_SLUG}_QA_{YYYY-MM-DD}.md`, mirroring the
feature folder's naming convention if it differs.

The report is **read-only output**: it never edits the source documents. Its
header carries the pinned provenance from Step 0 — that is the audit trail that
lets a reader check the answers against the same revision they were drawn from.

**Re-run the Step 0.4 pin before assembling.** If it differs from the Step 0.4
snapshot, the documents moved mid-session — almost always because a Step 5
handoff to `staged-engineering-doc` was accepted and amended them. Record both
revisions in the provenance table and mark which answers predate the amendment.
Certifying the opening SHA over answers drawn from the amended text is a false
audit trail, and it is the one failure this header exists to make impossible.

## Operating principles

- **The docs are the contract.** The code is not the answer to a spec question.
  When they disagree, that is a finding worth reporting, not a tiebreak to
  resolve silently.
- **One status per question.** A batch answer never collapses statuses, and no
  answer carries two.
- **Surface conflicts; never resolve them.** Present both sides with citations
  and let the reader decide. Same rule the sibling `three-p-visualizer` follows.
- **`NOT-SPECIFIED` beats a plausible answer.** The whole value of a grounded
  Q&A layer is that its silence is informative.
- **No numeric confidence scores.** The status taxonomy is the only
  quantisation — for the same calibration-drift reason `MD-23` rejects numeric
  scores in the critic rubric.
- **Read-only by default.** This skill reads documents and answers questions.
  Every write — an amended Spec, a filed issue, a saved report — needs the
  user's explicit go-ahead first.
- **Progressive disclosure.** The routing map loads when locating evidence; the
  report shape loads only when a report is actually requested.
- **Answer in the user's language**, but keep stable IDs, section numbers, and
  quoted normative clauses untranslated — they are literal keys into the docs.
