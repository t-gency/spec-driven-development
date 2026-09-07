# Seeds — the other document types

The three-document pipeline covers features. A repo needs four more kinds of document, and each
has a different lifecycle:

| Type | What it is | Lifecycle |
|---|---|---|
| **ADR** | A cross-cutting architectural decision | **Immutable once accepted.** Superseded, never edited |
| **Investigation** | Pre-spec research, an audit, a post-mortem | Dated. A snapshot, never retro-edited |
| **Runbook** | An operator playbook | Updated with the operation it describes |
| **Site doc** | Shipped behaviour, for users | Written when a feature ships |

Each folder here holds a **seed skill** and a **template**. They are starting points, not
finished products: install them, use them for a month, and edit them to match what your team
actually does.

```
adr/            SKILL.md · TEMPLATE.md · folder-README.md
investigation/  SKILL.md · TEMPLATE.md · folder-README.md
runbook/        SKILL.md · TEMPLATE.md · folder-README.md
site-doc/       SKILL.md · TEMPLATE.md · folder-README.md
```

- **`SKILL.md`** teaches an agent to write that document type well: when it applies, what it must
  contain, and what makes a bad one
- **`TEMPLATE.md`** is the file the document starts from
- **`folder-README.md`** goes in the destination folder in your repo, so someone who opens
  `docs/adrs/` learns the rules without reading this

## Installing a seed

```
your-repo/
├── .claude/skills/adr/SKILL.md          the skill
└── docs/adrs/
    ├── README.md                        from folder-README.md
    ├── TEMPLATE.md                      from TEMPLATE.md
    └── 001-your-first-decision.md
```

Then ask in plain language: *"Write an ADR for the decision to use Postgres row-level security
for tenant isolation."*

## The rule that decides which one

**Sort by lifecycle, not by topic.** That is the whole idea, and it is what stops the same fact
from living in two places and disagreeing:

- A decision is **immutable** &rarr; ADR
- Research is a **dated snapshot** &rarr; investigation
- A convention is **living** &rarr; `docs/conventions/`
- A procedure changes **with the operation** &rarr; runbook
- User-facing docs change **when behaviour ships** &rarr; site

If two of these seem to fit, the document is probably two documents.

## Two distinctions people get wrong

**A `D-*` in a Concept Note is not an ADR.** The `D-*` is feature-scoped and lives with its
feature; an ADR is cross-cutting and outlives every feature that depends on it. If the decision
only makes sense inside one feature, it is a `D-*`.

**A spec is not a doc.** A spec is design intent, for engineers and agents. A doc is shipped
behaviour, for users. When a feature ships, its spec gets `status: implemented` and a site doc
gets written. Letting a spec become the user documentation is how a document ends up describing a
design that shipped differently.

## Writing rules, all four types

- **English only.** Conversation in any language is fine; the committed file is not
- **State what is true now**, not what changed. Changelogs live in git
- **Link, do not copy.** One fact, one home. A restatement is a future contradiction
- **Delete confidently.** A section describing something that no longer exists is a bug
- **Do not invent counts.** A number you could have counted from the repo belongs in a generator

## Making a seed your own

The `description` in the front matter is the routing table: it is what the agent reads to decide
whether to load the skill. When you adapt one, that is the field to get right, and the one to
suspect when the skill does not fire.

Keep the trigger phrases your team actually says. Ours say "write an ADR" because that is our
vocabulary; if yours says "decision record", change it.
