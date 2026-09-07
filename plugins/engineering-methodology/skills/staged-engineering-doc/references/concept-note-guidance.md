# Concept Note authoring guidance

Use alongside `templates/CONCEPT_NOTE_TEMPLATE.md`. This file gives
section-by-section advice; it is **not** the template itself. Read the
template first, then return here when a section is hard to fill.

Two cross-cutting reference files apply to every doc type:

- `references/verification-protocol.md` — the MD-26 *Trust but verify*
  discipline: what to verify against per claim class, the
  `[UNVERIFIED — <reason>]` marker, how it differs from `[INFERRED]`
  and `[OPEN-Q-N]`.
- `references/review-passes.md` — the MD-21 two-pass consistency check
  (self-consistency, cross-consistency) run before saving.

## Tone & shape

- The Concept Note is *divergent and exploratory*. Its job is to make the team
  agree on the **direction**, not on the design. Resist the urge to specify
  field-level data models or class structure here.
- Prefer a **memo voice** over a template voice. Prose over bullets where
  prose is clearer; bullets where prose would meander.
- Length: most Concept Notes land between **2,500 and 6,000 words**. Anything
  shorter is probably a Slack message; anything longer is probably already
  a Spec.

  The band counts the **delivered document**, scaffolding included. The
  template's own normative scaffolding is ~2,300 words before a single
  placeholder is filled, which is why the floor is not lower: a "short"
  Concept Note is a conforming one with little content, not a small file.
- The reader hierarchy: **TL;DR** is read by everyone; **§3 Goals + §4 Non-goals + §10 Decisions + §15 Open questions + §16 Handoff** by reviewers; the rest by the implementer (and by the AI agent that drafts the Spec from this doc — for which §16 is load-bearing).

## Section-by-section tips

### §1 TL;DR

Three to five sentences a busy stakeholder can quote without opening the rest.
Cover: *what is being proposed*, *who it is for*, *why now*, and *the single
most important decision the reader needs to be aware of*. If you cannot write
a TL;DR yet, the proposal is not ready — keep researching.

### §2 Problem statement

Concrete examples beat abstract framings. If you have data — support tickets,
funnel drop-offs, telemetry, a user quote — cite it. Avoid framing the
problem as "we don't have feature X"; frame it as "users cannot do Y, which
costs Z".

### §3 / §4 Goals & non-goals

Treat these as a pair. A Goal without a paired non-goal usually means the
scope is not yet bounded. Each non-goal should be defensible — a reviewer
should be able to challenge it. Common useful non-goals:

- "We are not building a general-purpose X."
- "We are not solving cross-{{boundary}} state in this iteration."
- "We are not optimising for {{rare scenario}}."

### §5 Vision / desired end state

Two patterns work well:

1. **Press release** (Amazon PRFAQ) — write the announcement you would publish
   when this feature ships. Forces clarity on user-visible value.
2. **Day-in-the-life vignette** — a short narrative of a representative user
   completing the new flow. Forces clarity on UX, not just architecture.

Either is better than a bullet list of "the system will…".

#### §5.1 Context diagram — when to include

Required (per MD-24) when the feature crosses ≥2 system boundaries:
new third-party services, integrations with other internal systems, or
new infrastructure. Optional otherwise — a context diagram for a
feature that lives entirely inside one existing service is noise.

Use Mermaid `C4Context` (preferred) or a simple `flowchart LR`. Cap at
~10 nodes — the Context view is meant to be readable at a glance; if
you need more, you're already at the Container level (which belongs in
Plan §3, not Concept §5).

What to put in: external actors (user roles, partner services, other
teams' systems), this feature as a single box, the relationships
between them. What to keep *out*: internal components of this feature
(that's Container/Component, Plan §3), data shapes (that's Spec §10),
deployment topology (out of scope for a Concept Note).

### §6 Context & background

This is the section AI agents lack the most. Be generous with links. Quote
one paragraph from each linked doc rather than expecting the reader (or the
next-stage agent) to fetch and synthesise it.

#### §6.5 Sources & Origins — when to include what (per MD-25)

§6.5 is the **grounding evidence ledger**. Not a research narrative —
that's §7. §6.5 is the audit trail: *what did the author actually consult
before drafting?* Each line is one citation plus one line of "what this
pinned." A downstream reader should be able to back-derive from a citation
to the FR/NFR/TC/D-*/TD-* it shaped.

Rules of thumb, per sub-list:

- **Codebase evidence** — cite the *specific file/module you read*, not the
  whole repo. `packages/foo/src/session.ts:120` is a good citation; "the
  session module" is not. Line-anchor when a specific function or pattern
  matters; module-level otherwise. The one-line "what it told you" is what
  makes the citation useful — *"pinned FR-005 rate-limit shape to
  existing middleware"*, not just *"read this file"*.
- **Industry-standard evidence** — three classes to enumerate: regulatory
  (HIPAA/GDPR/PCI/SOC 2/WCAG/sector-specific), architectural (12-factor,
  DDD, event-driven, ISO 25010 quality model, OAuth/OIDC), style
  (`AGENTS.md` / `CLAUDE.md` / `CONTRIBUTING.md` / `CODEOWNERS`). Cite the
  clause or URL, not just the name. If a standard didn't apply, don't list
  it — the section shows what constrained the design, not what didn't.
- **Prior-art evidence** — competitor products, prior features in this
  codebase, papers/frameworks. Papers cite with arXiv ID or DOI + one-line
  finding. **Verify arXiv IDs against the actual paper's abstract page**
  (`MD-26`) — the audit chain has caught fabricated IDs before.

**How much detail is enough?** As many bullets as it takes to back-derive
the design; no more. If §6.5 has zero bullets, the doc is either
greenfield (declare `<sub-list> evidence: none — <reason>` per sub-list) or under-grounded. Both
outcomes are visible.

**The `<sub-list> evidence: none — <reason>` declaration.** Explicit is required; silent absence
is not. If the feature is greenfield and there's no codebase, write
`Codebase evidence: none — greenfield feature, no existing codebase`.
If no regulatory / architectural / style constraints apply beyond default
project conventions, write `Industry-standard evidence: none — <reason>`.
Same for prior-art. The declaration is the audit signal that the author
considered the sub-list and found nothing to cite — the rubric row can
distinguish that from *"forgot to fill in"*.

**Common failure modes this section catches:**

- Agent invents a convention the codebase already implements (Codebase
  evidence would have surfaced it).
- Spec ships without checking a regulatory obligation (Industry-standard
  evidence would have flagged it upstream).
- Team re-litigates an approach a prior feature already rejected (Prior-
  art evidence would have named the prior Concept Note).

**Relationship to §7 Research & industry context.** §7 is the *analytical
narrative* — how established products handle this, what the literature
says, what PoCs proved/disproved. §6.5 is the *ledger* — what was
consulted, cited briefly. §6.5 feeds §7: every §7 claim should be
back-referenced to a §6.5 citation. If §7 makes a claim not grounded in
§6.5, the claim is either speculative (should be flagged) or the citation
was missed from §6.5 (should be added).

### §7 Research & industry context

The most under-written section in most engineering docs.

- **§7.1** — name competitors specifically. "Industry trend" claims invite
  hallucination. If you are unsure, write "we did not investigate this" and
  flag it as an open question.
- **§7.3 PoCs** — for each PoC, the *what was disproved* row matters more
  than *what was proved*. Disproof prevents the team from re-litigating
  abandoned approaches.

### §8 Proposed direction

Stay at the conceptual level. Mermaid diagrams are welcome (per MD-24,
ASCII art and image links are not allowed; use §5.1's `C4Context` for
system-shape sketches — Concept Notes do not carry component-level
diagrams, that's Plan §3); field schemas and class hierarchies are not.
If you find yourself writing pseudocode here, you are drifting into the
Spec or Plan.

### §9 Alternatives considered

The single most valuable section for future readers. Each alternative needs
all four bullets — Description / Pros / Cons / Decision — even if Pros or
Cons are short. The "Decision" line is what prevents the team from quietly
re-discovering the same option in six months.

For 3+ materially different alternatives, add §9.3 the comparison table.
Pick dimensions that matter to *this* decision (cost, latency, complexity,
auditability, vendor lock-in, …); do not use a generic template.

### §10 Key decisions

Atomic, ID'd, citeable. The Spec and Plan will reference these by ID. Use a
short uppercase prefix if the team has multiple concurrent Concept Notes
(e.g. `AUTH-D-01`, `BILLING-D-02`); a single Concept Note can use plain
`D-01`.

The **Reversibility** column is borrowed from Bezos's "one-way vs. two-way
doors" framing. *Hard* and *one-way* decisions deserve more reviewer
scrutiny than *easy* ones.

**Where each `D-*` lands in the Spec.** Decisions split into two flavours:

- *Settled-direction* decisions (e.g. "we will pursue Strategy E", "we
  will phase delivery in five branches") become **inherited constraints**
  in Spec §3.3. They constrain *what the Spec can say*.
- *Solution-space* decisions (e.g. "must use vendor X for retrieval",
  "must reuse the existing integration layer", "must remain
  backend-pluggable") become **technical constraints** (`TC-*`) in
  Spec §4. They constrain *which implementations are admissible*.

Mixing the two in §10 is fine — they're all decisions at this stage.
The split happens when the Spec is written. Make each decision atomic
enough that the split is unambiguous.

### §11 Risks

Order by severity × likelihood. A long unranked risk list is read as a
disclaimer; a short ranked list is read as a plan.

External *constraints* (deadlines, regulatory drivers, partner asks,
budget envelopes) are not risks — put them in §6 Context. Solution-space
*mandates* (must use vendor X, must reuse system Y) are not risks
either — put them in §10 Decisions; they will become Spec §4 TC-* later.

### §12 Success signals

These are *not* the post-launch metrics from the Spec — those need
quantification and a measurement source. Concept-stage success signals are
softer: "users start uploading docs without prompting", "support tickets
about manual entry drop", "the team uses the feature in dogfood without
asking how".

### §13 Dependencies & stakeholders

Two distinct concepts in one section:

- **§13.1 Dependencies** — services, vendors, upstream specs, downstream consumers. These carry forward to Spec §13.
- **§13.2 Stakeholders** — owning team, reviewing teams, customers, partners. The Spec doesn't have a dedicated stakeholders section; this is the canonical home.

### §14 Out of scope / deferred

Explicit parking lot, distinct from §4 Non-goals:

- §4 = "we will not build this" (defensible, permanent).
- §14 = "we will not build this *now*; the trigger to revisit is X".

If you can't write a clear "deferred until …" condition, the item is
probably a non-goal, not a deferral.

### §15 Open questions

Honesty currency. A doc with honest open questions builds trust; a doc
with none is read as overconfident. Owners and target stages turn the list
from a wish into a plan.

### §16 Handoff to the Spec

Treat this as a contract with the next-stage author (human or AI). Three
parts:

1. **Settled** — decision IDs that must not be relitigated.
2. **Decide in Spec** — open question IDs the Spec must resolve.
3. **Must remain non-goals** — non-goal statements quoted **verbatim** from §4 (not by section number — sections can be deleted, content cannot drift). E.g. `"The system shall not …"`.

When an LLM reads this Concept Note to draft the Spec, this section is the
single most load-bearing.

### §17 Appendix

Anything a reader might want but that would clutter the body. Good
candidates: interview notes, raw benchmark spreadsheets, AI prompt
logs, longer architecture diagrams that didn't fit §5.1, links to
related Linear/Jira tickets, screenshots.

What does **not** belong here: anything load-bearing for a Spec author.
If a downstream agent needs it to draft the Spec, promote it to the
appropriate body section.

### §18 Change log

Append-only. One row per material change after the Concept Note is
first reviewed. Skip nits (typo fixes); record substantive changes
(decision flipped, alternative added, scope shifted).

## Common authoring smells

- **No non-goals.** Almost always means the team has not yet agreed on
  scope. Ask 2–3 "would we want X?" questions and write down the no's.
- **Alternatives all rejected for the same reason.** Suggests the rejection
  is really a *mandate*, not a risk. Route it into §10 Decisions if it's a
  solution-space mandate (must use vendor X), or into §6 Context if it's an
  external constraint (regulatory, deadline, partner ask). Do **not** put
  it in §11 — that section is for risks (severity × likelihood items), not
  for mandates.
- **Open questions all due "post-launch".** Suggests no one is committing
  to resolve them; rebalance toward Spec / Plan.
- **PoC summarised but never linked.** The link is the value; without it
  the Concept Note is hearsay.
