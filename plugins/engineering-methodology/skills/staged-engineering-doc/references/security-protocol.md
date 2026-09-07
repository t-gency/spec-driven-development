# Security protocol (MD-31)

Shared security-discipline reference for the `staged-engineering-doc` skill. Applies to all three doc types (Concept Note, Spec, Implementation Plan) and defines what the methodology's *security-as-first-class* discipline (MD-31) obliges at each stage.

Referenced by the `SKILL.md` operating principle *Security posture (MD-31)* (which this file elaborates), by Concept Note §5.2 *Security posture*, by Spec §4.5 *Security constraints* + §11.5 meta-`AC-55`, and by Plan DoD gate `T-N.D20`. The `critic-rubric.md` Dim 5 row *Security posture (MD-31)* enforces this protocol at review time. Kept as a reference file (per `MD-13` progressive disclosure) so `SKILL.md` stays lean.

---

## Scope — read this first

**This protocol is about the security posture of the software the user is specifying.** It is not about the security of the agent authoring the docs, not about the security of the plugin itself, not about the security of the toolchain the methodology runs on. When a user is specifying an AI-based feature (one that processes user text or feeds untrusted content to a model), the CWEs applicable to *their* feature belong here as ordinary `TC-*` rows citing the relevant CWE identifiers — including AI/ML-specific CWEs where they exist. Meta-security concerns about running the methodology are legitimate but out of scope for MD-31 and this protocol.

The distinction matters because it keeps the discipline actionable: the author is writing a Spec for a payment gateway, not writing a Spec for the Claude Code invocation that helps them write the Spec.

## Security is a design consideration — not a post-hoc check

This protocol's three touchpoints — Concept §5.2 posture, Spec §4.5 constraints, Plan `T-N.D20` gate — are all *design* work. The §5.2 posture SHAPES the feature's architecture and pattern selection (what stays inside the trust boundary, what treats input as untrusted, what encrypts). The §4.5 TCs are CONSTRAINTS ON THE SOLUTION — they narrow what the code can look like, not just what must be tested afterward. The `T-N.D20` gate is the mechanical floor beneath the design work, catching one specific class of supply-chain debt.

The checks the rubric grades exist because design decisions need to be **visible and reviewable** — not because compliance is the goal. A Spec with no §4.5 constraints is not a Spec that has proven security; it is a Spec that has not designed for security. NIST SSDF `PW.1` names the orientation verbatim: *"**Design** Software to Meet Security Requirements and Mitigate Security Risks"* — the verb is *design*, not *audit*.

## Structural floor, not ceiling

MD-31 mandates **one** closed vocabulary (CWE Top 25 for §4.5 TCs) and **one** mechanical gate (CVE lockfile audit at Plan DoD). This is the *minimum every feature that adopts this methodology must clear* — the STRUCTURAL FLOOR. It is not the extent of security work.

**Additional security work remains legitimate and expected per feature complexity**, and belongs in the same three artefacts:

- **Threat modeling** (STRIDE for security, LINDDUN for privacy) — for features crossing trust boundaries. The Threat Modeling Manifesto's four questions (`https://www.threatmodelingmanifesto.org/`) parallel this methodology's doctrine tone: *what are we working on / what can go wrong / what are we going to do about it / did we do a good enough job*.
- **Secure design patterns** — least-privilege by default, secure defaults, defense-in-depth, fail-closed. High-value flows warrant these; the §5.2 posture is the place to declare them.
- **Penetration testing** — public-internet surfaces warrant this; the Spec's §11.5 or the Plan's §14 can commit to it as an AC or R-\* row.
- **Security code review** as part of PR review — orthogonal to the automated `T-N.D20` gate.
- **Dependency-provenance verification** (SLSA-level attestations, signed builds) — above the CVE-lookup floor.
- **Secret scanning, SAST, DAST** in CI — orthogonal to the mechanical CVE gate; project-level CI concerns.
- **AI-agent-specific hardening** (prompt-injection defence, least-privilege tool access, output filtering) — when the feature *is* an AI agent, these belong here as ordinary `TC-*` rows citing the relevant CWE identifiers (or the current OWASP LLM Top 10 categories when a CWE hasn't yet been assigned).

**How to add work above the floor:** declare it in Concept §5.2 as part of the posture ("this feature commits to a STRIDE threat model, penetration testing before public GA, and SLSA L3 provenance"), and land the concrete obligations as additional §4.5 TCs, additional §11 ACs, or additional Plan §14 R-\* rows citing whatever standard applies. The escape valve is the same MD-25 pattern — **declared work is visible, silent absence is disallowed**. If a project skips a category the field would consider essential for that feature type, the Concept §5.2 declaration makes the choice visible to the rubric and the reviewer.

What this MD **rules out** is silent absence at the floor. What it does **not** rule in is a cap on what a project can do above it.

## No snapshots — retrieve security standards live, at the moment they are consulted

**This methodology never embeds a snapshot of a security standard.** The CWE Top 25, the ASVS release, the SLSA level ladder, the CVE advisory database — all are moving targets, and pinning any of them into a static file guarantees the discipline drifts silently within months. Instead, each canonical URL below **resolves to whatever the current stable release is at the time the URL is retrieved**. The agent retrieves it live (an HTTPS GET against the canonical URL, evaluated at the moment the standard is consulted — no bundled copy, no cached snapshot in the plugin) at three moments: (1) authoring the Spec's §4.5 TCs, (2) running the rubric's Dim 5 pass, (3) executing the Plan's `T-N.D20` gate. If the environment cannot fetch external URLs (air-gapped, offline, blocked-by-proxy), the derived content is tagged `[UNVERIFIED — offline; last known <standard> as of <date>]` per `MD-26`'s trust-but-verify discipline, and the rubric grades that condition — a `[UNVERIFIED]` on the security-standards retrieval is 🟡 (author disclosed) rather than 🔴 (author neither verified nor disclosed).

*(In Claude Code specifically, the retrieval is a `WebFetch` tool invocation; other agent environments use whatever their equivalent primitive is. The methodology names the action — retrieve the URL over HTTPS — not any particular tool.)*

The two exceptions to the no-snapshot rule are:

1. **Verbatim quotes from a standard's normative clause**, when the exact wording *is* the citation (e.g. NIST SSDF `PW.1.1` quoted verbatim in `DESIGN_RATIONALE`'s `MD-31` row). The URL still resolves to current-stable, but the quoted clause is naturally tied to the revision it was quoted from. Re-quoting on a standards refresh is a rubric-review responsibility.
2. **Tool commands that pin a specific *tool* version** for reproducibility. `T-N.D20`'s `osv-scanner` invocation does *not* pin a scanner version (the tool self-updates its advisory DB); a project that requires reproducible builds can pin the tool version in its own `AGENTS.md`, but the methodology does not.

## Standards this protocol references (URLs resolve to current-stable)

| Standard | Canonical URL | What we use it for |
|---|---|---|
| CWE Top 25 (CISA / MITRE) | `https://cwe.mitre.org/top25/` | Closed vocabulary for §4.5 security TCs. Annual refresh, each December. |
| CWE base catalog | `https://cwe.mitre.org/data/` | Full CWE-XX definitions cited in TC bodies. |
| OWASP ASVS | `https://owasp.org/www-project-application-security-verification-standard/` | Level (L1/L2/L3) selection for the Spec's declared assurance target. |
| OWASP Top 10 | `https://owasp.org/Top10/` | *Awareness* document; cite explicitly as awareness-not-checklist to warn against using it as a compliance list. |
| OWASP Top 10 for LLM Applications | `https://genai.owasp.org/llm-top-10/` | Fallback vocabulary for AI-agent features when a CWE hasn't been assigned to a specific LLM-native risk (LLM01 Prompt Injection, LLM02 Insecure Output Handling, …). Same "current-stable resolves live at URL" retrieval discipline as the other rows. |
| NIST SSDF SP 800-218 | `https://csrc.nist.gov/pubs/sp/800/218/final` | Doctrinal envelope for design-time security requirements (`PW.1`). |
| SLSA Build Track | `https://slsa.dev/spec/` | Supply-chain assurance level a project targets; informs `T-N.D20`. |
| OSV / osv-scanner | `https://github.com/google/osv-scanner` | Default supply-chain scanner. |
| Threat Modeling Manifesto | `https://www.threatmodelingmanifesto.org/` | Not required, but useful envelope framing for the four-question shape of the discipline. |

If a URL 404s or redirects to a superseded page, that is a signal the standard moved — retrieve the parent URL over HTTPS to find the current publication and note the move in the Spec's provenance if it changes a TC-selection outcome.

## Concept Note §5.2 — Security posture (three lines)

The Concept Note declares three things, in a single paragraph or three short bullets. The declaration selects which CWE categories the downstream Spec has to consider; a category ruled out at Concept time does not need a TC in Spec §4.5 (but the ruling itself is a citation).

**Line 1 — Feature exposure.** Does this feature process untrusted input, and from what actor class? Examples:

- *"External HTTP input from public API consumers."*
- *"Uploaded files from authenticated internal users."*
- *"No external input — internal batch process reading trusted internal storage."*

**Line 2 — Data sensitivity.** Which regulated / sensitive data classes flow through this feature?

- *"PII, PHI (HIPAA scope), and payment card data (PCI scope in-scope for §4.3 TCs too)."*
- *"Session tokens and refresh credentials."*
- *"None regulated — public non-PII data only."*

**Line 3 — Deployment surface.** Where does this feature run?

- *"Public REST endpoint behind auth gateway."*
- *"Internal service behind mTLS; not reachable from the public internet."*
- *"Embedded library consumed by first-party services only."*

> **On altitude (`MD-01`).** The deployment-surface line names the *trust context* the feature is being designed against — "reachable from the public internet" vs "first-party only" changes which CWE categories are in scope — not the Plan's deployment mechanics (which gateway, which mesh, rollout order). It is a *why-this-security-shape* statement, so it stays in the Concept Note's lane; the Plan still owns the *how*. Keep the line at that altitude (a trust boundary, not a topology) and the `MD-01` rubric row has nothing to flag.

**Escape valve — same shape as `MD-25`'s declared-none pattern.** If no security posture applies, write it once, explicitly:

> **Security posture:** internal-only, no external input, no regulated data — no CWE Top 25 categories in scope; §4.5 will declare `Security constraints: none — see Concept §5.2 posture`.

**Silent absence is disallowed** — the same rule `MD-25` §6.5 applies. A Concept Note without a §5.2 declaration fails the rubric's Dim 5 *Security posture (MD-31)* row 🔴.

## Spec §4.5 — Security constraints (TC-* rows citing CWE)

Every CWE category the Concept §5.2 posture declared applicable produces at least one `TC-*` row in Spec §4.5. Each row cites its CWE identifier verbatim in the TC body — the CWE number is *content of the row*, not a new ID prefix (`MD-05`'s one-prefix-per-section discipline is preserved).

**Example rows:**

- **`TC-040`** — user-supplied file paths shall be resolved through the sandboxed-path helper (`<repo>/util/safepath.ts`) before any filesystem access, **defends `CWE-22` *Improper Limitation of a Pathname to a Restricted Directory ('Path Traversal')***.
- **`TC-041`** — all HTML rendered from user-supplied content shall be produced by the templating layer's auto-escaping API; direct concatenation into HTML output is a lint violation, **defends `CWE-79` *Cross-Site Scripting***.
- **`TC-042`** — SQL query construction shall use the parameterized-query API of the DB driver; string interpolation into SQL text is a lint violation, **defends `CWE-89` *SQL Injection***.

**The `defends CWE-XX` phrase is the machine-readable marker.** A convenience-check `grep -oE 'CWE-[0-9]+' SPEC.md` returns every CWE the Spec commits to; cross-checking that set against the current Top 25 (retrieved live from `https://cwe.mitre.org/top25/` at the time of the check) surfaces coverage gaps. This is a *convenience*, not a mechanical gate — the semantic correctness of a TC's defence claim requires human or LLM judgement (`MD-25`'s and `MD-26`'s argument for staying rubric-based on this class).

**A category the Concept §5.2 posture ruled out** still needs a one-line entry in Spec §4.5, but as a ruling not a commitment:

> **`CWE-79` *XSS*** — not applicable; §5.2 posture declared no HTML rendering surface. (Ruling out; no TC follows.)

**Outside-Top-25 escape.** A feature may legitimately need a TC citing a CWE outside the current Top 25 — LLM01 *Prompt Injection* from OWASP LLM Top 10, CWE-1039 *Inadequate Neutralization of Special Elements Used in AI/ML Prompt*, or a domain-specific CWE the CISA scoring didn't rank this year. The escape mirrors `MD-27`'s `Custom arc: <N> — <reason>` shape: cite the CWE (or the OWASP-LLM category) and add a one-line reason for outside-Top-25 inclusion.

> **`TC-045`** — model-input strings shall be passed through the prompt-neutralisation layer before concatenation with system prompts, **defends `CWE-1039` *Inadequate Neutralization of AI/ML Prompt Elements*** — *outside Top 25: LLM-native risk absent from CISA's general-code ranking, called out by the feature's §5.2 posture (`Feature exposure`: user text fed to LLM).*

**Meta-`AC-55` (supply-chain integrity).** New in §11.5, alongside `AC-50`..`AC-54`:

> **`AC-55`** — Every direct and transitive dependency in the branch's committed lockfile passes a current-advisory-DB check with **no unwaived advisory** (the scanner exits clean); any advisory the team accepts is cited in Plan §14 *Risks & rollback* as an `R-*` row with a waiver rationale — this is where severity judgement lives — and (where possible) an `OBS-*` for the residual-risk signal. A branch with no lockfile to scan declares `Supply-chain: none — <reason>` in Plan §5 and satisfies this criterion vacuously. Mechanically gated by Plan `T-N.D20`. Advisory data is retrieved at gate-run time — no snapshot is embedded in the methodology (`MD-31`).

## Plan `T-N.D20` — mechanical CVE gate

Added to the per-branch DoD checklist (`§7.x.9`), after `T-N.D19`:

```markdown
- [ ] T-1.D20 **Supply-chain audit** — the branch's committed lockfile has no
      unwaived advisory. Default recipe:
      `osv-scanner --lockfile={{path/to/lockfile}}` — the scanner **exits
      non-zero when it finds any advisory**, so the gate passes on a clean exit
      and fails otherwise. There is no severity threshold on the scan path
      (`osv-scanner` #1400, requesting one, was closed *not planned*), and there
      is deliberately none in this gate either — **severity judgement lives in
      the waiver, not the command** (see below). Language-native equivalents
      share the same exit-code-on-any-finding shape: `npm audit` (non-zero on
      any vuln by default), `pip-audit`, `cargo audit`, `govulncheck ./...`,
      `bundle audit`. Use each tool's **default text output** and check its exit
      status — do *not* pass `--format=json`/`sarif`, since `govulncheck` exits
      `0` under structured formats (a false pass). Any advisory the team accepts
      must appear in §14 as an `R-*` row with a rationale (severity, exploit
      path, compensating control) and, where possible, an `OBS-*` residual-risk
      signal; the rubric grades the rationale. Gate for Spec §11.5 `AC-55`
      (`MD-31`). If §5 declares `Supply-chain: none — <reason>` (no lockfile to
      scan), this gate passes vacuously. **The scanner retrieves current advisory
      data at run time** — a check that passed yesterday can fail today when a
      new advisory lands, and that is the desired behaviour. In offline /
      air-gapped environments where the scanner cannot retrieve, leave this
      checkbox unchecked **AND add a `[UNVERIFIED — offline; advisory DB
      unreachable]` marker to §15.1 *Open questions*** — a silently-unchecked box
      grades 🔴 (skipped gate); a disclosed offline box grades 🟡
      (diligence-blocked, per `MD-26`).
```

**Interpretation notes**:

- **The gate is exit-code, not report-parsing.** Every scanner in the family exits non-zero when it finds an advisory; the gate reads that exit status. It does **not** grep the report for severity words — `osv-scanner`'s table carries a numeric **CVSS** column (`8.6`, `7.5`), not the strings `HIGH`/`CRITICAL`, so a severity grep would silently pass every scan. `npm audit --audit-level=high` does *not* filter the report either — per npm's docs it "does not filter the report output, it simply changes the command's failure threshold." Gate on the exit code the tool actually sets.
- **The scanner runs fresh at every DoD invocation.** Cached results are not honoured; a re-check is cheap and the advisory DB moves daily.
- **Severity judgement lives in the waiver.** The gate fails on *any* advisory — the honest floor, and what every tool does natively. A team that accepts a specific advisory (a `moderate` with no exploit path in this usage, a `high` behind a compensating control) records it as an `R-*` row in §14 with that rationale; the rubric grades the rationale, and a reviewer sees exactly what was accepted and why. This is strictly better than a blanket severity threshold, which accepts *unknown future* moderate advisories sight-unseen.
- **Waivers are explicit.** A waived advisory must appear as an `R-*` row in §14 with a rationale — not silently suppressed via a `.osv-ignore` / `audit-resolve` file. The waiver rationale is what the rubric grades.
- **Nothing to scan — declare it.** A branch with no lockfile (docs-only change, vendored-deps project, a language with no lockfile concept) declares `Supply-chain: none — <reason>` in Plan §5 (same shape as the `Binding:` token). `T-N.D20` then passes vacuously. The rubric grades an *undeclared* Supply-chain token 🔴 (silent absence), not the vacuous pass itself — declared-none is visible, silent absence is disallowed (`MD-25`).
- **Conformance reads, never re-runs.** `spec-conformance` settles `AC-55` by *reading* the recorded `T-N.D20` checkbox, the §5 `Supply-chain` token, and the §14 `R-*` waiver rows — it never re-runs the scanner. This keeps conformance verdicts reproducible at a pinned SHA even though the gate itself is deliberately time-varying (the one non-deterministic DoD gate; see *Determinism* below).
- **Offline / air-gapped: disclose or fail.** When the scanner cannot fetch the advisory DB, the DoD checkbox is left unchecked. **Silently unchecked → 🔴** (skipped gate). **Unchecked WITH a `[UNVERIFIED — offline; advisory DB unreachable]` marker in Plan §15.1 *Open questions* → 🟡** (a legitimate diligence-blocked case per `MD-26`). The marker moves the outcome from 🔴 to 🟡; without it, the offline case is indistinguishable from an author who just skipped the gate.

## Determinism — the one time-varying gate

`T-N.D20` is the **only** non-deterministic DoD gate in the methodology. Every other gate (`T-N.D8`–`D19`) is `grep`/`comm`/`sed` over committed markdown: same commit → same verdict, forever. `T-N.D20` executes a third-party binary against a live advisory database, so a branch that passed yesterday can fail today when a new advisory lands — and that is *desired* for a merge gate (you want to know the moment a shipped dependency turns vulnerable). The cost is that a raw re-run is not reproducible at a pinned SHA, which `spec-conformance` otherwise relies on (it measured verdict-drift-at-fixed-SHA down from 20 % to 4 %). The reconciliation is the *Conformance reads, never re-runs* rule above: the **auditable record** of `AC-55` is the checkbox + `Supply-chain` token + `R-*` rows a human committed, not a fresh scan. Conformance audits the record; the gate audits reality; the two are allowed to differ, and when they do it is a signal to re-run the gate, not a conformance defect. <!-- closed-set:subset — D8–D19 deliberately excludes D20, the gate being contrasted here -->

## Rubric integration (Dim 5)

`critic-rubric.md` Dim 5 gains a *Security posture (MD-31)* row. **Each clause names the doc type it applies to** — the row lives in the all-doc-types block but, like the neighbouring `MD-25` row, only fires its clauses against the artefact that carries the relevant section (a Spec critiqued alone is never docked for a Concept Note's missing §5.2):

- **Concept Note — missing §5.2 *Security posture* declaration** → 🔴 (structural gap). Only graded when a Concept Note is under critique.
- **Spec — a CWE category the Concept §5.2 posture declared in-scope has no `TC-*` cite in §4.5 AND no explicit ruling** → 🔴 (obligation gap). An explicit ruling — *"CWE-XX — not applicable; §5.2 rules out …"* — is the escape valve; a ruling counts as a commitment even though it's not a TC. Only graded when a Spec is under critique **and** its feature folder has a Concept Note to read the posture from.
- **Plan — `T-N.D20` unchecked at merge with no waiver `R-*` row, no disclosed-offline marker, and no `Supply-chain: none — <reason>` token in §5** → 🔴 (supply-chain gap). An *undeclared* Supply-chain token is itself 🔴 (silent absence); a declared `none` passing vacuously is not. Only graded when a Plan is under critique.
- **Cross-doc — posture drift** (Concept §5.2 declares "public API with PII" but the Spec's §4.5 cites no input-validation CWE) → 🟡 (soft signal). Only graded in cross-doc critique, where both documents are in hand.
- **Any doc — a disclosed offline `[UNVERIFIED — offline; …]` marker** (on the §4.5 CWE-set, or on the `T-N.D20` gate) → 🟡, never 🔴 — grading a disclosed diligence-blocked case 🔴 would punish honesty (`MD-26`).

## Handoff obligation

Every Spec that adopts §4.5 carries its CWE-cites forward to the Plan: the §4.5 CWE set flows into Plan §12 *Verification & tests* (each `defends CWE-XX` TC gets a verification entry, alongside the existing §11.3 → §12 obligation for compliance TCs), and a CWE the Spec commits to but Plan §12 does not verify is a gap. Separately, any `[UNVERIFIED — offline; …]` marker the author had to add — because the CWE Top 25 could not be fetched at authoring time — is enumerated in the Spec's §17 *Handoff to the Implementation Plan* slot, exactly as `MD-26` requires every `[UNVERIFIED]` marker to be surfaced in the handoff-adjacent section so the downstream stage inherits the verification debt. (The Concept §16 reverse-handoff is not affected.)

## Failure modes MD-31 catches

Recorded pattern from the codebase-evidence pass and the field-canonical failure modes:

- **Compliance-shaped grounding without vulnerability-shaped commitment** — a Concept Note that grounds in HIPAA / GDPR / PCI (`MD-25` §6.5 industry-standard slot) can produce a Spec that has zero mention of input validation or output escaping. Compliance and vulnerability are orthogonal; MD-31 forces the second to be named.
- **Awareness-doc-as-checklist confusion** — treating OWASP Top 10 as a checklist rather than an awareness document, and then discovering the *actual* checkable vocabulary (CWE Top 25) doesn't align with the Top 10 categories. MD-31 anchors on CWE Top 25 explicitly for this reason.
- **CVE-blind merges** — a dependency added in Plan §8 that carries a known `high`-severity advisory nobody checked. `T-N.D20` is the mechanical primitive.
- **Post-hoc rationalisation of gaps** — a review that finds a security gap and closes it by softening the Spec rather than fixing the code. The rubric's 🔴 on obligation gaps forces the choice to be made in the direction that improves security posture, not the one that hides the gap.

## Practical checklist for authors

Run this before the doc leaves your hands:

1. **Concept Note authoring**: write the three-line §5.2 posture. If the answer is *"none applies,"* say so with the escape declaration and cite the reason. Silent absence is disallowed.
2. **Spec authoring**: for every CWE Top 25 category the §5.2 posture declared in-scope, either write a `TC-*` in §4.5 citing the CWE (with a *defends `CWE-XX` <name>* phrase) OR write a one-line ruling ("not applicable — Concept §5.2 rules out …"). At Spec-authoring time, retrieve `https://cwe.mitre.org/top25/` live over HTTPS; the categories that must appear in §4.5 are what the current CISA publication lists intersected with what §5.2 said applies. If the environment cannot retrieve external URLs, tag the derived set `[UNVERIFIED — offline; last known Top 25 as of <date>]`.
3. **Plan authoring**: add `T-N.D20` to every branch's §7.x.9 DoD **and declare the `Supply-chain` token in §5** — the lockfile path `T-N.D20` scans, or `none — <reason>` when the branch has nothing to scan. The token's *absence* is the 🔴 trigger, so naming it is not optional; confirming the lockfile path is correct is the second half. If the project uses a non-`osv-scanner` tool, name the equivalent in the recipe.
4. **Rubric pass**: the rubric's *Security posture (MD-31)* row will grade missing §5.2 declarations 🔴, in-scope categories with neither a TC nor an explicit ruling 🔴, `T-N.D20` unchecked at merge with no waiver `R-*` row in Plan §14, no disclosed-offline marker, **and no `Supply-chain: none — <reason>` token in §5** 🔴, posture-drift 🟡, and disclosed offline `[UNVERIFIED — offline; …]` markers (on either the CWE Top 25 fetch or the T-N.D20 gate) 🟡.
