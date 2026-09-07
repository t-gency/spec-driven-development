<!-- markdownlint-disable MD033 -->
# Spec-Driven Development

**Write the specification before the code, and keep the two tied together afterwards.** Three
documents per feature, and an ID system that lets a tool walk from a requirement to the line of
code that satisfies it — and report the requirements nothing satisfies.

This repository is both the explanation and the runnable implementation.

📖 **[Read the reference](https://t-gency.github.io/spec-driven-development/)** ·
🚀 **[Quickstart](docs/00-quickstart.md)** ·
🔒 **[Security skills](skills/)**

---

## Install

Two lines, typed **by a human inside Claude Code**. They are client slash-commands, so an agent
cannot run them for you.

```
/plugin marketplace add t-gency/spec-driven-development
/plugin install engineering-methodology@tgency-method
```

> **Change the first line if you forked this.** It takes `<owner>/<repo>` and must point at
> wherever *your* copy lives.

That installs four skills at once. **You never type a skill's name** — you describe what you
want, in plain language, and the routing table in each skill's front matter picks the right one.

```
"Draft a concept note for the recovery feature. Research the codebase first,
 and ask me whatever you can't ground."

"Does the code match the spec for this feature? Audit it and list every gap."
```

Then follow the **[quickstart](docs/00-quickstart.md)** for a first feature end to end.

---

## The one-paragraph version

Spec-driven development separates three questions that teams usually answer at once and badly:
**why are we doing this and in what direction** (Concept Note), **what must the system do and how
must it behave** (Spec), and **what do we build, where, and in what order** (Implementation
Plan). Each document stands on its own and cites the previous one by ID, so a reader — human or
AI — can reconstruct any stage from its neighbours. The IDs are not bureaucracy: they are what
lets a tool walk from a requirement to the code that satisfies it, and report the ones nothing
satisfies.

### Why this matters more now than five years ago

Writing specs is an old idea that mostly died for a good reason: the spec went stale the moment
coding started, and nobody could afford to keep it current. Two things changed.

**An agent can write most of the document.** The cost of producing a well-structured Spec dropped
from days to hours, which changes the arithmetic that killed the practice.

**An agent can also audit the code against it.** That closes the loop that was always missing:
the spec stops being a document someone wrote once and becomes a thing that can be checked, so it
either stays true or you find out.

The second point is the real one. A spec nobody verifies decays into fiction. A spec that gets
audited is a contract.

### What this is not

Not a template pack, and not a phase gate to satisfy an auditor. **If a team adopts the documents
and skips the traceability, they get the ceremony without the benefit:** three more files to
maintain and nothing checking them. [Document 3](docs/03-traceability.md) is the part that pays
for the other two.

And it is expensive: **15,000 to 40,000 words per feature** across the three documents, plus real
calendar time to write and review them. That is too much for most work, and pretending otherwise
is how this gets abandoned. [Document 4](docs/04-adopting-it.md) is about deciding what earns it —
the honest answer, on the board where this was first run, was 2 or 3 features out of 18.

---

## The documents

Two audiences, two depths. Read in order or jump to your layer.

| | Document | For |
|---|---|---|
| 0 | [**Quickstart**](docs/00-quickstart.md) | **Start here.** From nothing installed to a first feature, on your own project |
| 1 | [What it is, and why](docs/01-what-and-why.md) | Anyone in Product. No repo, no tooling |
| 2 | [The three documents](docs/02-the-three-documents.md) | Anyone in Product |
| 3 | [Traceability: the part that makes it work](docs/03-traceability.md) | Anyone who will write or review one |
| 4 | [Adopting it on a real board](docs/04-adopting-it.md) | Teams putting it into practice |
| 5 | [Plugins and skills, and how to install them](docs/05-plugins-and-skills.md) | Anyone who will run it |
| 6 | [The delivery loop](docs/06-the-delivery-loop.md) | Anyone who will run it |
| 7 | [Branching and PRs](docs/07-branching-and-prs.md) | Engineering |
| 8 | [The documentation system](docs/08-the-docs-system.md) | Anyone who writes docs |
| 9 | [Talk outline](docs/09-talk-outline.md) | Whoever presents this |

The same material is published as a browsable site under
[`docs/`](https://t-gency.github.io/spec-driven-development/), with companion pages for the
[quickstart](docs/quickstart.html), the [security skills](docs/skills.html), the
[seeds](docs/seeds.html) and the [talk outline](docs/talk-outline.html).

---

## What is in this repository

```
.claude-plugin/marketplace.json     makes this repo installable
docs/                               the reference, documents 0–9, plus the HTML site
plugins/engineering-methodology/    the runnable plugin: 4 skills, templates, gates
skills/                             3 security skills, to copy and adapt
seeds/                              starting points for ADRs, investigations, runbooks, user docs
```

### `plugins/engineering-methodology/` — the four skills

| Stage | Skill | What it does |
|---|---|---|
| **Author** | `staged-engineering-doc` | Writes or derives any of the three documents, through guided Q&A plus codebase research |
| **Present** | `three-p-visualizer` | Renders a feature as an interactive Product / Process / Project explainer |
| **Query** | `spec-answers` | Answers questions about a documented feature, citing IDs, with an explicit answer status |
| **Verify** | `spec-conformance` | Audits the code against the Spec — forward and backward |

`spec-conformance` is the one that makes the rest worth doing. Every obligation in the Spec gets
exactly one verdict — `IMPLEMENTED`, `PARTIAL`, `ABSENT`, `DIVERGENT` or `UNVERIFIABLE` — each
citing a `file:line` at a pinned commit. Then it sweeps **backwards**, looking for behaviour in
the code that no ID sanctions. `UNVERIFIABLE` ranks above `ABSENT` on purpose: *"I could not
check" must never be reported as "it is not there."*

Design decisions for the whole methodology (`MD-01`–`MD-32`), the research summary, and the open
questions (`EVO-*`) are in
[`plugins/engineering-methodology/DESIGN_RATIONALE.md`](plugins/engineering-methodology/DESIGN_RATIONALE.md).
Read that to onboard as a contributor.

### `skills/` — security, and not in the plugin

Three skills you **copy and adapt**, rather than install:

```bash
mkdir -p .claude/skills
cp -r skills/secure-dev skills/secure-container-images skills/production-readiness-gate .claude/skills/
```

Every control is anchored to a standard you can download — OWASP ASVS v5.0, the OWASP
Top 10:2025, the CWE Top 25, NIST SP 800-63B / 800-218 / 800-190, the CIS Docker Benchmark, and
CVSS v4.0 / EPSS / CISA KEV for the vulnerability gate. Every threshold that is *not* from a
standard is labelled as a default you should replace with your own policy. See
[`skills/README.md`](skills/README.md).

**`production-readiness-gate` is an engineering assessment, not a compliance certification and
not an approval authority.** A `GO` means *the controls we could check are implemented and
evidenced in this repository at this commit*.

---

## Requirements

| | |
|---|---|
| **Claude Code** | The agent that runs the methodology |
| **Git** | Everything here lives next to code |
| **A POSIX shell** | The mechanical gates are `grep` / `sed` / `awk` / `comm` pipelines |

**On Windows the gates do not run in PowerShell** — they use process substitution. Use Git Bash
or WSL, and prefix sorted comparisons with `LC_ALL=C`; `comm` needs both sides sorted the same
way, and a non-English locale makes it return garbage *without reporting an error*.

Writing and reading the documents needs none of this. It is only the gates.

---

## Where the plugin really comes from

The plugin is developed in a private engineering repository and **mirrored here** so this repo is
installable on its own.
[`plugins/engineering-methodology/UPSTREAM.md`](plugins/engineering-methodology/UPSTREAM.md)
records which upstream commit this copy corresponds to, and CI fails when the two disagree.

A single source of truth beats a mirror. A mirror that says which commit it is — and that breaks
the build when it drifts — beats a copy nobody can date. **If you are adopting this, you have no
upstream: delete `UPSTREAM.md` and let your fork be the source of truth.**

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The short version: the methodology is applied to itself,
so a change to a closed set (the meta-acceptance-criteria `AC-50`…, the DoD gates `T-N.D1`…)
has to move every enumeration site together — `plugins/engineering-methodology/scripts/closed-set-consistency.sh`
is what fails the build when it does not.

## License

[Apache-2.0](LICENSE). The worked example this material draws on is T-Gency's; the methodology is
yours to take.
