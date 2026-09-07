# Security Implementation Checklist

One line per obligation, each anchored to a public standard so a reviewer can check the source.
Work through the sections that apply to the solution's type; the tier column says where each
item becomes mandatory.

**Anchors:** ASVS = [OWASP ASVS v5.0](https://owasp.org/www-project-application-security-verification-standard/)
chapter · CWE = [MITRE CWE](https://cwe.mitre.org/) · A0x = [OWASP Top 10:2025](https://owasp.org/Top10/2025/)
· APIx = [OWASP API Security Top 10 2023](https://owasp.org/API-Security/)

A box that cannot be ticked is either a finding or a declared exception with an owner.
**An unticked box with no note is a defect; a declared exception is a decision.**

---

## 0 · Threat model — all tiers · SSDF PW.1.1

- [ ] A dated data-flow sketch exists with every trust boundary drawn
- [ ] STRIDE walked across each boundary; threats enumerated with IDs
- [ ] Each threat has a response that lands as a `TC-*` or `NFR-*`, or an explicit acceptance with an owner
- [ ] Each security `TC-*` cites the CWE it defends against, verbatim (`defends CWE-89 SQL Injection`)
- [ ] The model is revisited when a trust boundary moves

---

## 1 · Authentication — ASVS V6 · A07 · CWE-287, CWE-306

- [ ] Mechanism matches the tier (none / OIDC / OIDC+MFA / phishing-resistant MFA)
- [ ] Authorization Code + PKCE; **no** Resource Owner Password Credentials, **no** Implicit
- [ ] MFA meets NIST 800-63B **AAL2** (P2, I2, C1) or **AAL3**, phishing-resistant (C2, R1, R2)
- [ ] Passwords stored with Argon2id, scrypt or bcrypt — never a fast or bare hash (CWE-916)
- [ ] Password policy: ≥8 chars, breached-password screening, **no composition rules, no forced periodic rotation**
- [ ] Throttling/lockout on repeated failures, per account **and** per source
- [ ] Failure responses are uniform — no user enumeration (CWE-204)
- [ ] All authentication events logged with actor, source IP, timestamp, outcome
- [ ] No default, seeded or demo credentials in any environment
- [ ] Service-to-service authenticated by mTLS, signed token or workload identity — never by network position

### Tokens — ASVS V9, V10 · CWE-347
- [ ] `alg` pinned server-side; `alg: none` rejected
- [ ] `iss`, `aud`, `exp`, `nbf` validated on every request
- [ ] Access tokens short-lived; refresh tokens rotated with reuse detection
- [ ] No confidential data inside a JWT payload (signed ≠ encrypted)

---

## 2 · Authorization — ASVS V8 · **A01** · API1, API3, API5 · CWE-862, CWE-863, CWE-639

- [ ] Enforced server-side on **every** request; no client-side-only checks (CWE-602)
- [ ] **Object-level** authorization on every object access, not only at the route (API1, CWE-639)
- [ ] **Property-level** binding via an explicit allowlist — no whole-body binding (API3, CWE-915)
- [ ] Deny by default: a route with no policy is unreachable
- [ ] Authorization centralised in one middleware/policy layer; exceptions documented
- [ ] Role/permission matrix written down (C1, C2, R1, R2)
- [ ] Least privilege at API, service, database and filesystem layers
- [ ] Multi-tenant: tenant predicate enforced in the data layer (row-level security or a single audited repository layer)
- [ ] A test exists proving a cross-tenant read fails
- [ ] Grants, revocations **and denials** are logged

---

## 3 · Session management — ASVS V7 · CWE-384, CWE-613

- [ ] Cookies: `HttpOnly`, `Secure`, `SameSite`, scoped `Path`
- [ ] Session tokens never in `localStorage` / `sessionStorage`
- [ ] Session ID from a CSPRNG, ≥128 bits of entropy (CWE-330)
- [ ] ID regenerated on login and on every privilege change (CWE-384)
- [ ] Absolute **and** idle timeouts, enforced server-side (P2, I2, C1, C2, R1, R2)
- [ ] Logout invalidates server-side
- [ ] Concurrent-session limits and re-auth for sensitive operations considered and documented

---

## 4 · Input validation, injection, output encoding — ASVS V1, V2, V5 · **A05** · CWE-79, 89, 78, 94, 22, 502, 434

- [ ] All input validated server-side: type, length, range, format; allowlist over denylist
- [ ] SQL via parameterised queries; dynamic identifiers allowlisted (CWE-89)
- [ ] OS commands via argument arrays, never a shell string (CWE-78, CWE-77)
- [ ] No `eval`, template or expression evaluation of user-controlled content (CWE-94)
- [ ] Paths resolved then asserted inside the base directory (CWE-22)
- [ ] No deserialization of untrusted data into arbitrary types (CWE-502)
- [ ] XML parsers configured with DTD and external entities disabled (CWE-611)
- [ ] Output encoded per context; framework auto-escaping on; every escape-hatch use justified (CWE-79)
- [ ] Content Security Policy present as defence in depth
- [ ] Uploads: type sniffed as well as declared, size capped, stored outside web root with a non-guessable key, served as `attachment` (CWE-434)
- [ ] Responses sanitised; correct `Content-Type`; sensitive fields masked (C1, C2, R1, R2)

---

## 5 · Request forgery and cross-origin — ASVS V3, V4 · CWE-352, CWE-918, CWE-601

- [ ] State-changing requests protected against CSRF by anti-forgery token **or** non-ambient credentials (CWE-352)
- [ ] `SameSite` set on every session cookie
- [ ] User-supplied URLs: private/loopback/link-local/metadata ranges rejected **after DNS resolution**, redirects re-checked per hop (CWE-918, API7)
- [ ] Outbound fetches routed through an egress allowlist where feasible, with no credentials attached
- [ ] Redirect targets from an allowlist or server-side lookup (CWE-601)
- [ ] CORS: origins enumerated, `Origin` never reflected, no `*` with credentials
- [ ] Headers set: `Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options`, `Referrer-Policy`

---

## 6 · Cryptography and data protection — ASVS V11, V12, V14 · **A04** · CWE-327, CWE-330

**In transit**
- [ ] TLS on all traffic, including service-to-service; TLS 1.2 minimum, 1.3 preferred
- [ ] Legacy cipher suites disabled
- [ ] mTLS on Restricted service-to-service paths
- [ ] Certificate issuance and renewal automated (CA/B Forum: ≤200 days from Mar 2026, ≤100 from 2027, ≤47 from 2029)

**At rest**
- [ ] AES-256-GCM or an equivalent AEAD (I1 and above); never ECB, never unauthenticated CBC
- [ ] Envelope encryption where a per-record or per-tenant data key is warranted (C, R tiers)
- [ ] Keys from a KMS/HSM at runtime; never in repos, images, snapshots or config files
- [ ] Key access is logged; rotation and revocation procedures exist and have been exercised

**Everywhere**
- [ ] No home-rolled cryptographic constructions (CWE-327)
- [ ] All security-relevant randomness from a CSPRNG (CWE-338)
- [ ] Sensitive fields masked in responses and logs; retention period recorded
- [ ] Post-quantum readiness evaluated for data confidential beyond ~2030; cryptographic inventory maintained

---

## 7 · Secrets and credentials — ASVS V14 · **A02** · CWE-798

- [ ] Zero hardcoded credentials in code, config, committed `.env`, or CI logs
- [ ] Retrieved at runtime from an approved secret manager
- [ ] Short-lived dynamic credentials preferred over rotation wherever the platform supports it
- [ ] Static-secret rotation cadence agreed and enforced (T-Gency default: ≤90 d Restricted, ≤180 d Confidential, ≤365 d Internal/Public)
- [ ] Immediate rotation on suspected compromise and on offboarding
- [ ] Secret scanning runs on the diff **and** on full git history
- [ ] Each environment has distinct credentials

---

## 8 · Error handling and fail-safe — ASVS V16 · **A10** · CWE-209, CWE-754

- [ ] External errors generic; no stack traces, schemas, paths or versions
- [ ] Full detail logged internally with a correlation ID returned to the caller
- [ ] Every failure path fails **closed** — auth errors deny, timeouts on checks deny
- [ ] Error paths are covered by tests

---

## 9 · Rate limiting and resource control — ASVS V4 · API4, API6 · CWE-770

- [ ] Limits per principal **and** per source, at the edge and in the application
- [ ] Stricter limits for unauthenticated callers and expensive endpoints
- [ ] Bounds on body size, upload size, page size, query depth, result-set size, concurrency, execution time
- [ ] `429` returned with `Retry-After`; thresholds are configuration
- [ ] Sensitive business flows rate-limited as flows, not just as endpoints (API6)

---

## 10 · Security logging and detection — ASVS V16 · **A09**

- [ ] AuthN, authZ decisions (including denials), privileged actions and config changes logged
- [ ] Entries carry actor, source IP, ISO-8601 timestamp, action, outcome
- [ ] Retention ≥90 days (T-Gency default; confirm the client's regulatory requirement)
- [ ] Structured format, shipped off-host, application cannot rewrite history
- [ ] No credentials, tokens, session IDs, card numbers or raw personal data in logs
- [ ] Logged input sanitised — log injection and log-viewer XSS prevented (CWE-117)
- [ ] Read access and before/after values logged for C2 and R2
- [ ] Alerts on patterns: repeated denials, 401 spikes, first-seen admin action, mass export

---

## 11 · Dependencies and supply chain — **A03** · SSDF PS, PW.4

- [ ] Lockfiles committed; versions pinned; builds reproducible
- [ ] Vulnerability scan on every build, gating on the scanner's exit code
- [ ] Findings triaged with owner and date; waivers documented and time-bounded
- [ ] SBOM (CycloneDX or SPDX) produced per build and kept with the release
- [ ] CI actions and build images pinned by digest, not tag
- [ ] Downloaded binaries checksum- or signature-verified; no `curl | sh` in builds
- [ ] Internal package names scoped against dependency confusion
- [ ] Release artifacts signed (Sigstore/cosign) and verified at deploy

---

## 12 · Environment segregation — SSDF PO.5

- [ ] Minimum environments met (2 for P/I, 3 for C/R)
- [ ] Production data never copied to non-production; synthetic or tested-anonymised data only
- [ ] Separate credentials, keys, infrastructure and permissions per environment
- [ ] Promotion to production passes the defined gates

---

## 13 · Pipeline verification — SSDF PW.7, PW.8, RV.1

- [ ] SAST on every pull request plus a scheduled full scan; build fails on new high findings
- [ ] SCA continuous, including licence and end-of-life checks
- [ ] Secret scanning on diff and history
- [ ] DAST when an externally exposed surface changes, and at minimum annually
- [ ] IaC scanning where infrastructure is code
- [ ] Security regression tests exist for the controls that matter (cross-tenant read denied, unauthenticated route rejected, SSRF allowlist rejects metadata IP)

---

## 14 · AI / agent / MCP overlay

Only if the solution embeds an LLM, runs or calls an agent, or exposes/consumes MCP.
Full detail and rationale in `ai-mcp-controls.md`; the box list is at the end of that file.

- [ ] The overlay checklist in `ai-mcp-controls.md` has been completed in full
