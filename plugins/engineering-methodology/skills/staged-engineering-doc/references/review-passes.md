# Consistency review passes

The two mechanical passes the skill runs in `SKILL.md` Step 5 before
saving any document. They are the heavy, recipe-bearing half of the
review; `SKILL.md` keeps only a short pointer to them so the orchestrator
stays lean (`MD-13` progressive disclosure). Both passes use `grep` /
`comm` against the actual files — treat any non-empty diff as a bug, not
a comment.

The Plan gates these as `T-N.D18` (self-consistency) and `T-N.D19`
(cross-consistency); the Spec and Concept Note run the same passes by
hand during their own review.

> **No contiguity requirement.** These passes deliberately do **not**
> require ID families to be gap-free. The methodology's own templates use
> non-contiguous IDs by design (`spec-guidance.md §7` — "keep gaps if
> needed"; `SPEC_TEMPLATE.md` reserves `AC-01..09 → 10..14 → 50..54`,
> `S-01 → S-10 → S-20`). A contiguity gate would fail on a conforming
> document. What matters is **referential integrity** — that every ID a
> document *cites* is *defined* somewhere it should be — not that the
> numbers run 1, 2, 3 without holes.

## Pass 1 — self-consistency (within one document)

Catches drift internal to a single doc: an FR renumbered but a downstream
AC still points at the old ID; an `OPEN-Q-*` resolved in the body but
still listed in the handoff; a referenced task that no section defines.

For **every** document, regardless of type:

1. **Every referenced ID is defined in the same doc.** Take the union of
   all IDs *cited* in prose / tables, subtract the IDs *defined* in the
   doc's structural sections, expect an empty difference. Anything left is
   a typo or a stale reference to a deleted ID.

   ```bash
   # Example for one prefix; repeat per prefix declared in the doc:
   PREFIX=AC
   comm -23 \
     <(grep -oE "(^|[^A-Za-z])${PREFIX}-[0-9]+" {{path/to/DOC.md}} \
        | sed -E 's/^[^A-Za-z]//' | sort -u) \
     <(grep -oE "^\s*[-|>* ]*\**\s*${PREFIX}-[0-9]+" {{path/to/DOC.md}} \
        | grep -oE "${PREFIX}-[0-9]+" | sort -u)
   ```

   The right-hand side is the set of *definition* lines (list items,
   table rows, or headings that introduce the ID). Tune the anchor to how
   the doc defines that family. Empty output = every reference resolves.

   **The left-anchor is load-bearing here too** — and this pass is *more*
   exposed than Pass 2, not less. Pass 2 runs the same form on both sides, so
   a superstring phantom that appears on the left usually appears on the right
   and cancels. Here the two sides are asymmetric by construction: the
   right-hand side is already immune, because its line-start anchor
   (`^\s*[-|>* ]*\**\s*`) cannot step over the extra letter of a longer prefix.
   An unanchored left-hand side therefore contributes phantoms that **nothing
   cancels**, and every one of them is emitted as a dangling reference. Run
   over the templates this repo ships, the unanchored form fabricates a phantom
   for every longer-prefixed ID: an `R-NNN` for each `FR-*` / `NFR-*` in the Plan
   (`R-001` ← `FR-001`, `R-002` ← `NFR-002`, …), a `D-NN` for each `MD-*` the Spec
   cites (`D-22` ← `MD-22`, `D-31` ← `MD-31`, …), and an `S-NN` for each `OBS-*`
   (`S-02` ← `OBS-02`, …) — one dangling reference per superstring, and the count
   grows with every new `MD-NN` / `NFR-*` / `OBS-*` the templates add.

2. **OPEN-Q book-keeping.** Every `OPEN-Q-*` introduced in the body is
   either resolved with a decision in the same doc *or* listed in the
   handoff section (Concept §16, Spec §16, Plan §15.1). The reverse holds:
   every handoff `OPEN-Q-*` is surfaced where the question was raised, not
   invented in the handoff.

3. **No orphan sections.** Every numbered section the template prescribes
   is present (skip with a one-line "Not applicable — {{reason}}" rather
   than silently deleting), so the cross-doc renderer can locate sections
   by number.

Document-specific extras:

- **Concept Note** — §3 Goals and §4 Non-goals are disjoint. Every
  alternative in §9 has an explicit "why rejected" sentence.
- **Spec** — Every `FR-*` is referenced by at least one `AC-*` in §11.1;
  every quantified `NFR-*` by an `AC-*` in §11.2; every `TC-*` by an
  `AC-*` in §11.3; every `S-*` by an `AC-*` in §11.1/§11.4. Each family
  lives in its own section (FRs not hidden in §4 TCs, etc.).
- **Plan** — Every `T-N.*` task ID cited from the §14 *Mitigation task*
  column, the §12.2 *Mitigation task* column, or the §16 *Satisfied by*
  column resolves to a task **defined** in some §7.x.9 checklist. (Restrict
  the definition set to checkbox-defined IDs, or the references match
  themselves — the same de-tautologised shape as the `T-N.D17` risk gate.)
  Every branch in §7 has a closing `T-N.D1`–`T-N.D20` block.

  ```bash
  # Every T-N.* referenced from §14 / §12.2 / §16 is defined in a §7.x.9 checklist:
  comm -23 \
    <(grep -oE "T-[0-9]+\.[A-Z]?[0-9]+" {{path/to/PLAN.md}} | sort -u) \
    <(grep -oE "^- \[[ x]\] T-[0-9]+\.[A-Z]?[0-9]+" {{path/to/PLAN.md}} \
       | grep -oE "T-[0-9]+\.[A-Z]?[0-9]+" | sort -u)
  ```

## Pass 2 — cross-consistency (between documents)

Run when iterating on or back-deriving any document. The goal is to catch
*dangling references*: the doc cites `FR-099` but the Spec only defines
`FR-001..FR-040` — the symptom of a renumbering in one doc that wasn't
propagated to its siblings.

Mechanical recipe (substitute the right paths and `<PREFIX>`):

```bash
comm -23 \
  <(grep -oE '(^|[^A-Za-z])<PREFIX>-[0-9]+[a-z]*' {{path/to/THIS_DOC.md}}     | sed -E 's/^[^A-Za-z]//' | sort -u) \
  <(grep -oE '(^|[^A-Za-z])<PREFIX>-[0-9]+[a-z]*' {{path/to/UPSTREAM_DOC.md}} | sed -E 's/^[^A-Za-z]//' | sort -u)
```

**The left-anchor is not optional.** A bare `grep -oE "<PREFIX>-[0-9]+"` matches
*inside* a longer prefix, and the result is fabricated dangling references: `D-`
matches inside `TD-` and `MD-`, `S-` inside `US-` and `OBS-`, `FR-` inside
`NFR-`, `R-` inside all three. A Plan citing `MD-12` would be reported as citing
a Concept decision `D-12` that was never written.

One form serves every prefix. `(^|[^A-Za-z])` captures at most one character, so
`sed -E 's/^[^A-Za-z]//'` strips exactly the boundary whatever the prefix; and
the anchor plus the `[a-z]*` variant suffix are no-ops for families that have
neither a superstring nor variants.

Any output line is a dangling reference. Fix it by adding the missing
definition to the upstream doc, fixing the typo in this doc, or
renumbering this doc to match.

Specific edges to check:

- **Concept Note ↔ Spec.** Every Concept `D-*` cited by the Spec exists in
  the Concept. Every Concept `OPEN-Q-*` targeting "Spec" is resolved in the
  Spec or carried into Spec §16.
- **Spec ↔ Plan.** Every Spec ID (`FR-*` / `NFR-*` / `TC-*` / `AC-*` /
  `S-*`) cited by the Plan exists in the Spec. Every Spec `AC-*` appears in
  Plan §16 with both `Satisfied by` and `Test` columns populated. Every
  Spec `S-*` appears in Plan §12.1 (test); the change's consequences appear
  in §12.2 (impact, feature-level). Every quantified Spec `NFR-*` appears
  as a *Binds to* in some Plan §11 `OBS-*` row. Every Spec `OPEN-Q-*`
  targeting "Plan" is resolved in the Plan or carried into Plan §15.1.
- **Plan ↔ Concept Note.** Every Concept `D-*` cited by the Plan exists in
  the Concept.

The cleanest single direction is "every reference in the doc resolves to a
definition somewhere upstream" — that is the dangling-reference gate. The
reverse direction (e.g. every Spec `S-*` has a corresponding Plan §12.1
row) is worth a spot check but is already covered by the operational gates
`T-N.D8`–`T-N.D17`.
