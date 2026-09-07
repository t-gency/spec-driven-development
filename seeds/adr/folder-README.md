# Architecture Decision Records

Cross-cutting decisions, with their context, alternatives and consequences.

**Immutable once accepted.** When a decision changes, write a new ADR that supersedes the old one
and update only the old one's status line and forward link. Never edit an accepted ADR in place:
the point of the log is that you can read what was known at the time.

## Index

| # | Decision | Status | Date |
|---|---|---|---|
| 001 | *first one goes here* | accepted | |

## Rules

- **Numbered sequentially, never renumbered.** Gaps are fine
- **Title the decision, not the topic.** The index should be readable without opening files
- `proposed` · `accepted` · `superseded`. A superseded ADR keeps its file and links forward
- **Not for feature-scoped decisions:** those are `D-*` entries in that feature's Concept Note
- **Not for coding conventions:** those are living documents in `docs/conventions/`
- **Not for undecided research:** that is `docs/investigation/`

Start from `TEMPLATE.md`.
