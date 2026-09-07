# Mechanical gates — the deterministic tier

Load this in Phase 2. It runs the methodology's **own** Definition-of-Done
gates against the repository as it stands, instead of inventing a parallel set
of checks that would drift from them.

Most pipelines below are lifted from the bundled
`staged-engineering-doc/templates/IMPLEMENTATION_PLAN_TEMPLATE.md` — the
`T-N.D*` task definitions in §7.2.9 and the auto-derivation block in §12.1 —
but **not all of them**, so re-syncing this file wholesale against the template
would silently revert work. Each section is tagged:

| Tag | Meaning when the template changes |
|---|---|
| *[template]* | A copy. The template wins — re-sync it. |
| *[skill-local — new]* | No template equivalent. Leave it alone. |

The skill-local gates are listed at the end of this file, under *Gates this
skill adds*. Note that an **audited project's** Plan may predate the
methodology's gate corrections (`MD-28`) even though this file matches the
current template — see *Auditing a Plan that predates the gate corrections*.

---

## The interpretation rule

**A gate failure is evidence of a gap. A gate pass is not evidence of an
implementation.**

Every gate here is a *string-matching* check over documents and test names. It
proves a binding exists. It cannot see whether the bound test asserts anything,
whether the asserted behaviour is the one the Spec described, or whether the
code path it exercises is reachable in production.

So: a gate pass is an input to Phase 3, never a verdict. Phase 3 has to
believe or refute it. If the grounded tier never contradicts the gates, the
grounded tier is rubber-stamping — check the contract, not the code.

## Two scoping changes from the template

The template's gates run **per branch, during the build**. This skill runs them
**over the whole Spec, after the fact**. Two consequences:

1. **Drop every "for this branch" restriction.** The denominator is the whole
   Spec (see `SKILL.md`), so each `comm -23` runs against the complete ID set
   and its output is the complete unbound set.
2. **`comm` requires sorted input.** Both sides of every pipeline below end in
   `sort -u`. If you re-tool any of these, keep that.

## What each gate actually measures

Read this table before reporting anything. Three of these gates never look at
code at all — they compare the Spec to the *Plan document*. A pass tells you
two documents agree, which is not a conformance fact.

| Gate | Left side | Right side | Axis |
|---|---|---|---|
| `T-N.D8` | Spec §9 `S-*` + variants | **the test suite** | Spec ↔ code |
| `T-N.D8b` | Spec §9 headings | Spec §9 `Variants:` blocks | intra-Spec structure |
| `T-N.D9` | Spec §8 `NFR-*` | **the test suite** | Spec ↔ code |
| `T-N.D10` | Spec §4 `TC-*` | Plan §12 | Spec ↔ **Plan** |
| `T-N.D15` | — | Plan §12.2 `IMP-*` rows | intra-Plan |
| `T-N.D16` | Spec §8 `NFR-*` | Plan §11 `OBS-*` | Spec ↔ **Plan** |
| `T-N.D17` | Plan §14 `R-*` | their mitigation cells + §7.x.9 tasks | intra-Plan |
| `T-N.D18` | Plan ID citations | their definitions in the same Plan | intra-Plan |
| `T-N.D19` | Plan/Spec ID citations | their defining document | cross-document |
| `T-N.D20` | Plan §5 `Supply-chain` token + `T-N.D20` checkbox | §14 `R-*` waivers for accepted advisories | **Plan recorded state** (read, never re-run) |

Report the Spec ↔ Plan and intra-Plan gates under a heading that says so. A
`TC-*` that `T-N.D10` finds referenced in Plan §12 has been *planned for*, not
*complied with* — its conformance verdict still comes from Phase 3. `T-N.D20`
sits on its own evidence axis: neither code, document-to-document, nor
test-suite, but the Plan's *recorded* supply-chain gate state — the
**third citation axis** the report groups `AC-55` under (see `report-shape.md`),
read never re-run — see its section below.

**Every gate in this table has a section below**, and two facts derive from the
table rather than being enumerated anywhere:

- A gate is **`not-applicable`** when either side names a document that does not
  exist — most often the Implementation Plan. (`T-N.D20` is `not-applicable`
  when there is no Plan to carry the recorded state; a Plan that declares
  `Supply-chain: none — <reason>` is a genuine vacuous **`pass`**, not
  `not-applicable`.)
- A gate is **`unscoped-pass`-eligible** only when one side is *the test suite*.
  (`T-N.D20` has no test-suite side, so it is never `unscoped-pass`.)

Record a row either way. A silently missing gate reads as a gate that passed.

## The two failure modes of lexical matching

Every gate here matches ID tokens against markdown and source text, so every
gate can fail in exactly two ways: **wrong namespace** (the token is real but
belongs to something else) and **wrong token boundary** (the token was never
there). Both were observed on the first real run of this skill, and both produce
a **false clean result** — the dangerous direction. Anything new that goes wrong
here will be one of these two; give it a home rather than a third subsection.

### 1. Wrong namespace — IDs are numbered per document, not per repository

`S-01` means one thing in one feature's Spec and something else in another's.
The methodology numbers IDs *within* a document (`MD-05`), so a repository with
several features has several independent `S-01`s, `FR-001`s and `AC-01`s.

A gate whose right-hand side is the whole `tests/` tree therefore passes on
**other features' bindings**. Observed: a Spec's twelve scenarios all appeared
"covered" by `T-N.D8` while every matching test belonged to three unrelated
features that happened to reuse `S-01`–`S-25`.

**Scope the right-hand side to this feature before running anything:**

1. Best — the test paths named in Plan §12.1 and §16. They are this feature's
   tests by definition.
2. Otherwise — the feature's own test directory or file-naming convention,
   confirmed by reading a couple of the files rather than assumed from a name.
3. Otherwise — intersect with files that git attributes to the feature's
   branches or to commits citing its IDs.

If none of these scopes it, record the gates with a test-suite side as
`unscoped-pass` rather than `pass` — an unscoped pass is not weak evidence, it
is no evidence. Failures stay meaningful (nothing anywhere binds that ID), so an
unscoped run still has one useful direction. Every other gate compares documents
to documents and is unaffected; report those normally.

### 2. Wrong token boundary — a bare prefix matches inside a longer one

`grep -oE "FR-[0-9]+"` matches the tail of every **`NFR-`**. Observed: a Spec
with 18 FRs and 9 NFRs enumerated as 22 FRs, four of them phantoms
(`FR-006`–`FR-009` are really `NFR-006`–`NFR-009`).

**The rule is unconditional: never grep a bare prefix.** Always enumerate with
the anchored form:

```bash
spec_ids() {  # spec_ids <PREFIX> <FILE>  — e.g. spec_ids FR "$SPEC"
  grep -oE "(^|[^A-Za-z])$1-[0-9]+[a-z]*" "$2" | sed -E 's/^[^A-Za-z]//' | sort -u
}
tmp=$(mktemp)   # scratch for section slices; several gates below reuse it
```

Define both once at the top of the Phase 2 session; every pipeline below calls
`spec_ids` rather than restating the regex.

### `spec_clause` — the companion for Phase 3

Phase 3 must hand each agent the **verbatim normative text** of its IDs, not a
Spec path to re-read. Doing that by hand is a chore the orchestrator will skip
under load, so it is mechanical too — the templates give each family exactly one
of three shapes (a `- **ID** —` bullet, a `| ID |` table row, or a
`#### Scenario ID —` block):

```bash
spec_clause() {  # spec_clause <ID> <FILE>  — the text that DEFINES <ID>
  awk -v id="$1" '
    BEGIN { bullet="^- \\*\\*" id "\\*\\*"
            row="^\\| *" id " *\\|"
            head="^#+ .*[^0-9A-Za-z]" id "([^0-9A-Za-z]|$)" }
    $0 ~ bullet || $0 ~ row { print; exit }
    $0 ~ head { inblk=1; print; next }
    inblk && /^#+ / { exit }
    inblk { print }
  ' "$2"
}

# Build one cluster's payload:
for id in $CLUSTER_IDS; do printf '### %s\n' "$id"; spec_clause "$id" "$SPEC"; done
```

It returns the defining line for bullet and table families and the whole
Given/When/Then block for a scenario, stopping at the next heading. Verify the
line count is non-zero per ID before shipping a payload — a silent empty clause
means the agent judges an obligation it was never shown.

Two properties make this the *only* form worth knowing, so no table of
endangered prefixes is needed and none is maintained here:

- **The strip is prefix-independent.** `(^|[^A-Za-z])` captures at most one
  character, so `sed -E 's/^[^A-Za-z]//'` removes exactly the boundary and
  nothing else — whatever the prefix. A per-prefix strip (`s/^[^F]+//`) is what
  forced a separate pipeline per family.
- **It is a no-op where it is not needed.** The `[a-z]*` suffix is harmless on
  families without variants and the anchor is harmless on families without a
  superstring — verified: anchored and bare `TC-` enumeration over
  `SPEC_TEMPLATE.md` return identical sets.

Tracking *which* prefixes are currently endangered is not worth doing, because
the set changes whenever a family is added. It is already wider than it looks:
alongside `FR-` inside `NFR-`, `S-` inside `US-`/`OBS-` and `D-` inside
`TD-`/`MD-`, the `migration-methodology` extension this skill is told to sweep
(`SKILL.md`) defines **`PAR-`**, which makes a bare `R-` grep report a phantom
`R-01` on every Parity Plan row. Use the anchored form and the question never
arises.

For the same reason, the template's `T-N.D19` recipe cannot simply be copied —
see that section below.

## Enumerate files through git, never a bare recursive grep

**Every `grep -r` in this file must be confined to files git tracks at the
pinned SHA.** A working repository routinely contains other checkouts of
*itself* — nested worktrees under `.claude/worktrees/`, sibling clones,
vendored trees, build output — and a recursive grep walks straight into them.

Observed on the first real run: an audited repository held **35 nested
worktrees**, and a naive recursive grep for one feature function returned **147
hits, 141 of them inside those worktrees** — other branches, different content.
The audited file was one of six candidates, and nothing in the output said so.

That is worse than a false gate result. It is *false evidence*: a verdict cited
to a real path, at a real line, containing real code — from a different branch.

```bash
# Wrong — walks nested worktrees, vendored trees, build output:
grep -rEho "$TS_RE" tests/

# Right — only what git tracks at the pinned SHA:
git -C "$REPO" ls-files -z -- 'tests/*' | xargs -0 grep -Eho "$TS_RE"
```

Use `git ls-files` (or `git grep`, which honours the same index) for both sides
of every gate and for the test-root probe. If a path must be walked directly,
prune explicitly: `--exclude-dir=.claude --exclude-dir=node_modules
--exclude-dir=.venv`, and reject any candidate under a directory that itself
contains a `.git` entry.

## Locating the test suite

`tests/` is the template's placeholder, not a promise. Before running anything,
find the real test root(s) from Plan §5 *Engineering rules / project
conventions* (the `Tests` row), falling back to the project's actual layout
(`test/`, `spec/`, `src/**/__tests__/`, `*_test.go` beside sources). A pipeline
pointed at a directory that does not exist returns every ID as unbound — an
empty right-hand side reads as catastrophic drift and is really a typo.

## Picking the binding variant

Plan §5's `Binding` row records which convention the project chose, as one of
the closed tokens `variant-a` / `variant-b` / `none` (`MD-28`). Read it first —
the variants are not interchangeable, and **Variant A run against function-name
bindings silently reports every scenario as uncovered**, because identifiers
cannot contain hyphens.

`Binding: none` means the branch has nothing to bind — no in-scope scenarios and
no quantified NFRs — and the gate passes vacuously. It is **not** an opt-out: a
Plan that declares `none` while its Spec carries scenarios or quantified NFRs is
in violation of `AC-50`/`AC-51`, which Spec §17 lists as non-relitigable. Report
that as a finding rather than accepting the declaration and skipping the tier.

A Plan predating `MD-28` records the convention as free prose in the `Tests` row
with no `Binding` token; treat that as the *no convention recorded* case below
and report the missing token (see *Auditing a Plan that predates the gate
corrections*).

If §5 records no convention at all, probe both — but **non-emptiness is not a
valid selector.** Variant B's regex matches any test identifier containing a
digit, so a single `test_s3_upload` normalises to a phantom `S-3`, makes
Variant B look populated in a Variant A project, and the gate then returns every
scenario as unbound.

Select on **intersection with the Spec's ID set** instead:

1. Run both variants.
2. For each, intersect its output with the Phase 1 obligation set
   (`comm -12`). Pick the variant with the larger intersection.
3. If both intersections are empty, **no convention is in use** — record those
   gates as `no-convention`, not as a total failure: a project with no binding
   convention has no binding to find. That is a Spec-quality finding, not
   100 % drift.
4. Note in the report which variant was inferred and what its intersection was,
   so a reader can see the inference rather than inherit it.

---

## `S-*` — scenarios and variants (`AC-50`, code axis)

*[template — §12.1 auto-derivation block]*

Spec-side enumeration **must left-anchor** so `US-NN` user-story IDs do not
false-match:

```bash
# Left side — every scenario and variant declared in the Spec:
spec_ids S {{path/to/SPEC.md}}
```

**Variant A — string / mark / annotation bindings (the recommended
convention).** The regex anchors the ID to a recognised binding context so a
mention in a comment (`# similar to S-04 but different`) is not counted as
coverage:

```bash
TS_RE='(scenario\("|nfr\("|tc\("|it\(["'"'"']|t\.Run\("|test_case\(")S-[0-9]+[a-z]*'
grep -rEho "$TS_RE" {{path/to/tests/}} | grep -oE "S-[0-9]+[a-z]*" | sort -u
```

**Variant B — function-name bindings** (`test_S_04a_…`, `TestS04a_…`,
`fn s_04a_…`). The `sed` normalises back to the canonical hyphenated form:

```bash
TS_RE='(test_|Test|fn s_)S?[-_]?[0-9]+[a-z]*'
grep -rEho "$TS_RE" {{path/to/tests/}} \
  | grep -oE '[Ss][-_]?[0-9]+[a-z]*' \
  | sed -E 's/[Ss][-_]?([0-9]+[a-z]*)/S-\1/' \
  | sort -u
```

The diff is the unbound set:

```bash
comm -23 <(left side) <(chosen variant)
```

**Reading the output.** An `S-*` here has no test bound to it. That is an
`AC-50` violation and strong evidence for `ABSENT`/`PARTIAL` — but the verdict
is still Phase 3's, because a scenario can be implemented in code and simply
untested. Record it as *unbound*, and let the grounded tier decide whether it is
*unimplemented*.

## `S-*` — Variants-block presence (`AC-50`, structural half)

*[template — `T-1.D8b`]*

`comm -23` can only diff IDs that exist; a scenario whose author never thought
about variants has nothing to diff. This awk lint catches that — it is
fence-aware and handles multi-level headings:

(Four-backtick fence: the script matches a literal triple backtick, which would
close a three-backtick one.)

````bash
awk 'BEGIN{in_fence=0}
  /^```/{in_fence=!in_fence; next}
  in_fence{next}
  /^#{2,5} +Scenario +S-[0-9]+([^a-z0-9]|$)/ {
    if(current!="" && !found) print "MISSING Variants block: " current;
    current=$0; found=0; next }
  /^[ \t]*\*\*Variants:\*\*/ || /^[ \t]*Variants: *none/ {found=1}
  END{if(current!="" && !found) print "MISSING Variants block: " current}' {{path/to/SPEC.md}}
````

Output means the **Spec** is structurally incomplete, not that the code drifted.
Report it under the Spec-quality findings, not as a conformance verdict — and
note that unenumerated variants mean the denominator itself is understated: the
audit cannot measure edge cases nobody wrote down.

## `NFR-*` — measurement tests (`AC-51`, code axis)

*[template — `T-1.D9`]*

No `[a-z]*` suffix (NFRs have no variants) and no left-anchor needed (no
substring risk):

```bash
# Left side:
spec_ids NFR {{path/to/SPEC.md}}

# Variant A:
TN_RE='(nfr\("|it\(["'"'"']|t\.Run\("|test_case\(")NFR-[0-9]+'
grep -rEho "$TN_RE" {{path/to/tests/}} | grep -oE "NFR-[0-9]+" | sort -u

# Variant B (case-insensitive for Rust lowercase identifiers):
TN_RE_FN='(test_|Test|fn )[Nn][Ff][Rr][-_]?[0-9]+'
grep -rEho "$TN_RE_FN" {{path/to/tests/}} | sed -E 's/.*[Nn][Ff][Rr][-_]?([0-9]+).*/NFR-\1/' | sort -u
```

**Each prefix has its own literal binding pipeline — never substitute one
prefix into another's.** They differ in two parameters (variant suffix allowed,
case-insensitivity) that are per-family facts.

**Only quantified NFRs are in `AC-51`'s scope.** Phase 1 recorded which those
are. An unquantified NFR ("the system shall be maintainable") has nothing to
measure; its verdict comes from reading, and its unquantifiability is itself a
Spec-quality finding worth reporting.

## `TC-*` — compliance evidence (`AC-52`, **Plan axis**)

*[template — `T-1.D10`]*

```bash
sed -n '/^## 12\./,/^## 13\./p' {{path/to/PLAN.md}} > "$tmp"
comm -23 <(spec_ids TC {{path/to/SPEC.md}}) <(spec_ids TC "$tmp")
```

This accepts both forms of evidence — a runnable test *or* a named reviewer /
checklist — because TCs are heterogeneous and review remains valid verification
for non-mechanical ones. That tolerance is also why it proves so little about
the code: **a `TC-*` can pass this gate on the strength of a sentence in the
Plan.**

Constraints are also the family where the forward sweep inverts. A `TC-*` is
violated by **one counterexample** and satisfied only by the absence of any —
so Phase 3 searches for violations, not for confirmations. Note that in the
cluster prompt.

## `NFR-*` → observability (`AC-54`, **Plan axis**)

*[template — `T-1.D16`]*

```bash
sed -n '/^## 11\./,/^## 12\./p' {{path/to/PLAN.md}} > "$tmp"
comm -23 <(spec_ids NFR {{path/to/SPEC.md}}) <(spec_ids NFR "$tmp")
```

Output is a quantified NFR with no `OBS-*` signal bound to it: nothing in
production will ever tell anyone whether it holds. Report it as a gap even when
the NFR's own verdict is `IMPLEMENTED` — an unmeasured NFR is a claim with no
expiry date.

## `IMP-*` — impact enumeration (`AC-53`, intra-Plan floor)

*[template — `T-1.D15`]*

```bash
sed -n '/^### 12\.2/,/^### 12\.3/p' {{path/to/PLAN.md}} | grep -cE "^\| *IMP-[0-9]+"
```

A non-emptiness floor, not a coverage check — which scopes materially apply is
a judgement the gate cannot make. Zero means `AC-53` fails outright.

## `R-*` — risk mitigation paths (`T-N.D17`, intra-Plan)

*[template — `T-1.D17`]*

Every risk in Plan §14 must record a mitigation path — a `T-N.*` task, an
`accepted (rationale: …)`, or a `monitored only — see OBS-NN`. The mechanical
half checks that every `T-N.*` *cited* in §14 resolves to a task *defined* in
some §7.x.9 checklist:

```bash
comm -23 <(sed -n '/^## 14\./,/^## 15\./p' {{path/to/PLAN.md}} \
             | grep -oE "T-[0-9]+\.[A-Z]?[0-9]+" | sort -u) \
         <(grep -oE "^- \[[ x]\] T-[0-9]+\.[A-Z]?[0-9]+" {{path/to/PLAN.md}} \
             | grep -oE "T-[0-9]+\.[A-Z]?[0-9]+" | sort -u)
```

The right side is restricted to checkbox-**defined** task IDs on purpose —
matching every mention in the file would let §14's own references satisfy
themselves and the gate would never fire.

Reading empty mitigation cells is a manual scan of the §14 table; the `comm`
only catches dangling task references. Both halves matter here: a risk with a
mitigation task that does not exist is worse than one openly marked `accepted`.

**Why a conformance audit cares.** A risk whose mitigation task was never
written is a risk nobody built for — so if Phase 3 also finds the corresponding
behaviour `ABSENT`, this gate tells you it was never planned rather than
dropped in implementation.

## Intra-Plan self-consistency (`T-N.D18`)

*[template — `review-passes.md` Pass 1]*

**Not a shell gate.** `T-N.D18` is referential integrity *within* the Plan:
every ID referenced from one section resolves to a definition in another, and
every `OPEN-Q-*` in §15.1 is either marked resolved with a pointer or carried
forward. The methodology puts its recipe in
`staged-engineering-doc/references/review-passes.md` (Pass 1), not in a
pipeline, because it is a read-and-check pass.

Run it as written there, and record the result in the gate table as a pass/fail
with the dangling IDs listed. Two cautions carried over from that file:

- **Referential integrity only.** Non-contiguous numbering is intended
  (`FR-001`, `FR-010`, `FR-020` …). Never report a numbering gap as a defect.
- Any anchoring rule from the substring table above applies here too, since the
  pass greps the same prefixes.

## Cross-document ID integrity (`T-N.D19`)

*[template]*

**The left-anchor is load-bearing.** A bare `grep -oE "<PREFIX>-[0-9]+"`,
substituted across `FR`/`NFR`/`TC`/`AC`/`S` and `D`, hits both failure modes
above — and here they are one-directional, because the Plan-only families
(`OBS-`, `TD-`) put phantoms on the Plan side that the Spec/Concept side cannot
cancel. `comm -23` then emits pure fabrications. The template carries the
anchored form (`MD-28`); `spec_ids` is that same form parameterised by prefix,
which makes the whole gate one loop:

```bash
for p in FR NFR TC AC S; do
  echo "=== $p ==="
  comm -23 <(spec_ids "$p" {{path/to/PLAN.md}}) <(spec_ids "$p" {{path/to/SPEC.md}})
done
echo "=== D ==="
comm -23 <(spec_ids D {{path/to/PLAN.md}}) <(spec_ids D {{path/to/CONCEPT.md}})
```

Any output is a **dangling reference** — the Plan cites an ID that does not
exist. For this skill it matters twice over: a dangling ID means the Plan
attribution column cannot be trusted for that row, and it is often the fossil of
a renumbered or deleted requirement that the code may still implement.

## Supply-chain (`T-N.D20`) — read the record, never re-run (`MD-31`)

*[skill-local — the one gate settled by reading, not by matching tokens]*

`T-N.D20` gates `AC-55`. Unlike every other gate here, it does **not** compare
tokens across documents or against code — it executes a vulnerability scanner
against a lockfile, which is live, non-deterministic, and read-write on the
network. `spec-conformance` is read-only and reproducible-at-a-pinned-SHA, so it
never re-runs the scanner. It settles `AC-55` by **reading the Plan's recorded
state**:

- the branch's `T-N.D20` DoD checkbox in §7.x.9,
- the §5 `Supply-chain` token (a lockfile path, or `none — <reason>`),
- any §14 `R-*` rows that waive an accepted advisory.

Verdicts: a checked box with a lockfile token and no unwaived advisory → the
row is `IMPLEMENTED`; a declared `Supply-chain: none — <reason>` → `IMPLEMENTED`
(vacuous, and correct — nothing to scan); an unchecked box with neither a
`none` token nor a disclosed-offline marker → `ABSENT`; a waiver `R-*` whose
rationale cell is empty → `PARTIAL`. The gate covers whether the scan ran clean;
it does **not** cover whether each waiver's *rationale* is adequate — that is
reviewer judgement (see the `AC-55` row in *two populations* below). Because the
evidence is a committed record rather than a fresh scan, the verdict is stable
across re-runs at the same SHA even though the gate itself is deliberately
time-varying.

## `FR-*` — no gate exists

*[skill-local — new; the methodology gates no FRs]*

**The methodology never gave functional requirements a binding convention**, so
there is no pipeline here and none is missing. `AC-50` gates `S-*`, `AC-51`
`NFR-*`, `AC-52` `TC-*`; FRs are covered only transitively, through whichever
scenarios happen to cite them in Spec §9.

Consequences for the audit, both worth stating in the report:

- **Every `FR-*` verdict comes entirely from Phase 3.** There is no cheap tier
  for the largest family in the Spec.
- **An `FR-*` that no scenario cites has no mechanical coverage anywhere in the
  methodology.** Enumerate those in Phase 1 and mark them; they are the IDs most
  likely to have been quietly dropped, because nothing in the build would have
  complained.

A partial substitute worth running — which FRs are cited by any scenario.
**Both sides must left-anchor**, or every `NFR-0NN` enters the left side as a
phantom `FR-0NN` and is reported as an uncovered requirement that does not
exist:

```bash
comm -23 <(spec_ids FR {{path/to/SPEC.md}}) \
         <(sed -n '/^## 9\./,/^## 10\./p' {{path/to/SPEC.md}} > "$tmp"; spec_ids FR "$tmp")
```

Output is the set of FRs no scenario exercises. That is a Spec-quality finding
in its own right — and a priority list for Phase 3.

## `AC-*` — two populations

*[skill-local — new; how far each meta-AC's gate actually reaches]*

`AC-50`–`AC-55` are the **meta-ACs** of Spec §11.5. The gates above settle them
— but a gate's reach is narrower than the criterion's wording in every case but
one. Treating the gate result as the verdict reports a partly-checked criterion
as satisfied, which is a false `IMPLEMENTED` in the family whose whole job is
proving the traceability fabric holds.

| Meta-AC | Gate covers | Gate does **not** cover |
|---|---|---|
| `AC-50` | scenario/variant → test binding (`T-N.D8` + `D8b`) | the §16 *AC coverage* reference — **reviewer-checked by design, not gateable** (see below) |
| `AC-51` | quantified NFR → measurement test (`T-N.D9`) | — whole criterion |
| `AC-52` | TC → Plan §12 entry (`T-N.D10`) **and** TC → §11.3 compliance check (`T-N.D10b`) | — fully gated |
| `AC-53` | ≥1 `IMP-*` row (`T-N.D15`) | — whole criterion (the per-scope judgement is explicitly non-mechanical) |
| `AC-54` | quantified NFR → `OBS-*` row (`T-N.D16`) | — whole criterion |
| `AC-55` | lockfile scans clean, *or* `Supply-chain: none` declared (`T-N.D20`, read from the record) | the **waiver-rationale half** — whether each `§14 R-*` waiver's reason is *adequate* is reviewer judgement, not gateable. `spec-conformance` reads the recorded `T-N.D20` state and never re-runs the scanner (`MD-31`); a fresh scan would be non-reproducible at the pinned SHA. |

**Do not build a `comm` check for `AC-50`'s §16 clause.** §16 legitimately
cites scenario *ranges* (`covers S-01..S-09`), so any check that enumerates IDs
reports every scenario inside a range as missing — the Plan template's own
example fails it. The methodology relaxed that clause to reviewer-checked
rather than invent a check that cannot work (`MD-28`); a gate that reports
fabricated misses is worse than no gate, because it trains reviewers to
override. Judge the clause by reading §16, and report what you find as a
Spec-quality observation, not a gate result.

**A conjunctive meta-AC is `IMPLEMENTED` only when every conjunct passes.** One
side passing and the other failing is `PARTIAL`, naming which half held — and a
conjunct that could not be run (no Plan, no §11.3) makes it `UNVERIFIABLE`, not
`IMPLEMENTED`.

`AC-01`–`AC-49` are the project's own acceptance criteria. They have no binding
convention of their own — by design, since ACs aggregate scenarios and tests do
not carry AC IDs. Their mechanical input is Plan §16 *Acceptance criteria
coverage*, where a blank `Satisfied by` or `Test` cell is a declared gap:

```bash
sed -n '/^## 16\./,/^## 17\./p' {{path/to/PLAN.md}} | grep -E "^\| *AC-[0-9]+"
```

Read the rows for empty cells, then resolve the referenced tests through the
§12.1 matrix. An AC whose row is absent from §16 entirely is a stronger finding
than one with a blank cell — the first was never considered, the second was
considered and left open.

---

## Gates this skill adds

Two sections above have no template equivalent, and neither should be re-synced
away: **`FR-*` — no gate exists** (the methodology gates no FRs, so the whole
family routes to the grounded tier) and **`AC-*` — two populations** (how far
each meta-AC's gate actually reaches, which the template does not state).

`FR-*` having no binding convention is **not** a defect: the methodology's
choice is deliberate, inventing one would be a breaking template change
(`MD-30`, rejected alternative 4), and the skill's response — route `FR-*`
entirely to the grounded tier and report the absence — is the intended
handling.

---

## Auditing a Plan that predates the gate corrections

The recipes in this file match the current template. An **audited project's**
Plan may not: `MD-28` corrected three things, and a Plan generated before it
carries the uncorrected forms.

| What you may find in the audited Plan | Why it matters |
|---|---|
| `T-N.D19` with a bare `grep -oE "<PREFIX>-[0-9]+"` | Emits phantom dangling references — a Plan with `OBS-0N` rows reports scenarios `S-0N` that were never written; `TD-`/`MD-` do the same to `D-`. Because it is a *merge* gate, the project has been overriding it or ignoring it. |
| No `T-N.D10b` | `AC-52`'s §11.3 conjunct was never mechanically checked, so a Spec with an empty §11.3 gated clean while reporting its traceability fabric intact. |
| Plan §5 recording the test-binding convention in free prose, with no `Binding:` token | `T-N.D8`'s two regex variants are not interchangeable; picking the wrong one silently reports *every* scenario as uncovered. This skill's inference is the fallback — see the binding section above. |

**Report these; do not silently absorb them.** Each is a Spec-quality finding
about the project's own gates, and gets the same treatment as an unquantified
NFR or a missing `Variants:` block. The skill is uniquely placed to notice,
because it reads the Plan. Run this file's recipes regardless — they are
correct — but say in the report that the project's Plan carries the
uncorrected ones, and point at `MD-28`.
