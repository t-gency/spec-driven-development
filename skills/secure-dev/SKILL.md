---
name: secure-dev
description: >
  Secure coding guide anchored to OWASP ASVS v5.0, the OWASP Top 10:2025, the CWE Top 25
  and NIST SP 800-63B. Use this skill whenever the user asks what security controls to
  implement in code, how to classify a solution's assurance level, or about authentication,
  authorization, session management, input and output validation, injection, access-control
  flaws, cryptography, secret handling, error handling, rate limiting, security logging,
  file uploads, SSRF, CSRF, deserialization, CORS, dependency and supply-chain risk, SAST
  or DAST. Also trigger for security-focused code review, threat modeling, controls for
  LLM/agent/MCP tool-calling systems, and for questions phrased as "is this secure?",
  "how should I implement X securely?", or "review this endpoint".
  Not for container images — that is `secure-container-images`. Not for the release
  decision — that is `production-readiness-gate`.
---

# Secure Development

Everything here is anchored to a standard the reader can download and check. When this file
states a control, it names where the control comes from. When it states a threshold, that
threshold is either from a cited standard or explicitly labelled as a T-Gency default the
client may replace.

**Primary anchors**

| Anchor | Used for |
|---|---|
| [OWASP ASVS v5.0](https://owasp.org/www-project-application-security-verification-standard/) | The requirement set, and the L1/L2/L3 assurance ladder |
| [OWASP Top 10:2025](https://owasp.org/Top10/2025/) | Risk categories, for prioritising and for talking to non-specialists |
| [CWE Top 25 (2025)](https://cwe.mitre.org/top25/) | Naming a defect precisely enough to test for it |
| [OWASP API Security Top 10 (2023)](https://owasp.org/API-Security/editions/2023/en/0x11-t10/) | API-specific failures the web Top 10 under-weights |
| [NIST SP 800-63B](https://pages.nist.gov/800-63-3/sp800-63b.html) | Authentication assurance levels, password and MFA rules |
| [NIST SP 800-218 (SSDF)](https://csrc.nist.gov/pubs/sp/800/218/final) | Where a practice sits in the lifecycle |
| [OWASP Top 10 for LLM Applications 2025](https://genai.owasp.org/llm-top-10/) | The AI / agent / MCP overlay |

> **Standards move.** Retrieve the live page when a specific clause matters. If you cannot
> reach the network, say so in the output with `[UNVERIFIED — offline; <standard> as of
> <date>]` rather than asserting a clause from memory.

---

## Step 1 — Classify the solution

Do not recommend a single control before this is settled. Three questions:

| Variable | Options |
|---|---|
| **Data handled** | Public / Internal / Confidential / Restricted |
| **Availability & integrity impact** | Low / High |
| **Exposure** | Internet-facing / Internal only |

That yields a type from **P1 … R2**, and the type selects an **ASVS verification level**:

| Type | ASVS level |
|---|---|
| P1, I1 | **L1** |
| P2 | **L1** + L2 on V13 *Configuration*, V16 *Logging & Error Handling* |
| I2, C1 | **L2** |
| C2, R1 | **L2** + L3 on V8 *Authorization*, V11 *Cryptography*, V14 *Data Protection* |
| R2 | **L3** |

Full definitions, worked examples and the ASVS chapter list: `references/solution-typology.md`.

**If the solution involves an LLM, an agent, tool-calling or an MCP server**, the AI overlay in
`references/ai-mcp-controls.md` applies *in addition to* the P1–R2 controls. It is additive,
never a substitute.

**When the user cannot answer, ask — do not assume.** An assessment against the wrong tier is
worse than no assessment. If the user is unavailable and work must continue, default to **C1**
and state the assumption in the first line of the output.

---

## Step 2 — Threat model before controls

The most expensive defects are design defects, and no checklist finds them. OWASP Top 10:2025
ranks **A06 Insecure Design** sixth for a reason: a correctly implemented control on the wrong
design does nothing. NIST SSDF `PW.1.1` says the same thing in the imperative — *"Use forms of
risk modeling — such as threat modeling, attack modeling, or attack surface mapping — to help
assess the security risk for the software."*

Run this before writing the Spec's `NFR-*` and `TC-*` rows. It takes thirty minutes and it is
the input to every table below.

**The four questions** (Threat Modeling Manifesto):

1. **What are we building?** One data-flow sketch. Every trust boundary drawn explicitly —
   browser→API, API→database, service→third party, user→model, model→tool.
2. **What can go wrong?** Walk STRIDE across each boundary: **S**poofing, **T**ampering,
   **R**epudiation, **I**nformation disclosure, **D**enial of service, **E**levation of
   privilege.
3. **What are we going to do about it?** Each accepted threat becomes a `TC-*` (a constraint on
   the solution) or an `NFR-*` (a measurable obligation) in the Spec, citing the CWE it defends
   against — `defends CWE-89 SQL Injection`, not "input is validated".
4. **Did we do a good enough job?** The threat model is dated, committed next to the code, and
   revisited when a trust boundary moves.

**Output shape** — one row per threat, in the Concept Note or a `docs/investigation/` entry:

| ID | Boundary | STRIDE | Threat | Response | Lands as |
|---|---|---|---|---|---|
| T-01 | Browser → API | E | A user edits `accountId` in the request and reads another tenant's data | Server-side object-level authorization on every read | `TC-004` defends CWE-639 |
| T-02 | API → S3 | I | Signed URLs leak in logs | Redact query strings at the log sink | `NFR-007` |

A threat with no `Response` is an accepted risk and must say so, with an owner. **Silence is
not an answer** — an undeclared threat is a defect; a declared and accepted one is a decision.

---

## Step 3 — Controls by area

Each area names its ASVS chapter and the CWEs it defends against, so a reviewer can go
straight to the source. Rows are cumulative down the tiers.

### 3.1 Authentication — ASVS V6 · CWE-306, CWE-287 · A07:2025

| Type | Requirement |
|---|---|
| P1 | Public access; no authentication |
| I1 | Authenticate against the organization's IdP via OIDC **Authorization Code + PKCE** |
| P2, I2, C1 | Federated OIDC Authorization Code + PKCE, **plus MFA** meeting NIST 800-63B **AAL2** |
| C2, R1, R2 | The above, with **phishing-resistant** MFA meeting **AAL3** — FIDO2/WebAuthn security key or platform authenticator, or PIV/CAC smartcard. mTLS for service-to-service on Restricted data paths |

**Never use the Resource Owner Password Credentials grant.** It is removed in OAuth 2.1 and
forces the application to handle the user's password. Implicit flow likewise.

**Rules for every tier above P1**

- **Password storage:** a memory-hard KDF — **Argon2id** (preferred), **scrypt**, or **bcrypt**
  where the runtime offers nothing better. Never a bare hash, never a fast hash, never
  home-rolled salting. (ASVS V6; CWE-916.)
- **Password policy:** minimum 8 characters (15+ where MFA is absent), screened against a
  breached-password list, **no composition rules and no forced periodic rotation** — 800-63B is
  explicit that both make passwords worse. Rotate on evidence of compromise.
- **Lockout / throttling** after a defined number of failures, with exponential backoff. Rate
  limits are per-account *and* per-source, so neither credential stuffing nor a targeted
  lockout DoS works.
- **Uniform failure responses.** "Invalid email or password", never "no such user" — user
  enumeration is CWE-204.
- **Every authentication event is logged**, success and failure, with actor, source IP, and
  timestamp. Never log the credential.
- **No default credentials anywhere**, including seed data, fixtures and demo environments.
- **Service-to-service** authenticates with mTLS, signed tokens or workload identity — never by
  network position alone.

**Tokens (ASVS V9, V10)** — if the system issues or accepts JWTs:

- Reject `alg: none`; pin the accepted algorithm server-side rather than reading it from the
  header (CWE-347).
- Validate `iss`, `aud`, `exp`, `nbf` on every request. A signature check alone is not
  validation.
- Short access-token lifetimes, refresh tokens rotated on use with reuse detection.
- Never put anything in a JWT that the client must not read. It is signed, not encrypted.

### 3.2 Authorization — ASVS V8 · CWE-862, CWE-863, CWE-639, CWE-284 · A01:2025

**A01 Broken Access Control is the number-one risk in the OWASP Top 10:2025, and API1
Broken Object Level Authorization is number one in the API Top 10.** Everything else in this
document matters less than getting this right.

| Type | Requirement |
|---|---|
| P1, I1 | Least-privilege file and API permissions. Read-only access grants no write path |
| P2, I2 | RBAC with at least two roles: administrative and standard |
| C1, C2, R1, R2 | Fine-grained RBAC or ABAC with a written **role/permission matrix**. Deny by default |

**Non-negotiable, all tiers**

- **Enforce server-side on every request.** A hidden UI element is not a control (CWE-602).
- **Object-level authorization on every object access** — not just at the route. `GET
  /invoices/{id}` must verify that *this* principal may read *that* invoice, every time.
  This is CWE-639 / API1:2023, and it is the most common serious flaw in production APIs.
- **Property-level authorization.** Bind request fields to an explicit allowlist; never bind a
  whole request body onto a domain object (mass assignment, API3:2023, CWE-915). A user must
  not be able to set `role` or `accountBalance` by adding it to a JSON payload.
- **Deny by default.** A new endpoint with no explicit policy is unreachable, not public.
- **Centralise the decision.** One middleware or policy engine, applied globally, with
  documented exceptions — not an `if` statement per handler.
- **Multi-tenancy:** tenant isolation is enforced in the data layer, not only in the service
  layer. Where the datastore supports it, use row-level security so a missing `WHERE tenant_id`
  cannot leak data. Where it does not, the tenant predicate lives in one repository layer that
  every query goes through, and there is a test that proves a cross-tenant read fails.
- **Log grants, revocations and denials.** A denial nobody records is a probe nobody sees.

### 3.3 Session management — ASVS V7 · CWE-384, CWE-613

| Type | Requirement |
|---|---|
| All | Session cookies with `HttpOnly`, `Secure`, `SameSite=Lax` (or `Strict`), `Path` scoped. Never store session tokens in `localStorage` or `sessionStorage` — anything XSS can read is not a session control |
| P2, I2, C1, C2, R1, R2 | Absolute timeout **and** idle timeout, both enforced server-side |

- **Regenerate the session identifier on every privilege change** — login, step-up MFA, role
  assumption. Failing to is session fixation (CWE-384).
- **Logout invalidates server-side**, not just by clearing the cookie.
- Session identifiers come from a **cryptographically secure random source** with at least 128
  bits of entropy (CWE-330). `Math.random()`, `rand()` and `java.util.Random` are not that.
- Consider, and document if rejected: concurrent-session limits, re-authentication for
  sensitive operations, and binding notable session changes (IP, device) to a re-auth prompt.

### 3.4 Input validation, injection and output encoding — ASVS V1, V2, V5 · CWE-79, CWE-89, CWE-78, CWE-77, CWE-94, CWE-22, CWE-502, CWE-434, CWE-20 · A05:2025

| Type | Requirement |
|---|---|
| All | Validate every input server-side: type, length, range, format. Allowlist over denylist. Context-correct output encoding |
| C1, C2, R1, R2 | The above, plus response sanitisation, correct `Content-Type` on every response, and masking of sensitive fields in responses and logs |

**The rule that prevents most of the list above: never build an interpreted string by
concatenation.**

- **SQL** — parameterised queries or a query builder that parameterises. If dynamic identifiers
  are unavoidable, allowlist them against a fixed set (CWE-89).
- **OS commands** — pass an argument array to the process API. Never a shell string. If a shell
  is truly required, the arguments come from an allowlist (CWE-78, CWE-77).
- **Templates, expression languages, `eval`** — never evaluate user-controlled content
  (CWE-94).
- **Paths** — resolve the candidate path, then assert it is inside the intended base directory.
  Rejecting `../` by string match is not enough (CWE-22).
- **Deserialization** — never deserialize untrusted data into arbitrary types. Prefer a data
  format with no code semantics (JSON with a strict schema) over Java serialization, Python
  `pickle`, PHP `unserialize`, or YAML loaded unsafely (CWE-502).
- **XML** — disable external entity resolution and DTD processing (XXE, CWE-611).
- **XSS** — encode on output, for the context (HTML body, attribute, JS, URL, CSS). Use the
  framework's auto-escaping and treat every `dangerouslySetInnerHTML` / `v-html` / `|safe` as a
  finding requiring justification. Add a **Content Security Policy** as defence in depth, not as
  the control (CWE-79).
- **File uploads** — validate the declared type *and* sniff the content; cap size; store outside
  the web root, or in object storage with a non-guessable key; never derive the stored filename
  from user input; serve back with `Content-Disposition: attachment` and a fixed
  `Content-Type`; scan where the file will be opened by a human (CWE-434).
- **Mass assignment** — see §3.2.

**Validate even behind a WAF.** A WAF buys time to patch; it is not the control.

### 3.5 Request forgery and cross-origin — ASVS V3, V4 · CWE-352, CWE-918, CWE-601 · A01/A02:2025

These three were absent from the previous version of this guide and are among the most
commonly exploited.

- **CSRF (CWE-352, #3 in the CWE Top 25).** Any state-changing request authenticated by an
  ambient credential (cookie) needs either `SameSite=Strict`/`Lax` cookies **plus** an
  anti-forgery token, or a non-ambient credential (an `Authorization` header the browser does
  not attach automatically). Never rely on `POST` alone, on a `Referer` check alone, or on
  "it's an API".
- **SSRF (CWE-918, API7:2023).** Any feature that fetches a URL the user supplies — webhooks,
  image imports, PDF renderers, link previews, "test this endpoint" buttons — must resolve the
  hostname and **reject private, loopback, link-local and metadata addresses after resolution**
  (`169.254.169.254`, `127.0.0.0/8`, `10/8`, `172.16/12`, `192.168/16`, `::1`, `fd00::/8`), with
  redirects re-checked at every hop. Where possible, route the fetch through an egress proxy
  with an allowlist and no credentials attached.
- **Open redirect (CWE-601).** Redirect targets come from an allowlist or a server-side lookup,
  never from a raw query parameter.
- **CORS.** Never reflect the `Origin` header. Never combine `Access-Control-Allow-Origin: *`
  with `Access-Control-Allow-Credentials: true`. Enumerate allowed origins; treat a wildcard
  subdomain as an allowlist entry that a subdomain takeover would hand to an attacker.
- **Security headers** as a baseline for anything rendering HTML: `Content-Security-Policy`,
  `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `Referrer-Policy`,
  `Cross-Origin-Opener-Policy`.

### 3.6 Cryptography and data protection — ASVS V11, V12, V14 · CWE-327, CWE-330, CWE-200 · A04:2025

| Type | At rest | In transit |
|---|---|---|
| P1, P2 | Not required | **TLS mandatory** |
| I1, I2 | AES-256-GCM (or an equivalent AEAD), keys from a KMS | TLS |
| C1, C2, R1, R2 | The above, with envelope encryption where a data key per record or per tenant is warranted | TLS, plus mTLS for service-to-service on Restricted paths |

- **TLS 1.2 minimum, 1.3 preferred.** Disable renegotiation and legacy cipher suites. Internal
  service-to-service traffic is not exempt.
- **Use an AEAD mode.** AES-GCM or ChaCha20-Poly1305. Never ECB. Never CBC without a separate,
  verified MAC — and prefer not to hand-assemble that at all.
- **Never invent a construction.** No custom ciphers, no custom KDFs, no "we XOR it and base64
  it". Use the platform's vetted library.
- **Randomness for anything security-relevant** — tokens, IDs, nonces, salts, password-reset
  links — comes from a CSPRNG: `secrets` (Python), `crypto.randomBytes` (Node),
  `SecureRandom` (Java/.NET), `crypto/rand` (Go). Never the general-purpose PRNG (CWE-338).
- **Keys never live in source control, container images, VM snapshots or config files.** They
  come from a KMS or HSM at runtime, into memory, with access logged.
- **Certificate lifetimes** follow the CA/Browser Forum schedule for publicly trusted TLS
  certificates — **≤200 days as of 15 March 2026**, ≤100 days from March 2027, ≤47 days from
  March 2029 (ballot SC-081v3). Plan for automated issuance and renewal now; a manual process
  will not survive 47 days.
- **Data minimisation.** The safest way to protect a field is not to store it. Where it must be
  stored, mask it in responses and logs, and record its retention period.
- **Post-quantum readiness** is a *should*, not a *must*, for solutions whose data must stay
  confidential past ~2030. Evaluate hybrid key exchange (ML-KEM / FIPS 203) and hybrid
  signatures (ML-DSA / FIPS 204), and keep a cryptographic inventory so the migration is a
  configuration change rather than an archaeology project. Validate library and appliance
  support before any production rollout.

### 3.7 Secrets and credential handling — ASVS V14 · CWE-798 · A02:2025

- **Zero hardcoded credentials.** Not in code, not in config, not in `.env` files that reach the
  repository, not in CI variables printed to logs, not in commit history.
- **Retrieve at runtime** from an approved secret manager — HashiCorp Vault, AWS Secrets
  Manager, Azure Key Vault, GCP Secret Manager, or the client's equivalent. Hold in memory;
  avoid writing to disk.
- **Prefer short-lived dynamic credentials over rotation.** A workload identity or a token with
  a TTL of an hour removes the rotation problem instead of scheduling it.
- **Rotation cadence for static secrets — T-Gency default, replace with the client's policy if
  they have one:**

  | Classification | Static secrets and API keys | On compromise or offboarding |
  |---|---|---|
  | Restricted (R1, R2) | ≤ 90 days | Immediately |
  | Confidential (C1, C2) | ≤ 180 days | Immediately |
  | Internal / Public | ≤ 365 days | Immediately |

  This table is a T-Gency default, not a standard. NIST does not publish a universal interval;
  the defensible principles are *short-lived beats rotated*, *rotation is automated or it does
  not happen*, and *compromise triggers rotation regardless of schedule*.
- **Secret scanning runs in CI and on the full history**, not only on the diff. A secret removed
  in a later commit is still published.
- **Every environment has its own credentials.** Sharing a secret across dev and prod means a
  dev-side compromise is a prod-side compromise.

### 3.8 Error handling and fail-safe — ASVS V16 · CWE-209, CWE-754 · A10:2025

`A10:2025 Mishandling of Exceptional Conditions` is new in the 2025 Top 10, and this is what it
means in practice.

- External error messages are **generic**. No stack traces, no SQL, no schema names, no
  file paths, no library versions.
- The full error is logged internally with a correlation ID that the generic response returns,
  so support can find it without the user seeing it.
- **Fail closed.** An exception in an authorization check denies. An unreachable policy service
  denies. A timeout on a fraud check does not silently approve.
- Every error path is tested. An untested `catch` block is where fail-open lives.

```json
// ❌ Never
{ "error": "SQLException at UserRepo.java:142: column 'password_hash' not found" }

// ✅
{ "error": "An unexpected error occurred.", "correlationId": "7f3c1e94" }
```

### 3.9 Rate limiting and resource control — ASVS V4 · CWE-770, CWE-400 · API4:2023

- Quotas and rate limits **per principal and per source**, applied at the edge *and* in the
  application.
- Stricter limits for unauthenticated callers and for expensive endpoints (search, export,
  report generation, anything that fans out).
- Bound every resource: request body size, upload size, page size, query depth (GraphQL),
  result-set size, concurrent connections, and per-request execution time.
- Return `429` with `Retry-After`. Make thresholds configuration, not constants.
- Protect the *business* flow, not just the endpoint (API6:2023): a coupon endpoint rate-limited
  to 10 rps still loses money if one account can redeem 10 coupons per second.

### 3.10 Security logging and detection — ASVS V16 · A09:2025

| Type | Requirement |
|---|---|
| All | Log authentication, authorization decisions (including denials), privileged actions and configuration changes. Each entry: actor, source IP, ISO-8601 timestamp, action, outcome. Retention **≥90 days** (T-Gency default; regulated clients often require 12 months) |
| C2, R2 | The above, plus read access to sensitive records, and before/after values on modification |

- **Structured logs** (JSON), shipped off the host to a store the application cannot rewrite.
- **Never log** credentials, tokens, session identifiers, full card numbers, or raw personal
  data. Redact at the emitter, not at the sink.
- **Sanitise what you log.** Untrusted input written verbatim into a log is log injection
  (CWE-117), and a log viewer that renders HTML turns it into stored XSS.
- **Alert on patterns, not just on errors**: repeated authorization denials for one principal, a
  spike in 401s, first-time-seen admin action, mass export.

### 3.11 Dependencies and supply chain — A03:2025 · SSDF `PS.*`, `PW.4`

`A03:2025 Software Supply Chain Failures` rose to third in the 2025 Top 10. Treat it as a
first-class control area, not as "run `npm audit` sometimes".

- **Lockfiles committed**, builds reproducible, versions pinned.
- **Vulnerability scanning on every build**, gating on the scanner's exit code, with severity
  judgement handled by a documented waiver rather than by a threshold flag that hides findings.
  `osv-scanner`, `npm audit`, `pip-audit`, `cargo audit`, `govulncheck`, `bundle audit`.
- **Generate an SBOM** (CycloneDX or SPDX) as a build artifact and keep it with the release. It
  is what lets you answer "are we affected?" in an hour instead of a week.
- **Pin CI actions and build images by digest**, not by tag. A mutable tag in a pipeline is
  remote code execution with extra steps.
- **Verify what you pull**: signature or checksum verification for downloaded binaries; no
  `curl | sh` in a build.
- **Guard against dependency confusion**: scope internal packages, and configure the package
  manager so an internal name cannot be resolved from a public registry.
- **Sign your own artifacts** (Sigstore/cosign) and verify signatures at deploy time.

### 3.12 Environment segregation — SSDF `PO.5`

| Type | Minimum environments |
|---|---|
| P1, P2, I1, I2 | 2 (dev + prod) |
| C1, C2, R1, R2 | 3 (dev + QA/staging + prod) |

- **Production data never leaves production.** Non-production uses synthetic or irreversibly
  anonymised data. "Anonymised" means re-identification has been considered and tested, not that
  the name column was blanked.
- Separate credentials, separate keys, separate infrastructure, separate permissions per
  environment.

### 3.13 Verification in the pipeline — SSDF `PW.7`, `PW.8`, `RV.1`

- **SAST** on every pull request, plus a scheduled full scan. Fail the build on new
  high-severity findings; track the backlog of pre-existing ones with owners and dates.
- **SCA** continuously (see §3.11), including licence and end-of-life checks.
- **Secret scanning** on diff and on history.
- **DAST** against a running instance whenever an externally exposed surface changes, and at
  minimum annually otherwise.
- **IaC scanning** where infrastructure is code.
- **Security unit tests** for the controls that matter: a test that a cross-tenant read returns
  404, a test that an unauthenticated call to each route is rejected, a test that the SSRF
  allowlist rejects `169.254.169.254`. These are the tests that catch a regression six months
  from now; a scanner will not.

---

## Step 4 — Reviewing existing code

When asked "is this secure?", answer in this shape. Do not produce a narrative.

```
## Security review — <component> · <type P1–R2> · ASVS <level>

### Summary
Critical: N · High: N · Medium: N · Low: N

### Findings

#### [CRITICAL] Missing object-level authorization on GET /invoices/{id}
- Location: src/api/invoices.ts:48
- CWE-639 · ASVS V8 · API1:2023 · A01:2025
- Evidence: the handler loads by id and returns; no tenant or ownership predicate anywhere
  in the call path (checked invoices.ts, invoiceService.ts, invoiceRepo.ts).
- Impact: any authenticated user can read any invoice by incrementing the id.
- Fix: <the actual code change>
- Test that proves it: a request from tenant B for tenant A's invoice returns 404.

### Not assessed
<What you could not check and why — configuration outside the repo, a dependency you
could not resolve. Never report "not checked" as "not present".>
```

Rules that keep the review honest:

- **Cite a file and a line for every finding.** A finding without a location is a hypothesis.
- **Every finding carries a test** that fails today and passes after the fix. Otherwise the fix
  is unverified and the regression is scheduled.
- **A comment is not evidence.** `// validates the token` above code that does not validate the
  token is itself a finding.
- **Distinguish "absent" from "could not check".** They lead to different actions.
- **Do not pad.** Ten low-severity style notes around one critical finding is how the critical
  finding gets missed.

---

## Quick reference

| Control | P1 | P2 | I1 | I2 | C1 | C2 | R1 | R2 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| ASVS level | L1 | L1+ | L1 | L2 | L2 | L2/L3 | L2/L3 | L3 |
| Authentication | — | OIDC+MFA | OIDC | OIDC+MFA | OIDC+MFA | AAL3 | AAL3 | AAL3 |
| RBAC | least-priv | 2 roles | least-priv | 2 roles | matrix | matrix | matrix | matrix |
| Object-level authz | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Session timeout | — | ✅ | — | ✅ | ✅ | ✅ | ✅ | ✅ |
| Encrypt at rest | — | — | ✅ | ✅ | ✅ | ✅ envelope | ✅ | ✅ envelope |
| TLS | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| CSRF / SSRF / CORS | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Log reads | — | — | — | — | — | ✅ | — | ✅ |
| Log before/after | — | — | — | — | — | ✅ | — | ✅ |
| WAF | — | ✅ | — | ✅ | — | ✅ | — | ✅ |
| Environments | 2 | 2 | 2 | 2 | 3 | 3 | 3 | 3 |
| Threat model | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| SBOM + signing | — | ✅ | — | ✅ | ✅ | ✅ | ✅ | ✅ |

Rows that are ✅ across every column are there on purpose: they cost nothing extra and their
absence is the most common cause of a serious incident.

---

## Where this runs in the delivery loop

Not at the end. Three touchpoints, and the first is the one that matters:

| When | What | Why |
|---|---|---|
| **Writing the Spec** | Threat model (Step 2) → `NFR-*` and `TC-*` citing CWEs | Security shapes the WHAT. A control that appears first in review is a control that gets waived under deadline |
| **Completeness phase** | Implement the constraints the Spec already committed to | Nothing new is discovered here — it was decided in the Spec and deferred, not forgotten |
| **Before the PR** | `production-readiness-gate` over the complete feature | The go/no-go, on evidence |

---

## References

- `references/solution-typology.md` — classification, ASVS level mapping, worked examples
- `references/security-checklist.md` — the full checklist, by area, with ASVS and CWE anchors
- `references/ai-mcp-controls.md` — the AI / agent / MCP overlay
- OWASP ASVS v5.0 · <https://owasp.org/www-project-application-security-verification-standard/>
- OWASP Top 10:2025 · <https://owasp.org/Top10/2025/>
- OWASP API Security Top 10 2023 · <https://owasp.org/API-Security/>
- OWASP Cheat Sheet Series · <https://cheatsheetseries.owasp.org/>
- CWE Top 25 · <https://cwe.mitre.org/top25/>
- NIST SP 800-63B, Digital Identity Guidelines · <https://pages.nist.gov/800-63-3/sp800-63b.html>
- NIST SP 800-218, SSDF v1.1 · <https://csrc.nist.gov/pubs/sp/800/218/final>
- Threat Modeling Manifesto · <https://www.threatmodelingmanifesto.org/>
