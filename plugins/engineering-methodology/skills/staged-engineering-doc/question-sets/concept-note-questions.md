# Concept Note — question set

Use this list as a **checklist**, not a script. Skip questions the user
already answered or that are answered by source material the user
provided. Batch 3–7 questions per turn; do not interrogate one at a time.

## A. Framing (always ask)

1. **Feature name + one-sentence pitch.** What is the feature, in one sentence?
2. **Audience.** Who is this for — end user role, internal team, or downstream service?
3. **Why now.** What changed, or what deadline / commitment is driving this work now?

## B. Problem & motivation (almost always ask)

4. **Concrete pain.** Describe the most recent moment the absence of this feature hurt someone. Names, numbers, screenshots welcome.
5. **Existing telemetry.** Any data, tickets, NPS, or funnel evidence we should cite?
6. **Failed alternatives.** Has anyone tried to solve this before, internally or externally? What happened?

## C. Vision & scope

7. **Press-release test.** When this ships, what is the one-line announcement?
8. **Day-in-the-life.** Walk me through a representative user using the new flow.
8a. **Goals (outcome-shaped).** What user-visible outcomes should be true once this feature ships? Push for *outcomes*, not features — "users can {{outcome}}" / "we measure {{metric}} move", not "we built {{thing}}". 2–5 bullets. These land in §3. (Distinct from C-7 press-release test, which is the *announcement*; distinct from F-23 success signals, which are softer post-launch signals — not quantified metrics.)
9. **Non-goals (permanent).** What could reasonably be in scope and is *permanently* not? (At least 2 — push back if the user says "everything is in scope".) These land in §4. Distinct from C-9a Out of scope / deferred.
9a. **Out of scope / deferred (parking lot).** What is *deferred* — not in scope for v1 but a candidate for v2+? For each, name the *condition* that would bring it back ("once we have >100k uploads", "if multilingual ships"). These land in §14, not §4. The condition is what distinguishes a deferred item from a permanent non-goal.
10. **External constraints.** Deadlines, regulatory drivers, partner asks, budget envelopes the design must respect from day 1. (These land in §6 Context, not §11 Risks.)
11. **Solution-space mandates.** Specific tech-stack / vendor / architecture / convention choices the team is committing to (e.g. "must use vendor X", "must reuse the existing integration layer"). Each becomes an atomic decision in §10 — and will become a Spec §4 TC-* later.
11a. **System boundaries (drives §5.1 Context diagram, MD-24).** Does this feature cross ≥2 system boundaries — third-party services, other internal systems, new infrastructure? If yes, list the actors and the relationships they have with this feature (caller, callee, async producer, async consumer). Drives the §5.1 Mermaid `C4Context` diagram. If the feature lives inside one existing service, skip — no Context diagram needed.
11b. **Codebase grounding (drives §6.5 Codebase evidence, MD-25).** If the target repo already exists: which files/modules did you actually read before answering the earlier questions? Cite by `<repo>/path:LN` (or module-level when a specific line isn't needed) with a one-line note per citation on what it pinned (existing convention, API shape, test pattern, migration approach). If you haven't done this yet, do it now before advancing to drafting — the SKILL Step 3.1 Codebase Analysis is non-negotiable. Greenfield → declare `Codebase evidence: none — greenfield feature`.
11c. **Industry-standard grounding (drives §6.5 Industry-standard evidence, MD-25).** Which standards did you check against? Three classes to enumerate: (i) regulatory (HIPAA / GDPR / PCI / SOC 2 / WCAG 2.1 AA / sector-specific), (ii) architectural (12-factor, DDD, event-driven, ISO 25010 quality model, OAuth/OIDC, REST/gRPC/GraphQL conventions), (iii) style (`AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `CODEOWNERS`, company-specific playbooks). Cite the clause or URL, not just the name. If none apply → declare `Industry-standard evidence: none — <one-line reason>`.

## D. Research & alternatives

> **Questions C-11b, C-11c, D-12, D-13 all drive §6.5 Sources & Origins (MD-25).**
> C-11b/11c surface the Codebase and Industry-standard evidence sub-lists
> (they're grouped with the C-11 solution-space cluster because grounding
> constrains the design). D-12/13 surface the Prior-art evidence sub-list.
> Per MD-25, do not proceed to Step 4 drafting until §6.5 sub-lists are
> populated or explicitly declared empty via `<sub-list> evidence: none —
> <reason>`.

12. **Peer products.** Which competitor / OSS / internal product solves something similar? How? (Answers drive §6.5 Prior-art evidence per MD-25, and §7.1 narrative.)
13. **Prior art.** Papers, blog posts, RFCs, standards we should cite? (Answers drive §6.5 Prior-art evidence per MD-25, and §7.2 narrative. Verify arXiv IDs against the actual abstract page per `MD-26` — fabricated citations are a real failure mode.)
14. **PoCs / spikes.** Has anything been prototyped? Where (branch, notebook)? What did it prove or disprove?
15. **Alternatives shortlist.** What approaches did we seriously consider before settling on a direction? At least 2; if the answer is 1, push back.
16. **Why not the runner-up.** For each non-selected alternative, what specifically rules it out (cost, complexity, vendor, latency, …)?

## E. Decisions

17. **Direction taken.** What is the proposed direction at a sketch level?
18. **Atomic decisions.** Walk me through the 3–7 individual decisions baked into that direction. (Drives the §10 table — combine with answers from C-11.)
19. **Reversibility.** For each decision, easy to reverse, hard to reverse, or one-way door?

## F. Risks, dependencies, stakeholders, success

20. **Risks.** Top 3 ways this could go wrong (technical, organisational, vendor).
21. **Dependencies.** Other teams, services, vendors, upstream specs we are blocked on or coupling to.
22. **Stakeholders.** Owning team, reviewing teams, customers, partners. (Drives §13.2; this is the canonical home for stakeholders — the Spec doesn't have a dedicated section.)
23. **Success signals.** Six months in, how would we know this was the right bet?

## G. Open questions & handoff

24. **Known unknowns.** What is unresolved at this stage that you expect the Spec or Plan to answer?
25. **Settled items.** What must remain settled — decisions a downstream reader (or AI agent) must not relitigate?

## H. Optional context (ask only when relevant)

- Privacy / compliance sensitivity (PII, regulated data).
- Geographical / localisation scope.
- Performance envelope at a sketch level (< 10 rps? > 1k rps?).
- Mobile / web / API surface.

## How to use answers

- A → §1 TL;DR
- B → §2 Problem statement
- C-7,8 → §5 Vision · C-8a → §3 Goals · C-9 → §4 Non-goals · C-9a → §14 Out of scope / deferred · C-10 → §6 Context · C-11 → §10 Decisions (will become Spec §4 TC-*) · C-11a → §5.1 Mermaid `C4Context` per MD-24 · C-11b → §6.5 Codebase evidence per MD-25 · C-11c → §6.5 Industry-standard evidence per MD-25
- D-12,13 → §6.5 Prior-art evidence per MD-25 (ledger form) + §7.1/§7.2 (narrative form) · D-14 → §7.3 PoCs · D-15,16 → §9 Alternatives
- E → §8 Proposed direction, §10 Decisions
- F-20 → §11 Risks · F-21 → §13.1 Dependencies · F-22 → §13.2 Stakeholders · F-23 → §12 Success signals
- G → §15 Open questions, §16 Handoff
- H → §6 Context, §11 Risks (§14 Out of scope is reserved for C-9a deferred items with a re-entry condition — context tags route to §6 only)
