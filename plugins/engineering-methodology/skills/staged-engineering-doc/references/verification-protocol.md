# Verification protocol (MD-26)

This file is the shared verification protocol for the `staged-engineering-doc` skill. It applies to all three doc types (Concept Note, Spec, Implementation Plan) and defines what "verified against a primary source" means per claim class, when to use the `[UNVERIFIED — <reason>]` marker, and how the marker differs from its siblings `[INFERRED]` and `[OPEN-Q-N]`.

Referenced by the `SKILL.md` operating principle **Trust but verify (MD-26)** (which this file elaborates — the SKILL bullet is titled *"Trust but verify"* rather than *"Verification protocol"*; both names refer to MD-26) and by the top-of-file preambles of `concept-note-guidance.md`, `spec-guidance.md`, and `implementation-plan-guidance.md`. The `critic-rubric.md` Dim 5 row *Trust but verify (MD-26)* enforces this protocol at review time. Kept as a reference file (per MD-13 progressive disclosure) so `SKILL.md` stays lean.

## When a claim needs verification

Every claim in every doc that references an external or internal source is subject to MD-26. That includes:

| Claim class | What to verify against |
|---|---|
| arXiv ID (`arXiv 2507.20439`) | The arXiv abstract page for that ID exists and shows a paper matching the referenced title / authors / topic. Verify at `https://arxiv.org/abs/<id>`. |
| DOI (`10.1007/s00766-023-00412-z`) | The DOI resolves and the resolved landing page describes a paper matching the reference. Verify at `https://doi.org/<doi>`. |
| Paper finding quoted or paraphrased (`"the study found X"`) | The claim appears in the paper body — not just plausibly inferred from the abstract. If the number, percentage, or specific mechanism you cite is not stated in the abstract, either fetch the PDF/HTML and locate it, or tag `[UNVERIFIED — paper interior; specific number visible only in figures]`. |
| CLI flag (`npx mmdc --validate`) | The tool's `--help` output or official docs list the flag. Fabricated flags are a real observed failure mode (`mmdc --validate` was caught by Copilot on PR #12 — the flag does not exist). |
| Language / framework syntax (`Mermaid dotted-arrow -.label.->`) | The language or framework docs document the syntax form. Undocumented-but-widely-used forms should be tagged `[UNVERIFIED — form works in practice but not in the docs]`. |
| Peer framework quote (`Spec Kit constitution.md pattern`) | Verified against the current-main source of that framework, not against a blog paraphrase. Blog walkthroughs are a documented failure mode — a Medium author's own convention got passed as an OpenSpec pattern earlier this year. |
| Standard-clause text (`SWEBOK v4 §2.1 says X`) | Verified against the standard's PDF or the authoritative organization's site. Standards are frequently paraphrased incorrectly. |
| Repo-rooted internal citation (`<repo>/path:LN`) | The file exists at `path` and the "what this pinned" note matches the file's actual content at line `LN` (or the module-level content if unanchored). Extended from MD-25 §6.5 to all repo citations wherever they appear. |
| Cross-doc reference (`Spec §7 already handles this`) | The referenced section exists in the referenced doc and its content matches the claim being cited. |

## The `[UNVERIFIED — <reason>]` marker

Used when the author considered verifying a claim against its primary source and could not — for a specific, legitimate reason.

**Format**:

```
… as documented in [UNVERIFIED — Springer paper paywalled; abstract only shows headline] Mucha et al. (2024).
```

**Legitimate reasons** (non-exhaustive — the underlying test is *"did the author actually try to verify and hit a real obstacle?"*):

- `paywalled — could not access full text`
- `standard PDF requires purchase — abstract inaccessible`
- `arXiv page 404s`
- `URL redirect chain terminates in Cloudflare block`
- `tool not installable in this environment — could not check flag behaviour`
- `peer-framework repo private / archived / deleted`
- `paper interior; specific number visible only in figures we could not extract`
- `internal repo not clonable from the skill environment`

**Illegitimate reasons** — treat as if the marker were absent, and the rubric grades the claim as if un-flagged:

- `didn't check` (author skipped the discipline)
- `looked plausible` (post-hoc justification)
- `<blank>` (marker without a reason)

**Handoff obligation**: every `[UNVERIFIED]` marker in the doc must be enumerated in the doc's handoff-adjacent slot (Concept §16 *Handoff to the Spec*, Spec §17 *Handoff to the Implementation Plan*, Plan §15.1 *Open questions* — the Plan has no downstream handoff since it is terminal per MD-01, so its `[UNVERIFIED]` markers are consumed by execution and live alongside its open questions) so the downstream stage inherits the verification-debt explicitly. A downstream stage that finds an `[UNVERIFIED]` claim it depends on should either verify it (and drop the marker) or carry it forward with the same marker.

## How `[UNVERIFIED]` differs from `[INFERRED]` and `[OPEN-Q-N]`

Same marker family (`MD-10`), three distinct semantic categories:

| Marker | Semantic | Author knew | Author tried to verify |
|---|---|---|---|
| `[OPEN-Q-N]` | Unknown; deferred to a downstream stage | No | N/A |
| `[INFERRED]` | Back-derived from a sibling doc (not from a primary source) | Yes (derived it) | Not applicable — no primary source expected |
| `[UNVERIFIED — <reason>]` | Claim is asserted; primary source exists but couldn't be reached | Yes (cited it) | Yes (and the reason describes the obstacle) |

**Never mix them.** A claim cannot be both `[INFERRED]` and `[UNVERIFIED]` at the same time — either it's asserted from primary source (verified or not) or derived from sibling docs. A claim cannot be both `[OPEN-Q-N]` and `[UNVERIFIED]` — either you don't know it yet (`OPEN-Q`) or you claim it but couldn't verify it (`UNVERIFIED`).

## Failure modes MD-26 catches

Recorded pattern from the audit chain preceding MD-26's promotion — each is a real drift instance the discipline is designed to prevent:

- **Top-tier-slice-as-population** — citing the top-tier row of a paper's results table as the paper's overall finding (SADU accuracy bands, MD-22 review round).
- **Reversed paper attribution** — citing a paper for a conclusion the paper explicitly rejects (C4-for-agents "skip L2" attributed to arXiv 2603.15021, MD-24 review round).
- **Fabricated tool flag** — citing a CLI flag that the tool does not have (`mmdc --validate`, Copilot review-catch on PR #12).
- **Undocumented syntax form** — citing a syntax the language/framework docs do not document (Mermaid dotted-arrow with space-labels, Copilot review-catch on PR #12).
- **Blog-paraphrase-as-framework-pattern** — citing a blog author's convention as if it were part of the framework itself (`project.md` as OpenSpec pattern, peer-comparison session).
- **Fabricated numeric detail** — citing a specific number (percentage, correlation, count) that is not in the cited source (MAJ-EVAL Spearman "0.47 vs 0.15-0.36" refuted 0-3 in adversarial verification).
- **Overreach from a real source** — extrapolating from what the source actually says to what would be convenient (workflow-generated claims about SWEBOK personas and pre-RS-traceability cost figures, both refuted 0-3).

Each of these has a shared root cause: the author (human or agent) generated a claim that felt right and did not verify it against the primary source before writing it down. MD-26 makes that verification step structural — either it happens, or the `[UNVERIFIED]` marker discloses that it did not.

## Practical checklist for authors

Run this before the doc leaves your hands:

1. **Grep for citation-shaped strings** — `arXiv \d`, `10\.\d{4}`, `https?://`, `[<>\w./-]+\.\w+:\d+` (catches `<repo>/path.ts:LN` / `.py:LN` / `.go:LN` / `.md:LN` / any other file extension — MD-26 covers all file types symmetrically), `§\d+(\.\d+)*`. For each hit, ask: did I verify this against a primary source?
2. **For each unverified hit**, either verify now (WebFetch, file read, `--help`) or add an `[UNVERIFIED — <reason>]` marker with a specific reason.
3. **If any `[UNVERIFIED]` markers survive**, add them to the handoff-adjacent slot (Concept §16 / Spec §17 / Plan §15.1 — the Plan is terminal per MD-01 and has no handoff section; its markers live under §15.1 *Open questions* and are consumed by execution) so the downstream stage sees them.
4. **The rubric's *Trust but verify (MD-26)* row** will grade fabricated citations 🔴, un-flagged unverifiable claims 🔴, `[UNVERIFIED]` markers with an illegitimate reason 🔴 (treated as if the marker were absent per the illegitimate-reasons list above — so the un-flagged-unverifiable-claim rule applies), and missing handoff citation 🟡.
