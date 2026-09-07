# Written-report shape

Load this only when the user asks for a written report (Step 6). The default
answer path is conversational and writes nothing. Step 6 owns the save path;
this file owns what goes *in* the file.

**Never overwrite an existing report.** Check the path first; if it is taken,
append a disambiguator (`…_QA_2026-07-25_b.md`, or a topic slug such as
`…_QA_2026-07-25_retention.md`) and say which file you wrote. A second batch of
questions the same day is normal, and silently replacing a report someone has
already shared destroys answers and their Gaps roll-up. The sibling
`staged-engineering-doc` disambiguates its same-day critique artefacts the same
way (`…_CRITIQUE_{{date}}_{{critic-model-short}}.md`).

---

## Structure

````markdown
# {{FEATURE_NAME}} — Spec Q&A

> **Answered from:** the authoritative documents below · Implementation Plan / code (fallback, labelled)
> **Date:** {{YYYY-MM-DD}} · **Asked by:** {{who}}

| Source | Path | Last commit | Doc status | Change log latest row |
|---|---|---|---|---|
| Concept Note | `{{path}}` | `{{sha}} {{date}}` | {{status}} | {{date — newest entry}} |
| Spec | `{{path}}` | `{{sha}} + uncommitted edits` | {{status}} | {{date — newest entry}} |

**One row per document actually read** — no fixed set of rows. The two above are
illustrative: add a row per extension-methodology document when the feature has
them, add the Plan row only when an answer fell back to it, and drop any row
rather than filling it with placeholders. Paths and change-log locations are
whatever this feature folder actually uses (Step 0.1 and Step 0.4 established
both); never copy the example paths. Every cell comes from the Step 0.4 pin —
never invent one, and carry its `uncommitted` markers through verbatim.

## Summary

{{N}} ANSWERED · {{N}} DERIVED · {{N}} OPEN · {{N}} CONFLICTING · {{N}} OUT-OF-SPEC · {{N}} PLAN-TERRITORY · {{N}} NOT-SPECIFIED

## Answers

### 1. {{the question, verbatim}}

**{{The answer, one or two sentences.}}**

> {{Verbatim quote of the normative clause when the exact wording is the answer.}}

- **Status:** {{ANSWERED | DERIVED | OPEN | CONFLICTING | OUT-OF-SPEC | PLAN-TERRITORY | NOT-SPECIFIED}}
- **Sources:** {{Spec §7.1 FR-003}}, {{Concept §10 D-02}}
- **Reasoning:** {{DERIVED only — the inference, every endpoint named}}
- **Gap note:** {{every status except ANSWERED, DERIVED and PLAN-TERRITORY — where the answer would belong}}
- **Caveat:** {{only when Step 4's stale-provenance triggers apply}}

### 2. {{next question}}

…

## Gaps surfaced

Every answer that is not `ANSWERED`, `DERIVED` or `PLAN-TERRITORY`, with its
proposed home. This roll-up is the actionable output — hand it to
`staged-engineering-doc`'s iterate-on-existing-draft path.

`PLAN-TERRITORY` is excluded by design: the question was never the Spec's to
answer, so listing it here would propose amendments to a document that is
already correct.

| # | Question | Status | Belongs in | Note |
|---|---|---|---|---|
| 1 | {{…}} | NOT-SPECIFIED | Spec §7 as a new `FR-*` | {{one line}} |
| 2 | {{…}} | CONFLICTING | Concept §10 `D-02` vs Spec §4 `TC-001` | {{both readings, one line}} |
| 3 | {{…}} | OPEN | already recorded as `Concept OPEN-Q-03`, targets Spec | {{quote}} |
| 4 | {{…}} | OUT-OF-SPEC | Spec §7 as an `FR-*` | fact lives only in Plan §10 config |

*(If there are none: "No gaps surfaced — every question answered from an
authoritative document.")*
````

---

## A worked block

The same question rendered end to end — provenance row, answer block, and the
Gaps roll-up entry it produces. `SKILL.md` Step 4 carries the conversational
form of this answer; here is what it looks like once written to a file.

**The two copies share an exemplar, so keep them in step.** Identical in both,
verbatim: the quoted clauses, the `§`+ID citations, and the status. Different
by design, and only here: the closing line of the gap note — Step 4 *offers the
handoff* because it is mid-conversation ("say the word and I will hand it
over"), while the written form *names the home* because a file has no one to
ask ("belongs in Spec §7 or Concept §10 — whichever is amended, the other needs
a Change-log row"). Any other difference between them is drift, not medium, and
should be fixed rather than explained.

````markdown
| Source | Path | Last commit | Doc status | Change log latest row |
|---|---|---|---|---|
| Spec | `docs/run-retention/RUN_RETENTION_SPEC.md` | `a1b2c3d 2026-06-14` | Draft | 2026-06-14 — added FR-012 |
| Concept Note | `docs/run-retention/RUN_RETENTION_CONCEPT.md` | `9f8e7d6 2026-05-02` | Draft | 2026-05-02 — initial draft |

### 3. How long are extraction artefacts retained?

**The two documents disagree — this is not settled.**

> Spec §7.1 FR-012 — "When a run completes, the system shall retain its
> extraction artefacts for 90 days."
> Concept §10 D-04 — "Retain artefacts for 30 days" (rationale: "bounds storage
> cost at the expected ingest rate").

- **Status:** CONFLICTING
- **Sources:** Spec §7.1 `FR-012`, Concept §10 `D-04`
- **Gap note:** §18 Change log records neither as superseding the other, so the
  contradiction is live. Belongs in Spec §7 or Concept §10 — whichever is
  amended, the other needs a Change-log row saying so.
````

…and its row in the roll-up:

````markdown
| # | Question | Status | Belongs in | Note |
|---|---|---|---|---|
| 3 | How long are extraction artefacts retained? | CONFLICTING | Spec §7.1 `FR-012` vs Concept §10 `D-04` | 90 days vs 30 days; §18 records no supersession |
````

Two things to copy. The **Sources** line and the roll-up's **Belongs in** cell
carry the same two citations, so a reader who only reads the roll-up can still
find both sides. And neither the answer nor the roll-up picks a winner — the
Gaps table names where the fix goes, not what the fix is.

---

## Rules

1. **The provenance table is not optional** — it is the audit trail Step 0.4
   exists to produce. A report without pinned commits is a snapshot with no
   expiry date on it.
2. **One block per question, in the order asked.** Never merge two questions
   into one block, even when they share a source.
3. **Answer text carries over from Step 4 unchanged** — it was already composed
   under the cite-don't-paraphrase rule. Do not re-summarise at assembly time;
   normative clauses render as the blockquote.
4. **Every block carries a status** from the closed set in `SKILL.md`, and the
   Summary counts total the number of blocks.
5. **The Gaps roll-up repeats — never replaces — the per-answer gap notes.** A
   reader who only reads the roll-up must still get the full picture of what is
   missing.
6. **Escape `|` inside any table cell.** The un-IDed sections are cited by
   section plus a verbatim quote of the row (`question-routing.md` rule 9), and
   the sections that need it most — Concept §11 Risks, Spec §15 Risks, the
   quantified NFR table in Spec §8 — are themselves Markdown tables, so those
   quotes contain pipes. Dropped into a Gaps roll-up cell unescaped, one quote
   splits the row into extra columns and the table stops rendering. Write `\|`
   in the cell, or move the quote to a bullet directly beneath the table and
   cite it from the cell. Never trim the quote to dodge the pipe — the citation
   has to be findable in the source.
7. Read-only, no numeric confidence, offer-don't-act — see `SKILL.md`'s
   Operating principles. Nothing about writing a report relaxes them.
