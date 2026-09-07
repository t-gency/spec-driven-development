# 5 · Plugins and skills, and how to install them

## The difference, in one line each

A **skill** is a folder of instructions that teaches an agent to do one job well.

A **plugin** is the package that ships a set of skills together, versioned, so a team can install
them with one command.

That is the whole distinction: **skill = the capability, plugin = the delivery mechanism.** You
never install a skill on its own; you install the plugin, and its skills come with it.

## What a skill actually is

A folder with a `SKILL.md` at its root. The file opens with a front-matter block that names the
skill and describes when it applies:

```yaml
---
name: spec-conformance
description: Audit a feature's actual codebase against its committed Spec and report
  where the two have drifted apart. Triggers on "does the code match the spec",
  "what's not implemented", "find implementation gaps"...
---
```

Everything after that block is the instructions the agent follows.

**The `description` is not documentation: it is the routing table.** The agent reads every
installed skill's description and loads the one that matches what you asked. That is why they end
with a list of trigger phrases, and why they say what they are *not* for. `spec-conformance`
closes with "not for answering questions from the docs, authoring them, or rendering them" so it
does not get loaded for a job one of its siblings handles.

Two consequences worth knowing:

- **You invoke a skill in plain language.** You do not type its name. You say "does the code match
  the spec for this feature" and the right one loads.
- **A vague description means the wrong skill loads, or none does.** When a skill misfires, its
  description is usually the bug, not its instructions.

Beside `SKILL.md`, a skill can carry `references/` (detail loaded only when needed),
`templates/`, and `scripts/`. Splitting it that way keeps the main file small: the agent reads
`SKILL.md` always and the references only when the job needs them.

## What a plugin adds

A plugin is a folder with a `.claude-plugin/plugin.json` manifest and a `skills/` directory:

```
engineering-methodology/
├── .claude-plugin/plugin.json      name, version, description
├── skills/
│   ├── staged-engineering-doc/     SKILL.md + templates/ + references/
│   ├── three-p-visualizer/
│   ├── spec-answers/
│   └── spec-conformance/
└── scripts/
```

It gives three things a loose folder cannot: **a version** (`0.15.0`, so you can say which one a
document was written under), **one install command** for the whole set, and **updates**, since
upgrading the plugin upgrades every skill in it at once.


**This repository publishes one plugin**, `engineering-methodology` — the three documents and
the four skills that author, present, query and verify them. It is the one the rest of this
material describes.

It has siblings that are not published here: a variant specialized for legacy migrations, an
autonomous bug pipeline driven off the tracker, issue triage, multi-agent orchestration over a
backlog, and an evaluator for LLM-facing behaviour. They are mentioned only so the shape is
clear — **a marketplace normally carries several plugins, and each is one coherent job.**

## The four skills we use

All four ship in `engineering-methodology`, one per stage of a feature's life:

| Stage | Skill | What it does |
|---|---|---|
| **Author** | `staged-engineering-doc` | Writes or derives any of the three documents, through guided Q&A plus codebase research |
| **Present** | `three-p-visualizer` | Renders a feature as an interactive Product / Process / Project explainer |
| **Query** | `spec-answers` | Answers questions about a documented feature, citing IDs, with an explicit answer status |
| **Verify** | `spec-conformance` | Audits the code against the Spec, forward and backward |

`staged-engineering-doc` is the one you will use most, and it does not one-shot a document: it
researches the codebase first, asks what it cannot ground, and marks what stays unresolved as
`[OPEN-Q]` rather than guessing.

## Security is already covered, and it is not in this plugin

Three separate skills, each control anchored to a standard the reader can download and check.
**They exist and they are installed; what was missing is that nothing in the pipeline named
them.**

| Anchor | Used for |
|---|---|
| OWASP ASVS v5.0 | The requirement set, and the L1/L2/L3 assurance ladder our P1–R2 types map onto |
| OWASP Top 10:2025 · API Security Top 10 2023 · CWE Top 25 | Naming a defect precisely enough to test for it |
| NIST SP 800-63B · SP 800-218 (SSDF) · SP 800-218A | Authentication assurance; lifecycle practices; the generative-AI profile |
| CIS Docker Benchmark · NIST SP 800-190 | Container build and runtime hardening |
| OWASP Top 10 for LLM Applications 2025 | The AI / agent / MCP overlay |
| CVSS v4.0 · EPSS · CISA KEV | The vulnerability gate |

| Skill | Covers |
|---|---|
| `secure-dev` | Secrets and `.env`, sessions, rate limiting, server-side validation, encryption, credential handling, error handling, SAST/DAST, environment segregation, AI and MCP tool-calling controls |
| `secure-container-images` | Dockerfiles, multi-stage builds, attack surface, CIS Docker Benchmark |
| `production-readiness-gate` | The go/no-go over a complete feature, with a vulnerability gate. An engineering assessment, not a compliance certification |

**Where they belong is the whole point**, and it is not at the end:

| When | Which | Why |
|---|---|---|
| Writing the Spec | `secure-dev` | So `NFR-*` and `TC-*` come from a real control list, not intuition. Security shapes the WHAT |
| Phase 2, completeness | `secure-dev`, `secure-container-images` | Implementing the controls the Spec already committed to |
| Before the PR | `production-readiness-gate` | The go/no-go over the complete feature |

Running only the last one turns security into a veto at the most expensive moment, and the one
most likely to get waived under deadline.

Every threshold that does not come from a cited standard is labelled a **T-Gency default the
client may replace with their own policy** — secret rotation cadence, log retention, remediation
SLAs, exception approval levels. That is what makes the set portable, and it turns a weakness
into a sentence worth saying out loud in a client room: *these are our defaults; if you have a
policy, we run against yours.*

The three live in [`skills/`](../skills/), deliberately outside the source-of-truth
rule: they are meant to be taken, adapted and shared with teams that have no access to the
engineering repo. [`skills/`](../skills/) holds the earlier versions and is **superseded** — those
encoded a third party's internal policy and should not leave T-Gency.

**Known gaps, stated rather than implied:** infrastructure-as-code and Kubernetes beyond the
container security context; mobile and desktop clients; model safety and evaluation, as opposed
to the security of the system around the model; privacy engineering beyond data minimisation and
retention. Multi-tenant row-level security *is* now covered, in `secure-dev` §3.2.

## Installing it

**This repository is itself the marketplace.** Two lines, typed by a human inside Claude Code —
they are client slash-commands, so an agent cannot run them for you:

```
/plugin marketplace add t-gency/spec-driven-development
/plugin install engineering-methodology@tgency-method
```

The first line registers the marketplace declared in this repo's
[`.claude-plugin/marketplace.json`](../.claude-plugin/marketplace.json); the second installs the
plugin from [`plugins/engineering-methodology/`](../plugins/engineering-methodology/). Change the
`<owner>/<repo>` in the first line if you forked this.

To pick up a new version later:

```
/plugin marketplace update tgency-method
```

Three things to check before blaming the command:

- **The install is per machine, not per repo.** A new laptop needs it again.
- **Private repositories are unreliable here.** `marketplace add` clones over git, and against a
  private repo it can fail with a credentials prompt, time out, or — worse — register the
  marketplace with no plugins in it and no visible error. Authenticate first (`gh auth login`)
  if the repo is not public.
- **A wrong `<owner>/<repo>` reads as "marketplace not found"**, which looks like the plugin does
  not exist rather than like a typo.

To confirm it worked, ask the agent to audit a feature against its Spec, in plain language. If
`spec-conformance` loads, the plugin is installed.

## Versioning, and where the plugin really comes from

The plugin is **versioned and it changes**: it carries its own decision log (`MD-*`) and its own
open questions (`EVO-*`), and it is at `0.15.0` today. Which version a document was written under
is not a detail — it decides which rules that Spec was approved against.

So when a document cites the methodology, it cites a **commit, never a branch**:

```markdown
> **Methodology:** engineering-methodology v0.15.0 ·
> [`spec-driven-development@<sha>`](https://github.com/t-gency/spec-driven-development/tree/<sha>/plugins/engineering-methodology)
```

A link to `main` will misrepresent, three weeks from now, which rules that Spec was approved
under. That is the whole reason for the SHA.

### This copy is a mirror

The plugin is developed in a private engineering repository and **mirrored here** so that this
repo is installable on its own. [`plugins/engineering-methodology/UPSTREAM.md`](../plugins/engineering-methodology/UPSTREAM.md)
records which upstream commit this copy corresponds to, and CI fails when the mirror and the
recorded commit disagree.

That is a deliberate compromise, and worth naming rather than hiding. A single source of truth is
better than a mirror; a mirror that says out loud which commit it is, and that breaks the build
when it drifts, is better than a copy nobody can date. **If you are adopting this, you have no
upstream — delete `UPSTREAM.md` and let this repo be the source of truth.**

---

Next: [The delivery loop](06-the-delivery-loop.md)
