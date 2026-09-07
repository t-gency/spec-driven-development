# User documentation

**Shipped behaviour, for users.** Written when a feature ships, not while it is being designed.

## The distinction that matters

| | Spec | Doc |
|---|---|---|
| Describes | Proposed or in-progress design | Shipped, working behaviour |
| Audience | Engineers and coding agents | Users |
| Lives in | `docs/specs/**` or `specs/NNN-slug/` | here |
| Status | Carries a status banner | published |

**When a feature ships:** set the spec's `status: implemented` and write the doc here. Never let a
spec quietly become the user documentation, or you end up with a document describing a design that
shipped differently, reading like documentation.

## Rules

- **Present tense, user's vocabulary.** Not the architecture
- **Written from the shipped build**, not from the spec
- **Changes in the same PR as the behaviour.** Documentation that lags the code is worse than
  none: it is confidently wrong and readers act on it
- **No design rationale.** That is the ADR or the Concept Note

Start from `TEMPLATE.md`.
