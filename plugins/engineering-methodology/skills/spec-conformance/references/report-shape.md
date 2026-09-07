# Report shape — canonical JSON, derived markdown

Load this in Phase 5. `spec-conformance-data.json` is the artefact; the
markdown is a **rendering of it**. Write the JSON first, then derive the
markdown from it — never the other way round, and never hand-edit the markdown
afterwards. A hand-edited twin drifts from the data on the first correction,
and then two documents disagree about what the audit found.

Same role `triage-data.json` plays in `issue-triage`. **Verdict tokens are
identical in both files** — one vocabulary, no case-mapping.

**Never overwrite an existing report or data file.** Check both paths; if either
is taken, append a disambiguator (`…_CONFORMANCE_2026-07-25_b.md`) and say which
files you wrote. Same-day re-audits are normal and the previous run is the
baseline the next diff needs — `spec-answers` disambiguates the same way.

---

## `spec-conformance-data.json`

```json
{
  "feature": "{{feature name}}",
  "feature_slug": "{{slug}}",
  "date": "{{YYYY-MM-DD}}",
  "run": 1,
  "denominator": 51,

  "documents": [
    {
      "kind": "Spec",
      "path": "docs/{{slug}}/{{NAME}}_SPEC.md",
      "sha": "a1b2c3d",
      "sha_date": "2026-06-14",
      "status": "Draft",
      "changelog_latest": "2026-06-14 — {{last row of the Change log}}"
    }
  ],

  "code": {
    "repo": "{{owner/repo}}",
    "branch": "main",
    "sha": "9f8e7d6",
    "dirty": false,
    "test_root": "tests/",
    "binding_convention": "variant-a"
  },

  "frontier": ["src/upload/", "src/api/upload_routes.py"],

  "gates": [
    {
      "gate": "T-N.D8",
      "axis": "spec-code",
      "ac": "AC-50",
      "result": "fail",
      "scoped_to": ["tests/unit/test_provisioning.py"],
      "unbound": ["S-07", "S-04c"],
      "note": "{{one line}}"
    }
  ],

  "ids": [
    {
      "id": "FR-001",
      "family": "FR",
      "section": "§7.1",
      "verdict": "IMPLEMENTED",
      "evidence": "src/upload/service.py:142 — validates size before persisting",
      "test": "tests/unit/test_upload.py::test_S_01_happy_walk",
      "plan_attribution": "Branch 2",
      "note": "",
      "provisional": false,
      "open_question": null,
      "alternate_reading": null,
      "revised_from": null,
      "verified_in_run": 1
    }
  ],

  "unspecified_behaviour": [
    {
      "file": "src/upload/service.py:210",
      "behaviour": "retries 3× with exponential backoff on upstream 503",
      "proposed_home": "an FR-* in Spec §7, or an NFR-* in §8 if the bound is a reliability target",
      "deliberate": true,
      "external_effect": true,
      "note": "{{one line}}"
    }
  ],

  "spec_quality": [
    {
      "kind": "missing-variants-block",
      "locus": "Spec §9.2 Scenario S-11",
      "note": "no Variants: block and no explicit none-declaration — AC-50 structural half"
    }
  ]
}
```

**Field notes.**

- `denominator` is Phase 1's count and must equal `len(ids)`. Assert it.
- `documents` has **one entry per document actually read** — no fixed set.
  Add extension-methodology documents when the feature has them. Carry the
  `+ uncommitted edits` and `uncommitted (working tree)` markers from Phase 0
  verbatim into `sha`; never invent one.
- `evidence` paths are **repo-relative**, never worktree-absolute — the
  citation must resolve after the worktree is removed.
- `plan_attribution` is `null` when no Plan exists. It is **context only**; no
  consumer of this file may use it to filter or downgrade a verdict.
- `provisional` is `true` when an `OPEN-Q-*` covers the ID; `open_question`
  carries the quote.
- `verified_in_run` records which run last established the verdict, so a re-run
  can carry rows forward and the report can mark which are fresh.
- `alternate_reading` is `null` normally. When a clause's subject genuinely
  reads two ways **and the readings disagree**, it carries the broad reading:
  `{"reading": "...", "verdict": "DIVERGENT", "evidence": "..."}`. The row's own
  `verdict` is always the **narrow** reading — that is what keeps the summary
  counts stable across runs — and the markdown renders the alternate beside it.
  **Any row with a non-null `alternate_reading` appears in the Gaps roll-up**
  whatever its verdict: a requirement that means two different things is a
  defect regardless of which meaning the code satisfies.
- `revised_from` is `null` normally. When Phase 4's reverse sweep contradicts
  the verdict Phase 3 assigned, it holds the **superseded** verdict plus which
  tier changed it (`"IMPLEMENTED (revised by reverse sweep)"`). The markdown
  must render it beside the row. A silent overwrite hides a disagreement
  between two tiers that both read the same code — which is a finding in its
  own right, not bookkeeping.
- **`unspecified_behaviour` holds the reverse sweep; `DIVERGENT` never appears
  there** — a `DIVERGENT` verdict is anchored to a Spec ID and lives in `ids[]`
  like every other verdict. The array name is the discriminator, so its members
  carry no `verdict` field. The summary's `DIVERGENT` count comes from `ids[]`,
  its `UNSPECIFIED-BEHAVIOUR` count from this array. **Do not rename this
  array** — calling it `divergences` makes a renderer report every unsanctioned
  behaviour as a contradicted requirement and zero reverse-sweep findings.
- **`gates[].result` is a closed set**, for the same reason the verdicts are —
  it feeds them, and a re-run diff over an open vocabulary is unreliable:

  | `result` | Meaning | Renders as |
  |---|---|---|
  | `pass` | ran, scoped, clean | ✓ |
  | `fail` | ran, found the listed IDs | ✗ + the IDs |
  | `unscoped-pass` | ran clean, but the test tree could not be narrowed to this feature | **UNSCOPED** — never a tick |
  | `no-convention` | no ID-binding convention is in use, so there is no binding to find | **UNSCOPED (no convention)** |
  | `not-applicable` | a document the gate needs is absent | **n/a** + which document |

  `unscoped-pass` and `no-convention` were one token until they proved to have
  opposite remedies — narrow the test paths, versus adopt a binding convention
  (and file it as a Spec-quality finding). Keep them distinct.
- `scoped_to` lists the test paths the gate's right-hand side was restricted
  to. `null` forbids a bare `pass`: in a repository with several features an
  unscoped pass can come entirely from another feature's bindings.
- A `not-applicable` gate **still gets a row**. An omitted gate reads as a gate
  that passed.
- `spec_quality` collects findings about the **document** rather than the code
  — unquantified NFRs, missing `Variants:` blocks, FRs no scenario cites,
  dangling IDs from `T-N.D19`. They are real output, but they are not
  conformance verdicts and never enter the verdict counts.

---

## The markdown report

````markdown
# {{FEATURE_NAME}} — Spec conformance

> **Audited:** Spec (authoritative) against the code at the pinned SHA below
> **Date:** {{YYYY-MM-DD}} · **Run:** {{n}} · **Requested by:** {{who}}

| Side | What | Pinned at |
|---|---|---|
| Spec | `docs/{{slug}}/{{NAME}}_SPEC.md` | `{{sha}} {{date}}` · Change log: {{date}} |
| Plan | `docs/{{slug}}/{{NAME}}_PLAN.md` | `{{sha}} {{date}}` · Change log: {{date}} |
| Code | `{{owner/repo}}` @ `{{branch}}` | `{{sha}}` |

**Denominator:** {{N}} obligations — every `FR-*`, `NFR-*`, `TC-*`, `S-*` and
`AC-*` in the Spec, held against the code **regardless of build state**. A
branch not yet started still produces `ABSENT` rows; the *Planned in* column is
context, and never excuses a verdict.

**Reverse-sweep frontier:** {{paths}}.

## Summary

{{N}} IMPLEMENTED · {{N}} PARTIAL · {{N}} ABSENT · {{N}} DIVERGENT · {{N}} UNVERIFIABLE
{{N}} UNSPECIFIED-BEHAVIOUR findings · {{N}} Spec-quality findings

## Conformance by requirement

### Functional requirements (§7)

| ID | Verdict | Evidence | Test | Planned in |
|---|---|---|---|---|
| FR-001 | IMPLEMENTED | `src/upload/service.py:142` — validates size before persisting | `test_S_01_happy_walk` | Branch 2 |
| FR-004 | PARTIAL | `src/upload/service.py:210` — retry present, dead-letter path missing | — | Branch 2 |
| FR-010 | ABSENT | would live in `src/upload/quota.py`; no quota logic anywhere in the frontier | — | Branch 4 |

### Non-functional requirements (§8)
### Constraints (§4)
### Scenarios (§9)
### Acceptance criteria (§11)

{{Same five columns. One section per family, in Spec order, so a reader can
scan against the document itself.}}

## Behaviour the Spec does not cover

| # | Behaviour | Where | Proposed home | Deliberate? |
|---|---|---|---|---|
| 1 | Retries 3× with exponential backoff on upstream 503 | `src/upload/service.py:210` | `FR-*` in §7, or `NFR-*` in §8 if the bound is a reliability target | yes — consistent and tested |

## Mechanical gates

| Gate | AC | Axis | Result | Detail |
|---|---|---|---|---|
| `T-N.D8` | `AC-50` | Spec ↔ code | FAIL | `S-07`, `S-04c` have no bound test |
| `T-N.D10` | `AC-52` | Spec ↔ **Plan** | PASS | proves the Plan mentions each `TC-*`, not that the code complies |

*A gate pass is not evidence of an implementation — see
`references/mechanical-gates.md`.*

## Spec-quality findings

{{Findings about the document, not the code. Not counted as verdicts.}}

## Gaps

Every row that is not `IMPLEMENTED`, plus every reverse-sweep finding, with
where the work belongs. This roll-up is the actionable output.

| # | Item | Verdict | Belongs to | Note |
|---|---|---|---|---|
| 1 | `FR-010` | ABSENT | Implementation Plan §7 | no quota logic in the frontier |
| 2 | `S-04c` | ABSENT | Implementation Plan §12.1 | `[failure]` variant of a shipped parent |
| 3 | `TC-003` | DIVERGENT | **decision needed** | fix the code, or amend Spec §4 — see below |
| 4 | backoff retry | UNSPECIFIED-BEHAVIOUR | Spec §7 as a new `FR-*` | `staged-engineering-doc` can amend |
| 5 | `NFR-001` | UNVERIFIABLE | a human run of the bound perf test | `tests/perf/test_nfr_001.py`; p95 under 400 ms settles it |

*(If there are none: "No gaps — every obligation implemented, and no
unsanctioned behaviour in the frontier.")*
````

---

## Rules

1. **The provenance table is not optional.** Both sides pinned, or the report
   is a snapshot with no expiry date. It is the whole point of Phase 0.
2. **One row per obligation, in Spec order**, grouped by family. The row count
   equals `denominator`. Never merge two IDs into one row, even when one piece
   of evidence settles both — cite the same evidence twice.
3. **Every row cites the locus its axis admits — no row ships without one.**
   There are **three axes**. *Code-axis* rows (`FR-`, `NFR-`, `TC-`, `S-`, and
   `AC-01`–`AC-49`) cite `file:line` at the pinned SHA. *Document-axis* rows — the
   meta-ACs `AC-50`–`AC-54` <!-- closed-set:subset — AC-55 is the supply-chain axis, described next in this same item -->, settled by Phase 2's gates over two documents — cite
   `document §section` instead. *Supply-chain-axis*: `AC-55` alone cites the
   Plan's recorded gate state — `Plan §7.x.9 T-N.D20` (checkbox) + `§5
   Supply-chain` token + any `§14 R-*` waiver rows — because its evidence is a
   scanner run against a lockfile, which is neither code nor prose. Read that
   record; the auditor never re-runs the scanner (`MD-31`). Demanding `file:line`
   from a meta-AC is unsatisfiable, and a rule that cannot be met gets waived,
   which is how the rule stops being enforced for the rows that *can* meet it.
4. **`ABSENT` cites the search, not nothing.** Where it would live, and what was
   looked for. "Not found" without that is unfalsifiable.
5. **The Gaps roll-up repeats — never replaces — the per-row detail.** A reader
   who only reads the roll-up must still get the full picture.
6. **On a re-run**, mark which rows were re-verified against the new SHA and
   which were carried forward, and state the previous run's SHA. A carried row
   is evidence from an older revision, and the reader is entitled to know.
7. The verdict-content rules are `SKILL.md`'s, not this file's — `PARTIAL`
   names both halves, `DIVERGENT` quotes the clause and picks neither remedy,
   no percentage headline, read-only, offer-don't-act, no invented content. The
   renderer's only job is not to drop them. That includes where the report
   itself is written: ask before putting a file inside the audited repository.
