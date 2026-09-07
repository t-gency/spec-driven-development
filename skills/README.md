# Security skills — public-standards edition

Three skills that keep bad practice out of the code and out of the release: secrets in the
repo, missing object-level authorization, unvalidated input, containers running as root,
services shipping without a tested rollback.

**Take them, adapt them, share them.** Every control here is anchored to a standard anyone can
download and check. Nothing in this folder depends on a private policy, a named vendor, or a
document a reader cannot obtain.

---

## Why this folder was rewritten

The previous version of these skills encoded a third party's internal secure-development policy:
their control numbering, their remediation cadences, their approval workflow, their choice of
MFA hardware and secrets vendor, and references to an internal document nobody outside that
organization can read. That made the skills unusable outside the context they came from, and
unwise to distribute at all.

This edition keeps the engineering — the tiering idea, the evidence discipline, the PASS /
FAIL / **UNVERIFIED** distinction, the severity model, the report shapes — and re-derives every
control from public sources:

| Anchor | Where it is used |
|---|---|
| [OWASP ASVS v5.0](https://owasp.org/www-project-application-security-verification-standard/) | The requirement set and the L1/L2/L3 assurance ladder |
| [OWASP Top 10:2025](https://owasp.org/Top10/2025/) · [API Security Top 10 2023](https://owasp.org/API-Security/) | Risk categories and API-specific failures |
| [CWE Top 25](https://cwe.mitre.org/top25/) | Naming a defect precisely enough to test for it |
| [NIST SP 800-63B](https://pages.nist.gov/800-63-3/sp800-63b.html) | Authentication assurance, password and MFA rules |
| [NIST SP 800-218 (SSDF)](https://csrc.nist.gov/pubs/sp/800/218/final) · [800-218A](https://csrc.nist.gov/pubs/sp/800/218/a/final) | Lifecycle practices; the generative-AI profile |
| [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker) · [NIST SP 800-190](https://csrc.nist.gov/pubs/sp/800/190/final) | Container build and runtime hardening |
| [OWASP Top 10 for LLM Applications 2025](https://genai.owasp.org/llm-top-10/) | The AI / agent / MCP overlay |
| [CVSS v4.0](https://www.first.org/cvss/) · [EPSS](https://www.first.org/epss/) · [CISA KEV](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) | The vulnerability gate |

Two things follow from that choice, and both are improvements:

- **A client can verify our work.** Every threshold is either cited or explicitly labelled a
  T-Gency default they are free to replace with their own policy.
- **The gaps are visible.** The previous version silently omitted CSRF, SSRF, IDOR, insecure
  deserialization, CORS, mass assignment, password hashing, JWT validation, SBOM and signing —
  several of which sit in the current OWASP and CWE top tens. They are covered here.

---

## The three skills

| Skill | Use it when |
|---|---|
| **`secure-dev`** | Writing or reviewing application code. Threat modeling, authentication, authorization, sessions, injection and encoding, CSRF/SSRF/CORS, cryptography, secrets, error handling, rate limiting, logging, supply chain, and the AI/agent/MCP overlay |
| **`secure-container-images`** | Anything with a Dockerfile or Containerfile. Multi-stage builds, non-root, capabilities, read-only root filesystem, image scanning, SBOM and signing |
| **`production-readiness-gate`** | Deciding whether something ships. A six-pillar go/no-go with a vulnerability gate, graded on evidence found in the repository |

### What `production-readiness-gate` is, precisely

An **engineering assessment**, not a compliance certification and not an approval authority. A
`GO` means *the controls we could check are implemented and evidenced in this repository at this
commit*. It does not replace a penetration test, an architecture review, a compliance audit, or
the accountable owner's sign-off.

When a client asks whether it helps with an audit programme, the honest answer is that it
produces engineering evidence their compliance function can evaluate as one input, and that
whether it satisfies any given control is their determination. The orientation mapping in
`production-readiness-gate/references/standards-mapping.md` exists for that conversation and
carries the same caveat at the top of the file.

---

## Installing

**Copy into a repository.** Drop the folders into `.claude/skills/` and they load automatically:

```
.claude/skills/
├── secure-dev/
├── secure-container-images/
└── production-readiness-gate/
```

**Or package them as a plugin** if you want a version number and one install command for a
team. See the plugins document for the manifest shape.

---

## Invoking

Plain language. You never type a skill's name:

> Is this endpoint secure? Review it against our standards.

> Review this Dockerfile for security issues.

> Is this service ready for production?

The `description` in each `SKILL.md` is what routes the request. **If you adapt a skill and it
stops loading when you expect it to, the description is where to look** — not the instructions.
Each description here also says what the skill is *not* for, so the three do not compete for the
same request.

---

## Where they belong in the delivery loop

Not at the end. Three touchpoints, and the first is the one that matters:

| When | Which | Why |
|---|---|---|
| **Writing the Spec** | `secure-dev`, starting with the threat model | So `NFR-*` and `TC-*` come from a real control list and a real threat list, not from intuition. Security shapes the WHAT |
| **Completeness phase** | `secure-dev`, `secure-container-images` | Implementing the constraints the Spec already committed to — nothing new is discovered here |
| **Before the PR** | `production-readiness-gate` | The go/no-go over the complete feature, on evidence |

Running only the last one turns security into a veto at the most expensive moment, and the one
most likely to be waived under deadline.

---

## Adapting them for a client

1. **Replace the classification if they have one.** `secure-dev/references/solution-typology.md`
   separates T-Gency's P1–R2 scoping matrix from the ASVS level it selects, precisely so the
   first half can be swapped for the client's data-classification scheme while the controls stay
   anchored to a public standard.
2. **Replace every T-Gency default with their policy** where they have one — secret rotation
   cadence, log retention, remediation SLAs, exception approval levels. Each is labelled as a
   default in the text. Record which policy and which version you assessed against.
3. **Keep the evidence rules.** *A PASS without a citation is an UNVERIFIED*, *never report "could
   not check" as "not present"*, and *a gate failure is evidence of a gap while a gate pass is
   not evidence of an implementation*. These are what make the output worth reading, and they
   are the parts most likely to be lost in adaptation.
4. **Say what you did not assess.** Every report shape here has a section for it. It is not
   optional.

---

## Known gaps

Stated rather than implied, because a checklist that hides its edges is worse than a short one:

- **Infrastructure as code and Kubernetes** beyond the container security context: no Terraform,
  NetworkPolicy, cluster RBAC or admission-policy coverage.
- **Mobile and desktop clients**: no coverage.
- **Model safety and evaluation** — whether a model produces harmful output — is a separate
  discipline and is out of scope for the AI overlay, which covers the security of the system
  around the model.
- **Privacy engineering** beyond data minimisation and retention: no data mapping, subject-rights
  workflow, or international transfer analysis.
- **Cloud provider configuration**: IAM policy review, network architecture and storage
  permissions are assessed only where they appear as code in the repository.

Check what else is missing for your stack before assuming the list is complete.
