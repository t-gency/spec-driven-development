# 0 · Quickstart

From nothing installed to a first feature shipped through the methodology, on **your own
project**. About 20 minutes of setup, most of it waiting for installs, and then the length of
one real feature.

**You do not need to know how to code** to write the documents. You do need a repository to
point the agent at.

---

## Step 1 · What you need

| Tool | Why | Check |
|---|---|---|
| **Claude Code** | The agent that writes the documents, implements the plan, and audits the code against the Spec | `claude --version` |
| **Git** | Everything here lives next to code | `git --version` |
| **A POSIX shell** | The mechanical gates are `grep` / `sed` / `awk` / `comm` pipelines | `bash --version` |

On macOS and Linux you already have the shell. **On Windows the gates do not run in
PowerShell** — they use process substitution, which PowerShell has no equivalent for. Use
**Git Bash** (ships with Git for Windows) or **WSL**. You can write and read the documents from
anywhere; it is only the gates that need bash.

<details>
<summary>Installing the tools</summary>

```bash
# macOS
brew install git
# Linux (Debian/Ubuntu)
sudo apt-get install -y git
```

```powershell
# Windows — then CLOSE and REOPEN the terminal so PATH updates
winget install --id Git.Git -e --source winget
```

Claude Code is installed from the Claude desktop app, or per the
[install guide](https://docs.claude.com/en/docs/claude-code/overview).
</details>

---

## Step 2 · Install the plugin

Two lines, typed **by a human inside Claude Code**. They are client slash-commands, so an agent
cannot run them for you.

```
/plugin marketplace add t-gency/spec-driven-development
/plugin install engineering-methodology@tgency-method
```

That installs four skills at once — authoring, presenting, querying and verifying.

> **Change the first line if you forked this repo.** It takes `<owner>/<repo>`, and it must
> point at wherever *your* copy lives.

**The install is per machine, not per repo.** A new laptop needs it again.

### Check it worked

Ask, in plain language — not by naming a skill:

> Does the code match the spec for this feature? Audit it and list every gap.

If it starts asking which feature and which Spec instead of asking what you mean, the plugin is
there. **You never type a skill's name.** You describe what you want and the routing table in
each skill's front matter picks the right one.

### Optional: the security skills

They are not in the plugin, on purpose — they are meant to be copied and adapted. Drop them into
your repo and they load automatically:

```bash
mkdir -p .claude/skills
cp -r skills/secure-dev skills/secure-container-images skills/production-readiness-gate .claude/skills/
```

See [`skills/README.md`](../skills/README.md) for what each one covers and where it belongs in
the loop. Read that before adapting: every threshold in them that is not from a public standard
is labelled as a default you should replace with your own policy.

---

## Step 3 · Pick the right first feature

**Not the easiest one.** An easy feature will not surface the problems, and you will conclude
the methodology is cheap. Pick the most expensive thing on your board — the one where people
disagree about what it should do.

And be honest about the alternative: most work should **not** get this treatment. Before you
start, read [what earns the full treatment](04-adopting-it.md#4--what-earns-the-full-treatment).
The short version:

| Your ticket is… | What to run |
|---|---|
| Blocked on a decision nobody has made | **Concept Note only** |
| Blocked on "we don't actually know what this should do" | **Concept Note + Spec** |
| Blocked on an external team's contract | **Nothing.** You need their contract, not your Spec |
| Not blocked | **Nothing.** Write a good ticket and ship |

A team that runs the full pipeline on everything will quietly stop running it on anything.

---

## Step 4 · Your first feature, end to end

Open Claude Code **in the repository the feature lives in**. Each step is plain language; the
constraints inside the prompts are load-bearing, so copy them nearly verbatim.

### 4.1 · The Concept Note — why, and in what direction

> Draft a concept note for {feature}. Research the codebase first, and ask me whatever you
> can't ground.

That second clause is what stops invention. Expect to be interviewed: it reads your code, checks
the standards that apply, looks for prior art, and only then asks you what it could not find
out on its own. Anything still unresolved comes back as `[OPEN-Q-N]` rather than a guess.

**What you are reviewing:** the numbered decisions `D-01`, `D-02`… each with a reversibility flag
(Easy / Hard / One-way), the non-goals, and the handoff section that splits everything into
*settled — do not relitigate*, *decide in the Spec*, and *must remain non-goals*.

### 4.2 · The Spec — what it must do

> Turn this concept note into a spec. Keep the focus on the WHAT, and enumerate the variants
> for every scenario.

Variants are where happy-path-only Specs get caught. Every scenario declares its boundary,
failure, concurrency and property variants — **or says explicitly that it has none, and why.**

**Review this one properly.** It is the document everything downstream is held to. Two tests you
can apply without being an engineer:

- **Can each requirement be violated?** "The system must be fast" cannot. "The system shall
  return search results within 300 ms at p95 for datasets under 10,000 records" can.
- **Is anything vague?** "Robust", "secure", "seamless" are defects, not requirements.

If security matters at all, this is where it enters — not in review three weeks later. Run
`secure-dev` here: *review this spec against our security standards and tell me which NFRs and
TCs are missing.*

### 4.3 · The Plan — what to build, where, in what order

> Generate an implementation plan from the spec. Use real file paths, stacked branches per the
> arc behind a flag, and a scenario → test matrix.

**The test:** hand it to a competent person who has never seen the codebase, give them five
days, and they ship without asking a question. If the plan says "the auth module" instead of
`src/auth/session.ts` and a function signature, send it back.

### 4.4 · Implement

> Implement the whole plan end to end. Commit locally as you go, but do NOT push and do NOT
> open the PR: stop when it's ready to verify on localhost.

Nothing gets pushed, so this can run unattended. Go do something else.

### 4.5 · Verify — the part people skip

> Make sure every service I need to validate {feature} on localhost is running: start whatever
> is down. Then walk me through validating the change, and give me example API calls where that
> is the clearest check.

The bar for this phase is that **the happy path works in a browser**. Nothing more. Show it to
whoever owns the WHY and get a real answer before investing in completeness.

### 4.6 · The audit — and this is the demo

Now run the thing that makes the whole practice worth reviving:

> Audit the code against the spec for {feature}. Report every obligation with one verdict, and
> tell me what the code does that the spec never sanctioned.

Every requirement, scenario, constraint and acceptance criterion comes back with exactly one
verdict — `IMPLEMENTED`, `PARTIAL`, `ABSENT`, `DIVERGENT` or `UNVERIFIABLE` — each citing a file
and a line at a pinned commit. Then it sweeps **backwards**, looking for behaviour in your code
that no ID sanctions.

**Run this on a feature you thought was finished.** That first report is what convinces a team,
and no amount of explaining substitutes for it.

### 4.7 · Completeness, then ship

> Product confirmed the prototype. Now complete {feature}: implement the deferred NFRs and TCs,
> and close the remaining scenario variants.

Then the pre-PR gate — conformance reconciled, end-to-end coverage, sibling docs updated in the
same change, and a security review over the complete feature rather than the prototype. Details
in [the delivery loop](06-the-delivery-loop.md).

---

## Step 5 · Where the documents live

Commit them next to the code, one folder per feature:

```
specs/
  001-conversations/
    concept-note.md
    spec.md
    implementation-plan.md
```

The methodology says to mirror whatever convention your repo already uses, so if you have a
`docs/` layout, use it. What matters is that it is **the same shape in every repo**, because
that is what lets one person read across several codebases.

And point your tickets at them with two fields in the body — this is the entire bridge between
a board and a document set:

```
Docs:      specs/001-conversations/
Satisfies: FR-003, S-04, AC-12
```

---

## When something fails

| What you see | What it means |
|---|---|
| `Marketplace not found` | The `<owner>/<repo>` in step 2 is wrong, or the repo is private and you have no access. The error does not say "permissions" |
| The command runs but no skill loads | The install is per machine. Run step 2 again on this machine |
| A gate reports every scenario as uncovered | You are running it in PowerShell, or your locale is not `C`. Use Git Bash or WSL, and prefix sorts with `LC_ALL=C` |
| A gate reports IDs that do not exist | Almost always an unanchored grep. `D-` matches inside `TD-`; `S-` matches inside `OBS-`. Use the recipes as written |
| The agent invents a requirement | It was asked to produce a Spec without a Concept Note to ground it, or the prompt dropped the *"ask me whatever you can't ground"* clause |
| The audit says `UNVERIFIABLE` a lot | Usually the test-binding convention is not recorded in Plan §5, so nothing can find the tests |

**Anything else: copy the whole error and ask.** Do not re-run a command that failed without
knowing why.

---

## What you cannot break

Reassurance, because fear of breaking something is what stops people from trying:

- **The documents are just markdown** in your repo. Delete the folder and you have lost nothing
  but the writing.
- **Nothing here pushes code.** The implement step commits locally and stops.
- **The audit never executes your code.** It reads. Bound tests are read to confirm they exist,
  never run — and an obligation only a run could settle comes back `UNVERIFIABLE` with the
  command named for you.
- **The audit writes nothing into the audited repo** by default. Its output goes to the agent's
  scratchpad unless you ask for it somewhere.

---

## Read next

| | | |
|---|---|---|
| **[1 · What it is, and why](01-what-and-why.md)** | The argument | Start here if you want to convince someone |
| **[3 · Traceability](03-traceability.md)** | The mechanism | The part that makes it work rather than ceremony |
| **[4 · Adopting it](04-adopting-it.md)** | The four questions the methodology does not answer | Read before rolling it out to a team |
| **[6 · The delivery loop](06-the-delivery-loop.md)** | The ten steps in full | Read when step 4 above stops being enough |

---

Next: [What it is, and why](01-what-and-why.md)
