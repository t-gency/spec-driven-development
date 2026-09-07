---
name: production-readiness-gate
description: >
  Assesses whether a service is fit to go to production and returns a GO / CONDITIONAL GO /
  NO-GO verdict with evidence cited from the repository. Use whenever the user asks if
  something is production-ready, ready to go live, ready for release, or asks for a go/no-go,
  a release gate, a pre-production review, a launch readiness check, a production-readiness
  audit, or "está apto para salir a producción". Grades six pillars — stability, scalability,
  fault tolerance, observability, documentation, security — plus a vulnerability gate, marking
  each item PASS, FAIL or UNVERIFIED against an artifact found in the repo.
  It is an engineering assessment, not a compliance certification and not an approval
  authority; its output is input for the team and for whoever owns the release decision.
---

# Production-Readiness Gate

Answers one question: **is this service fit to go to production, and what is the evidence?**

**Evidence model.** Repository and codebase inspection. Never accept a claim without an
artifact. Every item is graded on what can be *found*, not on what the team says.

**Deliverable.** A `PRODUCTION_READINESS.md` written beside the code, versionable with it.

**Verdict.** `GO` / `CONDITIONAL GO` / `NO-GO`.

> **What this skill is not.** It is not a certification, and it does not replace a penetration
> test, an architecture review, a compliance audit, or the accountable owner's sign-off. A `GO`
> here means *the controls we could check are implemented and evidenced in this repository at
> this commit*. Present it that way to clients. If a client needs evidence for an audit
> programme, this assessment is an **input their compliance function evaluates**, not the
> evidence itself.

**Anchors.** The six pillars follow the production-readiness framing popularised by Susan
Fowler's *Production-Ready Microservices* (O'Reilly, 2016) and the operational-readiness
practice in [Google's SRE Book](https://sre.google/books/). The security pillar is anchored to
[OWASP ASVS v5.0](https://owasp.org/www-project-application-security-verification-standard/),
the [OWASP Top 10:2025](https://owasp.org/Top10/2025/) and
[NIST SP 800-218 (SSDF)](https://csrc.nist.gov/pubs/sp/800/218/final). The vulnerability gate
uses [CVSS v4.0](https://www.first.org/cvss/), [EPSS](https://www.first.org/epss/) and the
[CISA KEV catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog).

**Self-contained.** Requires no other skill, connector or MCP server. Two optional companions,
used only if already present — never install, request, or block on them:

- `secure-dev` — how to *implement* a control the assessment found missing. Relevant during
  remediation, not during assessment.
- `secure-container-images` — the same, for image findings.

If the client has their own security policy, **their policy prevails over the defaults in this
skill.** Ask for it, assess against it, and record which version you used. Where this file marks
a threshold as a *T-Gency default*, that is exactly the kind of number a client policy replaces.

---

## Step 0 — Scope and classify

Do this first. Every threshold below depends on it.

1. **Identify the deployable unit.** One service per assessment. In a monorepo, ask which
   service is going live.

2. **Classify** using the three variables in `secure-dev/references/solution-typology.md` — data
   handled, availability/integrity impact, exposure — yielding **P1 … R2** and an **ASVS level**.
   Derive what you can from the repo (is there a public ingress? does it touch personal,
   payment or credential data?), then confirm with the user. **Never guess silently** — state
   the assumption in the report header.

3. **AI / agent / MCP overlay.** Applies additionally if the service embeds an LLM, runs or
   calls an agent, or exposes/consumes MCP. Detect via `openai`, `anthropic`, `langchain`,
   `llamaindex`, `bedrock`, `vertexai`, `mcp`, `@modelcontextprotocol`, `litellm`, `ollama` in
   manifests, or an `.mcp.json` / MCP server implementation in the tree.

4. **Regulatory overlay.** Ask whether GDPR, HIPAA, PCI DSS, SOX, DORA or a sector regime
   applies. These escalate SEC-07 from advisory to blocking, and they are the client's
   determination, not yours.

If the user cannot answer the classification questions, **stop and ask**. An assessment against
the wrong tier is worse than no assessment.

---

## Step 1 — Collect evidence

Read-only sweep before grading anything. Adapt paths to the stack.

```bash
# Inventory
find . -maxdepth 3 -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \
  -o -name "*.json" -o -name "*.toml" \) | head -100
ls -a .github/workflows .gitlab-ci.yml azure-pipelines.yml Jenkinsfile 2>/dev/null

# CI/CD
cat .github/workflows/*.yml 2>/dev/null

# Tests
find . -type d \( -name test -o -name tests -o -name __tests__ -o -name spec \) \
  -not -path "*/node_modules/*"
grep -rEl "jest|pytest|junit|mocha|vitest|go test|rspec" \
  --include="*.json" --include="*.toml" --include="*.xml" --include="*.gradle" . | head

# Security tooling in the pipeline
grep -rEi "codeql|snyk|sonar|trivy|grype|dependabot|semgrep|checkmarx|veracode|zap|gitleaks|trufflehog|osv-scanner|cosign|syft" \
  .github .gitlab-ci.yml Jenkinsfile 2>/dev/null

# Secrets hygiene — findings here are near-always blocking
grep -rEn "(api[_-]?key|secret|password|passwd|token|private[_-]?key)[\"' ]*[:=][\"' ]*[A-Za-z0-9/+=_-]{12,}" \
  --include="*.py" --include="*.js" --include="*.ts" --include="*.java" --include="*.go" \
  --include="*.rb" --include="*.yml" --include="*.yaml" --include="*.json" --include="*.tf" \
  --include="*.env*" --exclude-dir=node_modules --exclude-dir=.git . | head -50
git log --all --oneline -- "*.env" ".env" 2>/dev/null | head

# Observability
grep -rEi "prometheus|opentelemetry|datadog|newrelic|grafana|dynatrace|sentry|elastic|cloudwatch|structlog|winston|zap\.Logger" \
  --exclude-dir=node_modules . | head -30

# Resilience
grep -rEi "circuit_?breaker|resilience4j|hystrix|polly|retry|backoff|timeout|bulkhead|rate_?limit" \
  --exclude-dir=node_modules . | head -30

# Health and deployment
grep -rEi "livenessProbe|readinessProbe|healthcheck|/health|/ready|/healthz" --exclude-dir=node_modules . | head -20
grep -rEi "canary|blue-?green|rollingUpdate|argo|flagger|spinnaker" --exclude-dir=node_modules . | head -20

# Docs and decisions
ls docs/ adr/ architecture/ 2>/dev/null
find . -iname "*adr*" -o -iname "*runbook*" -o -iname "*threat*model*" -o -iname "CHANGELOG*" | head -20

# Open findings (feeds Step 2b)
find . -iname "*.sarif" -o -iname "*sbom*" -o -iname "*scan*report*" | head -20
gh api repos/:owner/:repo/code-scanning/alerts --jq '.[] | {rule:.rule.id, sev:.rule.security_severity_level, state:.state}' 2>/dev/null | head -30
gh api repos/:owner/:repo/dependabot/alerts --jq '.[] | {pkg:.dependency.package.name, sev:.security_advisory.severity, state:.state}' 2>/dev/null | head -30
```

If no scanner output is in the repo, ask the team for the current export. Step 2b needs a list
of open findings with CVE identifiers; without one, SEC-08 is **UNVERIFIED**, not PASS.

### Three states, and the distinction is the whole value

- **PASS** — an artifact was found *and it actually satisfies the requirement*.
- **FAIL** — absent, or present and demonstrably inadequate.
- **UNVERIFIED** — the control lives outside the repository (WAF rules, KMS configuration,
  on-call rotation, penetration-test report). Record what evidence would settle it and who owns
  it.

**Never silently upgrade UNVERIFIED to PASS.** For the verdict, an UNVERIFIED blocker counts as
a blocker — but label it distinctly, because the team's next action differs: FAIL means *build
it*, UNVERIFIED means *show me it exists*.

---

## Step 2 — Grade

Severity drives the verdict:

- 🔴 **BLOCKER** — a FAIL forces `NO-GO`.
- 🟠 **MAJOR** — a FAIL permits `CONDITIONAL GO` with a named owner and a committed date.
- 🟡 **MINOR** — a recommendation; does not gate.

Severity is a baseline. **Escalate one level** when the solution is C2/R2, internet-facing, or
under a regulatory overlay. **Never de-escalate a 🔴** without an explicit risk acceptance from
the accountable owner, quoted verbatim in the report with their name and the date.

### A · Stable and reliable — `STB`

| ID | Requirement | Verify in repo | Sev |
|---|---|---|---|
| STB-01 | Central repository, enforced code review, dev environment representative of production | Branch protection, `CODEOWNERS`, PR template, required reviewers | 🟠 |
| STB-02 | Documented test strategy covering functional and non-functional requirements; lint, unit, integration and e2e; tests gate the merge | Test plan or ADR; test directories; CI gate blocking on failure | 🔴 |
| STB-03 | Build, package and release fully automated — no manual steps | Pipeline definition performing all three | 🔴 |
| STB-04 | Safe deployment strategy (canary, blue-green or rolling), a staging phase, and a rehearsed rollback | Deployment manifests, `strategy:` blocks, documented and *tested* rollback | 🔴 |
| STB-05 | Upstream consumers known and documented | Service docs, consumer list, API contract registry | 🟠 |
| STB-06 | Downstream dependencies known, each with a fallback, cache or documented degradation | Dependency inventory; fallback code paths | 🟠 |
| STB-07 | Health checks on a separate path from business traffic; timeouts and circuit breakers on every outbound call | Liveness/readiness probes; circuit-breaker or timeout configuration | 🟠 |

### B · Scalable and performant — `SCP`

| ID | Requirement | Verify in repo | Sev |
|---|---|---|---|
| SCP-01 | Expected load expressed as a number (business metric → RPS/TPS), not "it should be fine" | Capacity or NFR document with figures | 🟠 |
| SCP-02 | Resource requests and limits set; no unbounded workload | Container/K8s resource blocks | 🟠 |
| SCP-03 | Bottlenecks identified; sizing evidence exists | Load-test results, sizing note, HPA configuration | 🟠 |
| SCP-04 | Autoscaling configured, or a documented reason it is not needed | HPA/ASG configuration | 🟡 |
| SCP-05 | Dependencies confirmed to scale with this service | Written confirmation from the dependency owners | 🟡 |
| SCP-06 | Traffic patterns understood; releases scheduled away from peaks | Traffic note; deployment window policy | 🟡 |
| SCP-07 | Failover across zones or regions possible | Multi-AZ/region configuration, DNS or traffic-manager failover | 🟠 |
| SCP-08 | Data layer scales: schema, expected TPS, read/write profile, replication or partitioning, dedicated vs shared | Migrations, database configuration, ADR on the datastore choice | 🟠 |

### C · Fault tolerant — `FLT`

| ID | Requirement | Verify in repo | Sev |
|---|---|---|---|
| FLT-01 | No single point of failure, or every SPOF explicitly accepted with a named owner | Architecture diagram; replica counts; no single-instance stateful dependency | 🔴 |
| FLT-02 | Failure modes enumerated across hardware, network, application and dependency layers | Failure-mode analysis or resiliency note | 🟠 |
| FLT-03 | Resilience tested — load tests, and fault injection where the blast radius justifies it | k6/Gatling/JMeter scripts; chaos experiments; results | 🟠 |
| FLT-04 | Detection and remediation automated (alert → rollback or failover) | Auto-rollback in the pipeline; alert-to-action wiring | 🔴 |
| FLT-05 | Incident procedure documented; criticality tier assigned; escalation path named | Incident runbook; severity matrix; link to the org's process | 🟠 |
| FLT-06 | Backups exist, **and a restore has been performed and timed**; RPO and RTO stated | Backup configuration plus a dated restore-test record | 🔴 |

FLT-06 is the one teams most often fail. A backup nobody has restored is a hypothesis.

### D · Observable and monitored — `OBS`

| ID | Requirement | Verify in repo | Sev |
|---|---|---|---|
| OBS-01 | Key metrics instrumented at service and infrastructure level; SLIs and SLOs defined | Instrumentation code; SLO definitions; dashboards as code | 🔴 |
| OBS-02 | Structured logs shipped off-host; sensitive data redacted at the emitter; log input sanitised (CWE-117) | Logging configuration; redaction; no raw personal data | 🔴 |
| OBS-03 | Dashboards cover the key metrics and mark deployments | Dashboard definitions in the repo, or a documented link | 🟠 |
| OBS-04 | Alerts are actionable and threshold-driven, each with a runbook entry; channels documented | Alert rules as code; one runbook section per alert | 🔴 |
| OBS-05 | On-call rotation exists with a documented escalation path and post-incident review practice | On-call document; escalation matrix; post-mortem template | 🟠 |
| OBS-06 | Distributed tracing across service boundaries, or a documented reason it is not needed | OpenTelemetry or equivalent instrumentation | 🟠 |

### E · Documented and understood — `DOC`

| ID | Requirement | Verify in repo | Sev |
|---|---|---|---|
| DOC-01 | Documentation exists in one findable place | `README`, `docs/`, or a linked knowledge base | 🟠 |
| DOC-02 | Documentation changes in the same change as the behaviour it describes | `git log --stat` shows doc changes alongside code changes | 🟡 |
| DOC-03 | Covers: purpose, architecture diagram, ownership and on-call contact, local setup, request flow and endpoints, dependencies, runbook, FAQ | Check each of the eight and list which are missing | 🟠 |
| DOC-04 | Architectural decisions recorded as ADRs; changelog uses semantic versioning | `docs/adrs/`; `CHANGELOG.md` | 🟠 |
| DOC-05 | Someone other than the author can operate it | Runbook detail sufficient for a non-author; verified by asking one | 🟡 |
| DOC-06 | A decommissioning plan exists: data deletion, credential revocation, retention obligations, archival | Documented plan | 🟡 |

### F · Secure — `SEC`

Grade against the ASVS level from Step 0. Implementation guidance lives in `secure-dev`; this
table asks only *is it implemented and evidenced*.

| ID | Requirement | Anchor | Verify in repo | Sev |
|---|---|---|---|---|
| SEC-01 | A dated threat model exists, with each threat resolved into a control or an accepted risk | SSDF `PW.1.1` · A06:2025 | Threat-model document with a date; controls traceable to threats | 🔴 |
| SEC-02 | Authentication meets the tier: OIDC Authorization Code + PKCE; MFA at AAL2 (P2/I2/C1) or phishing-resistant AAL3 (C2/R1/R2); no ROPC, no Implicit | ASVS V6 · NIST 800-63B | Auth configuration; MFA enforcement; absence of ROPC/Implicit | 🔴 |
| SEC-03 | Authorization enforced server-side on every request, **including object-level checks**; deny by default; tenant isolation enforced in the data layer | ASVS V8 · A01:2025 · API1:2023 | Central authorization middleware; ownership predicate on object reads; a test proving a cross-tenant read fails | 🔴 |
| SEC-04 | Input validated and output encoded; parameterised queries; no unsafe deserialization; CSRF, SSRF and CORS controls present | ASVS V1/V2/V3/V4 · A05:2025 | Query construction; validation layer; SSRF allowlist; CORS configuration | 🔴 |
| SEC-05 | Data protected in transit (TLS 1.2+, mTLS on Restricted service paths) and at rest (AEAD, KMS-managed keys); no key material in the repo | ASVS V11/V12/V14 · A04:2025 | TLS configuration; encryption configuration; zero key material in the tree | 🔴 |
| SEC-06 | Secrets in a secret manager, injected at runtime, never hardcoded; per-environment; rotation or short-lived credentials in place | ASVS V14 · A02:2025 · CWE-798 | Secret-manager references; zero literal-credential grep hits, **including in git history** | 🔴 |
| SEC-07 | Security event logging: authN, authZ decisions including denials, privileged actions; tamper-resistant store; alerting on patterns | ASVS V16 · A09:2025 | Audit-log emission; off-host sink; alert rules | 🔴 |
| SEC-08 | SAST, SCA, secret scanning and (for exposed surfaces) DAST run in CI and gate the build; findings triaged with owners | SSDF `PW.7/PW.8/RV.1` · A03:2025 | Scanner steps in the pipeline with a failing exit condition | 🔴 |
| SEC-09 | Supply chain: lockfiles committed, CI actions and base images pinned by digest, SBOM produced per build, release artifacts signed and verified at deploy | A03:2025 · SSDF `PS.*` | Lockfiles; digest pins; SBOM artifact; signing and verification steps | 🟠 (🔴 for C2/R2) |
| SEC-10 | Rate limiting and resource bounds per principal and per source; sensitive business flows protected as flows | ASVS V4 · API4/API6:2023 | Rate-limit configuration; body/page/query bounds | 🟠 |
| SEC-11 | Environments segregated; production data never present in non-production | SSDF `PO.5` | Environment configuration; data-seeding scripts | 🔴 |
| SEC-12 | Errors fail closed and leak nothing: generic external messages, full detail internal | ASVS V16 · A10:2025 | Error handler; absence of stack traces in responses | 🔴 |
| SEC-13 | Container image controls met, where the service ships as an image | CIS Docker · NIST 800-190 | Run `secure-container-images` and carry its CRITICAL/HIGH findings here | 🔴 |
| SEC-14 | Open vulnerabilities within the accepted gate | see Step 2b | Scanner export reconciled against the gate | 🔴 |
| SEC-15 | Compliance obligations identified and addressed where a regime applies | client determination | Assessment record; consent model; retention configuration | 🟠 (🔴 when a regime applies) |
| SEC-16 | **AI overlay** — where it applies: tool-layer authorization in code, no credentials in model context, human confirmation for irreversible actions, tool-call audit log, egress allowlist, MCP servers reviewed and pinned | OWASP LLM Top 10 2025 | `secure-dev/references/ai-mcp-controls.md` checklist completed | 🔴 |

---

## Step 2b — The vulnerability gate (SEC-14)

Full method, scoring inputs and worked example: `references/vulnerability-gate.md`.

In short: score each open finding with **CVSS v4.0**, adjust for real-world exploitability using
**EPSS** and the **CISA KEV catalog**, then adjust again for this service's data classification
and exposure. That yields an *adjusted risk*, which drives both the remediation SLA and the
release gate. Critical or High adjusted risk with no valid, unexpired, correctly approved
exception is a `NO-GO`.

The thresholds in that file are **T-Gency defaults**. If the client has a vulnerability
management policy, use theirs and record which version.

---

## Step 3 — The verdict

Apply in order:

1. **NO-GO** if any 🔴 is FAIL, or any 🔴 is UNVERIFIED at the moment of decision.
2. **CONDITIONAL GO** if every 🔴 passes and each failing 🟠 has a named owner, a committed date,
   and a compensating control where the risk is material. State an expiry date for the
   conditional status — a conditional GO without one becomes a permanent GO.
3. **GO** if every 🔴 and 🟠 passes. 🟡 items become recommendations.

**Hard overrides — `NO-GO` regardless of everything else:**

- A live credential, private key or token committed to the repository or present in its history.
- Production data in a non-production environment.
- No tested rollback path.
- No security scanning of any kind in the pipeline.
- Confidential or Restricted data transmitted or stored unencrypted.
- Object-level authorization absent on an endpoint that returns another tenant's or user's data.
- An open Critical or High adjusted-risk finding with no valid, unexpired, correctly approved
  exception.
- No backup, or a backup that has never been restored, for a service holding non-reproducible
  data.

Be plain about failures. The value of this assessment is that a `GO` means something. Do not
soften a finding to reach a comfortable verdict, and do not pad the report with passes to dilute
a blocker. **If the evidence is thin, say the evidence is thin.**

---

## Step 4 — Write `PRODUCTION_READINESS.md`

Write it beside the code. If a previous version exists, append to its history rather than
replacing it.

```markdown
# Production-Readiness Assessment

| | |
|---|---|
| **Service** | <name> |
| **Repository** | <path or URL> · commit `<sha>` |
| **Classification** | <P1–R2> — <data> / <impact> / <exposure> → ASVS <level> |
| **AI overlay** | Applies / Does not apply |
| **Regulatory overlay** | <GDPR, PCI DSS, … or None identified> |
| **Assessed on** | <YYYY-MM-DD> |
| **Assessed by** | <assessor> |
| **Assessed against** | T-Gency Production-Readiness Gate · OWASP ASVS v5.0 · NIST SSDF v1.1 <· client policy vX if supplied> |

## Verdict: <GO / CONDITIONAL GO / NO-GO>

<Two or three sentences: what drives it. If CONDITIONAL, the expiry date.>

### Blocking findings
| ID | Finding | Evidence | Owner | Due |

### Major findings
| ID | Finding | Evidence | Owner | Due |

### Recommendations
| ID | Recommendation |

## Scorecard

| Pillar | Pass | Fail | Unverified | N/A |
|---|---|---|---|---|
| Stable and reliable | | | | |
| Scalable and performant | | | | |
| Fault tolerant | | | | |
| Observable and monitored | | | | |
| Documented and understood | | | | |
| Secure | | | | |

## Detailed results

<One table per pillar: ID · Requirement · Status · Severity · Evidence (file:line, pipeline
step, or "not found") · Note.>

## Vulnerability gate

<Table: Finding · CVSS v4.0 · EPSS · KEV · Classification · Exposure · Adjusted risk · SLA ·
Status · Exception reference, approver and expiry.>

## Evidence not obtainable from the repository

<Every UNVERIFIED item, the artifact that would settle it, and who owns that artifact.>

## Assumptions

<Every assumption, especially about classification.>

## Assessment history

| Date | Commit | Verdict | Assessor |
```

**Rules for the report**

- **Cite a concrete artifact for every PASS** — file and line, pipeline step name, or document
  reference. *A PASS without a citation is an UNVERIFIED.*
- **Quote the failing configuration for every FAIL** rather than describing it.
- **Never include a discovered secret's value.** Name the file, the line and the credential
  type, and flag it for immediate rotation — finding it in the repo means treating it as
  already compromised.
- **Every finding is actionable**: what is missing, where it belongs, what "done" looks like.
- **Say what you did not assess.** A report that is silent about its blind spots reads as a
  clean bill of health it has not earned.

---

## Orientation mapping

`references/standards-mapping.md` maps each control family here to NIST SSDF practices, NIST
CSF 2.0 functions and ISO/IEC 27001:2022 Annex A control identifiers. It exists so a security
team can see how this assessment relates to a framework they already run.

**It is an orientation aid, not audit evidence, and it must be presented that way.** A control
mapping is not a scope, a statement of applicability, an independent assessment, or a period of
operating effectiveness — and this report is generated from a point-in-time repository scan, not
from a controls-testing programme.

---

## References

- `references/vulnerability-gate.md` — the CVSS/EPSS/KEV method, adjusted-risk matrix, SLAs, exceptions
- `references/standards-mapping.md` — orientation mapping to SSDF, CSF 2.0 and ISO 27001 Annex A
- `secure-dev/SKILL.md` — how to implement anything this assessment found missing
- `secure-container-images/SKILL.md` — image findings (SEC-13)
- OWASP ASVS v5.0 · <https://owasp.org/www-project-application-security-verification-standard/>
- NIST SP 800-218 (SSDF v1.1) · <https://csrc.nist.gov/pubs/sp/800/218/final>
- NIST Cybersecurity Framework 2.0 · <https://www.nist.gov/cyberframework>
- Google SRE Book · <https://sre.google/books/>
- Susan Fowler, *Production-Ready Microservices*, O'Reilly, 2016
