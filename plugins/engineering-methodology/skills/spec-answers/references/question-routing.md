# Question routing — question intent → doc section + ID family

This is the lookup map. For each kind of question, it names the **primary
source**, the ID family that indexes it (if any), and the **secondary source**
to consult only if the primary is silent.

Section numbers are the template's (from the sibling `staged-engineering-doc`
skill); adapt if the project's docs deviate — route by section *title* when the
numbering differs.

Legend: **CN** = Concept Note · **SP** = Spec · **PL** = Implementation Plan.

**The secondary column is not the same as `OUT-OF-SPEC`.** A **CN** or **SP**
secondary source is still authoritative — the answer is `ANSWERED` or
`DERIVED` like any other. Only a **PL** or code source yields `OUT-OF-SPEC`;
those are marked *(→ `OUT-OF-SPEC`)* in the table.

**Rows 16 and 17 are the exception**: their primary column reads *not a spec
question*, so a **PL** or code answer there is `PLAN-TERRITORY`, not
`OUT-OF-SPEC`. The Spec is *correctly* silent on module layout, build order and
shipped-state — Spec §17 hands the Plan freedom over module layout and file
paths — so these carry no gap note. Every other row's *(→ `OUT-OF-SPEC`)*
marking is a real Spec gap, because risks, metrics and assumptions do belong in
the Spec.

**Not every section has IDs.** An `ID family` of `—` means the section is
un-IDed *by design* — Concept §9 alternatives are prose subsections, and both
risk tables ship without an ID column. For those, cite the section plus a
verbatim quote of the row; do not invent an ID to satisfy the citation rule
(see SKILL.md Step 4).

---

## Routing table

| # | Question intent | Typical phrasing | Primary source | ID family | Secondary source |
|---|---|---|---|---|---|
| 1 | **What must it do** | "does it support X?", "can a user do Y?" | SP §7 Functional requirements | `FR-` | PL §12.1 matrix *(→ `OUT-OF-SPEC`)* |
| 2 | **What happens when…** | "what if the file is too big?", "what happens on timeout?" | SP §9.1 happy path · §9.2 edge cases · §9.3 failure scenarios, incl. `Variants:` blocks | `S-NN`, `S-NNa` | PL §12.1 matrix *(→ `OUT-OF-SPEC`)* |
| 3 | **How well / limits / SLA** | "how fast?", "how many concurrent?", "what uptime?" | SP §8 Non-functional requirements | `NFR-` | PL §11 Observability (`OBS-`) *(→ `OUT-OF-SPEC`)* |
| 4 | **What's allowed / mandated** | "can we use library Z?", "must it run on-prem?", "which vendor?" | SP §4 Technical & architectural constraints (§4.1 stack · §4.2 architecture · §4.3 compliance · §4.4 conventions) | `TC-` | CN §10 Key decisions (`D-`) |
| 5 | **Why this way** | "why did we choose X?", "why not Y?" | CN §9 Alternatives considered (prose `§9.x Alternative A/B`, no IDs) · §10 Key decisions | `D-` (§10 only) | PL §3.1 Key design decisions (`TD-`) *(→ `OUT-OF-SPEC`)* |
| 6 | **Is it in scope** | "is X included?", "are we doing Y too?" | CN §3 Goals · §4 Non-goals · SP §3.1 In scope · §3.2 Out of scope | — | CN §14 Out of scope / deferred |
| 7 | **How do we know it works** | "what are the acceptance criteria?", "when is this done?" | SP §11.1–§11.4 Acceptance criteria · §11.5 Test & traceability obligations | `AC-` | PL §16 AC coverage *(→ `OUT-OF-SPEC`)* |
| 8 | **What does *term* mean** | "what exactly counts as a <term>?" | SP §6 Glossary | — | CN §6 Context & background |
| 9 | **Who uses it** | "who is this for?", "which actors?" | SP §5.1 Personas/actors · §5.2 User stories | `US-` | CN §13.2 Stakeholders |
| 10 | **What data / what contract** | "what fields?", "what does the API return?", "what events?" | SP §10.1 Domain entities · §10.2 consumed · §10.3 exposed | — | PL §8 Data model · §9 API changes *(→ `OUT-OF-SPEC`)* |
| 11 | **Has it been decided** | "did we settle X?", "is that still open?" | CN §15 Open questions · SP §16 Open questions | `OPEN-Q-` | CN §16 / SP §17 Handoff |
| 12 | **What could go wrong** | "what are the risks?", "what if it fails in prod?" | CN §11 Risks · SP §15 Risks (both un-IDed tables) | — | PL §14 Risks & rollback (`R-`) *(→ `OUT-OF-SPEC`)* |
| 13 | **How is success measured** | "what metrics?", "how do we know it worked?" | CN §12 Success signals · SP §12 Success metrics | — | PL §11 Observability (`OBS-`) *(→ `OUT-OF-SPEC`)* |
| 14 | **What are we assuming** | "what does this depend on?", "what are we taking for granted?" | SP §13 Dependencies · §14 Assumptions | `A-` (§14 only) | PL §15.2 Assumptions *(→ `OUT-OF-SPEC`)* |
| 15 | **What's the pitch** | "what is this feature, in one paragraph?" | CN §1 TL;DR · §5 Vision · SP §2 Summary | — | — |
| 16 | **Where in the code / in what order** | "which module?", "what gets built first?", "which branch?" | **not a spec question** | — | PL §4 Module map · §7 Branch plan → always `PLAN-TERRITORY` |
| 17 | **Is it built yet / does it work** | "is this shipped?", "does it actually do this today?" | **not a spec question** | — | Code + git history → always `PLAN-TERRITORY` |
| 18 | **What backs this design** | "what evidence supports this?", "which standards were checked?", "what prior art?" | CN §6.5 Sources & Origins (`MD-25`) — three un-IDed sub-lists: Codebase evidence · Industry-standard evidence · Prior-art evidence | — | SP/PL inline grounding citations |

---

## Resolution rules

Apply in order when the routing above lands on more than one candidate.

These rules choose **which sources answer the question**. The *status* is then
chosen by the precedence ladder in `SKILL.md`, whose first rung — any
authoritative source contradicting another is `CONFLICTING` — outranks every
tiebreak below. No rule here can promote a contradiction into an `ANSWERED`.

1. **Glossary first.** Resolve every domain term in the question against SP §6
   before searching. A term with a narrow in-feature definition changes what
   the question is even asking.
2. **Follow the chain, don't stop at the first hit.** The IDs cross-reference
   each other by design: SP §3.3 inherited constraints cite CN `D-*`; scenarios
   name the FRs they cover; `US-*` link to implementing FRs; `AC-*` cite the
   `FR-`/`NFR-`/`TC-` they verify. A one-row answer to a chained question is
   usually incomplete.
3. **Spec wins for behaviour; Concept wins for rationale — but only where the
   two agree.** If both state something about *what the system does* and the
   statements are **substantively compatible** — the Spec sharpening what the
   Concept sketches, a rounded target made exact, a behaviour given its edge
   cases — the Spec is authoritative and this is not a conflict but the
   intended division. If the two make **incompatible** claims — a different
   retention period, a different retry limit, a different capacity — this rule
   does not apply at all: rule 4 governs and the status is `CONFLICTING`.
   Being downstream settles *precision*, never *contradiction*. The Spec
   stating something later is not evidence that the Concept was withdrawn;
   only §18 Change log (rule 5) is. The same holds for rationale: the Concept
   wins on *why* only where the Spec offers no conflicting reason.
4. **A genuine conflict is `CONFLICTING`, not a tiebreak.** This covers
   incompatible claims *between* the two documents **and between two sections
   of the same document** — Concept §3 Goals promising what §14 defers is a
   conflict, not a resolved question. Report every side.
5. **Check §18 Change log before declaring a conflict.** One statement may have
   been superseded by a later edit that missed its counterpart — that is drift
   worth naming as such, and it is exactly what
   `staged-engineering-doc`'s cross-consistency pass
   (`references/review-passes.md`, Pass 2) exists to catch.
6. **An explicit exclusion is an answer — unless something contradicts it.**
   "X is out of scope" (CN §4, SP §3.2) or "deferred" (CN §14) makes the
   question `ANSWERED` with a "no" rather than `NOT-SPECIFIED`. But check the
   in-scope side first (CN §3 Goals, SP §3.1): if a goal or an `FR-*` promises
   what an exclusion denies, rule 4 wins and the status is `CONFLICTING`. An
   exclusion is not automatically the final word just because it is the more
   definite-sounding one.
7. **A recorded unknown is an answer too.** If the question matches an
   `OPEN-Q-*`, the status is `OPEN`, not `NOT-SPECIFIED`. Quote the open
   question and its target stage.
8. **Exhaust every CN and SP source before leaving the two documents.** A
   secondary source that is still CN or SP (rows 4, 6, 8, 9, 11) is
   authoritative — the answer is `ANSWERED`, with no gap note. Only after
   *both* documents are silent may the Plan or the code be consulted; that
   answer is `OUT-OF-SPEC` and carries a gap note, because a behavioural fact
   living only in the Plan means the Spec is incomplete. That gap note is
   mandatory and appears in the report's Gaps roll-up — `OUT-OF-SPEC` is a
   gap-bearing status exactly like `NOT-SPECIFIED` (SKILL.md Step 5).
   **Rows 16 and 17 are exempt from this rule**: they are not spec questions,
   so their Plan/code answer is `PLAN-TERRITORY`, carries no gap note, and never
   enters the Gaps roll-up. Do not exhaust CN and SP first for those two — the
   Plan *is* the primary source.
9. **Cite what exists, never what would be tidy.** For an `ID family` of `—`,
   the citation is the section plus a verbatim quote (`Concept §11 Risks —
   "extraction workers starve under a burst"`). Fabricating `R-01` for an
   un-IDed Concept risk row produces a citation the reader cannot find, which
   is the failure this skill exists to prevent.

---

## Extension mappings

Extension plugins **may** ship an additional routing table named
`answers-routing.md` in the same format, which would **extend — never
replace —** this base map, the way `three-p-visualizer` composes complementary
`visualizer-mapping.md` files.

The extension file is deliberately **not** called `question-routing.md`. That
is this file's own name, so a `find … -name question-routing.md` discovery pass
would match the base map itself and every skill would have to remember to skip
itself. `three-p-visualizer` already solved this by pairing a base
`content-mapping.md` with an extension `visualizer-mapping.md`; `answers-routing.md`
is the same shape.

**No extension ships one today.** `migration-methodology` provides a
`visualizer-mapping.md` but no `answers-routing.md`. So if the feature folder holds
extension documents (a Migration Charter, Parity Plan, or Cutover Plan) and no
extension routing table is found:

- Say so up front — the reader needs to know the map is partial.
- Answer from the extension documents' own section titles anyway, routing by
  *what the question asks* rather than by a table row. Their content is
  authoritative for the feature.
- Do **not** return `NOT-SPECIFIED` merely because no table row matched. A
  missing routing row is a gap in this map, not a gap in the documents.
