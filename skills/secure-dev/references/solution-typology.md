# Solution Typology — Classification and ASVS Level Mapping

Two things happen here, and they are deliberately separate:

1. **Classification** is T-Gency's scoping matrix. It answers *how much assurance does this
   thing need*, using three variables any team can assess in a meeting. It is our own scheme.
2. **The verification level** is [OWASP ASVS v5.0](https://owasp.org/www-project-application-security-verification-standard/).
   It answers *which requirements must be verified*, and it comes from a public standard so a
   client's auditor, a pentester, or a new engineer can check our work against something they
   can download.

Keeping them separate is what makes the scheme portable. A client with their own data
classification scheme swaps step 1 and keeps step 2 unchanged.

---

## Step 1 — Classify (the three variables)

### Data handled

| Level | Description |
|---|---|
| **Public** | Information already published or intended for the general public |
| **Internal** | Information for use inside the organization; disclosure is embarrassing, not damaging |
| **Confidential** | Sensitive information with controlled access; disclosure causes material harm |
| **Restricted** | Maximum sensitivity — regulated data, payment data, credentials, critical personal data, trade secrets |

> This ladder mirrors the intent of ISO/IEC 27001:2022 Annex A control **A.5.12
> *Classification of information***. If the client already has a classification policy, map
> their labels onto these four and record the mapping in the assessment; do not renumber.

### Availability and integrity impact

| Level | Description |
|---|---|
| **Low** | Unavailability or corruption has minor, recoverable operational consequences |
| **High** | Unavailability or corruption causes significant financial, reputational, regulatory or operational damage |

### Exposure

| Level | Description |
|---|---|
| **Internet-facing** | Reachable from a public IP or domain, including via an API gateway or CDN |
| **Internal only** | Reachable exclusively from the corporate network, a VPN, or a private link |

---

## Step 2 — Read the type

```
What data does the solution handle?
├── Public
│   ├── LOW impact  → P1
│   └── HIGH impact → P2
├── Internal
│   ├── LOW impact  → I1
│   └── HIGH impact → I2
├── Confidential
│   ├── LOW impact + internal only → C1
│   └── HIGH impact (any exposure) → C2
└── Restricted
    ├── LOW impact + internal only → R1
    └── HIGH impact (any exposure) → R2
```

**When in doubt, classify up.** The cost of over-classifying is some extra verification work.
The cost of under-classifying is discovering the gap in production.

**Classify by the most sensitive data the system can reach, not by the data on the happy
path.** A dashboard that renders public metrics but holds a database credential that can read
the customer table is classified on the customer table.

---

## Step 3 — Map to an ASVS verification level

| Type | ASVS level | Rationale |
|---|---|---|
| **P1** | **L1** | ASVS L1 is the floor for *every* application. There is no tier below it |
| **P2** | **L1** + L2 for V13 *Configuration* and V16 *Security Logging and Error Handling* | Public data, but an outage or defacement is material |
| **I1** | **L1** | |
| **I2** | **L2** | Internal data whose loss materially hurts the business |
| **C1** | **L2** | |
| **C2** | **L2** + **L3** for V8 *Authorization*, V11 *Cryptography*, V14 *Data Protection* | Confidential data on a business-critical path |
| **R1** | **L2** + **L3** for V8, V11, V14 | Restricted data, even internal-only, earns L3 on the data path |
| **R2** | **L3** | Highest sensitivity and highest impact |

ASVS levels are cumulative: **L2 includes all of L1, and L3 includes all of L2.** Selecting
"L2 + L3 on three chapters" means the whole of L2 plus those three chapters verified to L3.

### ASVS v5.0 chapters, for reference

| | Chapter | | Chapter |
|---|---|---|---|
| V1 | Encoding and Sanitization | V9 | Self-contained Tokens |
| V2 | Validation and Business Logic | V10 | OAuth and OIDC |
| V3 | Web Frontend Security | V11 | Cryptography |
| V4 | API and Web Service | V12 | Secure Communication |
| V5 | File Handling | V13 | Configuration |
| V6 | Authentication | V14 | Data Protection |
| V7 | Session Management | V15 | Secure Coding and Architecture |
| V8 | Authorization | V16 | Security Logging and Error Handling |

Cite requirements with the version prefix — `v5.0.0-6.2.1`, not `6.2.1` — because chapter
numbering changed substantially between ASVS 4.x and 5.0 and a bare number is ambiguous.

---

## The AI / LLM / MCP overlay

If the solution embeds an LLM, runs or calls an agent, exposes or consumes an MCP server, or
lets a model call tools, the AI overlay applies **in addition to** its P1–R2 type. It never
replaces it: an agent that reads the customer table is an R2 with an overlay, not "an AI
project".

The overlay is anchored to [OWASP Top 10 for LLM Applications
2025](https://genai.owasp.org/llm-top-10/) and, where the team builds or fine-tunes models,
[NIST SP 800-218A](https://csrc.nist.gov/pubs/sp/800/218/a/final) (the SSDF Generative AI
community profile). See `references/ai-mcp-controls.md`.

---

## Worked examples

| The team says… | Type | ASVS | Overlay |
|---|---|---|---|
| "A marketing site, no forms" | P1 | L1 | — |
| "The corporate site — if it goes down it's on the news" | P2 | L1 + L2 on V13/V16 | — |
| "An intranet wiki" | I1 | L1 | — |
| "The internal dashboard the board reads on Mondays" | I2 | L2 | — |
| "An internal tool holding client contracts" | C1 | L2 | — |
| "The platform our customers log in to, no payment data" | C2 | L2 + L3 on V8/V11/V14 | — |
| "An internal HR system with health and payroll records" | R1 | L2 + L3 on V8/V11/V14 | — |
| "The payments service" | R2 | L3 | — |
| "A support chatbot over our public FAQ" | P1 | L1 | ✅ |
| "An agent that reads customer tickets and issues refunds" | R2 | L3 | ✅ |

The last two rows are the ones worth arguing about in the room. The chatbot is genuinely low
risk *until* someone connects it to a tool. The refund agent is a payments system that happens
to have a model in front of it, and classifying it as anything less is the mistake this table
exists to prevent.

---

## Recording the decision

Write the classification into the Concept Note's security posture section (§5.2) as three
lines, not one label:

```
Data handled: Confidential — customer contact details and contract terms
Impact: High — the sales team cannot quote without it
Exposure: Internet-facing via the partner portal
→ C2 · ASVS L2, with L3 on V8 Authorization, V11 Cryptography, V14 Data Protection
→ AI overlay: not applicable
```

The three lines are what a reviewer argues with. The label alone is unfalsifiable.
