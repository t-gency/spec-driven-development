# Orientation Mapping

Maps the gate's control families to three public frameworks, so a security team can see how this
assessment relates to something they already run.

> ## Read this before showing the table to anyone
>
> **This is an orientation aid. It is not audit evidence and must never be presented as such.**
>
> A control mapping is not: a scope definition, a statement of applicability, an independent
> assessment, a test of operating effectiveness over a period, or an opinion from a qualified
> assessor. This gate produces a point-in-time inspection of one repository, performed by the
> team building the software.
>
> The correct sentence to a client is: *"This is engineering evidence your compliance function
> can evaluate as one input. Whether it satisfies any control in your programme is their
> determination, not ours."*
>
> Do not use this mapping in a proposal, a report header, or a skill description to imply that
> running this gate produces audit evidence, satisfies a control, or contributes to a
> certification.

**Frameworks referenced.** [NIST SP 800-218 SSDF v1.1](https://csrc.nist.gov/pubs/sp/800/218/final)
and [NIST CSF 2.0](https://www.nist.gov/cyberframework) are US government publications and freely
available. ISO/IEC 27001:2022 is a paid standard; only Annex A control *identifiers* are cited
here, never its text, and the mapping is our reading, not ISO's.

---

## Security controls

| Gate ID | Control | NIST SSDF | NIST CSF 2.0 | ISO 27001:2022 Annex A |
|---|---|---|---|---|
| SEC-01 | Threat modeling | `PW.1.1` | `ID.RA-01` | A.8.25, A.8.27 |
| SEC-02 | Authentication | `PW.4`, `PW.5` | `PR.AA-01`, `PR.AA-03` | A.5.16, A.5.17, A.8.5 |
| SEC-03 | Authorization, incl. object level | `PW.5` | `PR.AA-05` | A.5.15, A.5.18, A.8.2, A.8.3 |
| SEC-04 | Input validation and output encoding | `PW.5`, `PW.7` | `PR.PS-06` | A.8.26, A.8.28 |
| SEC-05 | Encryption in transit and at rest | `PW.9` | `PR.DS-01`, `PR.DS-02` | A.8.24 |
| SEC-06 | Secret management | `PO.5`, `PW.9` | `PR.AA-01` | A.5.17, A.8.24 |
| SEC-07 | Security event logging | `PW.8` | `DE.CM-03`, `PR.PS-04` | A.8.15, A.8.16 |
| SEC-08 | SAST / SCA / DAST / secret scanning in CI | `PW.7`, `PW.8`, `RV.1` | `ID.RA-01`, `DE.CM-08` | A.8.8, A.8.29 |
| SEC-09 | Supply chain: pinning, SBOM, signing | `PO.3`, `PS.1`–`PS.3`, `PW.4` | `ID.RA-09`, `PR.PS-01` | A.5.20, A.5.21, A.8.30 |
| SEC-10 | Rate limiting and resource bounds | `PW.5` | `PR.IR-01`, `DE.CM-01` | A.8.6, A.8.20 |
| SEC-11 | Environment segregation | `PO.5` | `PR.PS-01` | A.8.31, A.8.33 |
| SEC-12 | Fail-closed error handling | `PW.5` | `PR.PS-06` | A.8.28 |
| SEC-13 | Container image hardening | `PO.5`, `PW.6` | `PR.PS-01`, `PR.PS-02` | A.8.9, A.8.19 |
| SEC-14 | Vulnerability gate | `RV.1`, `RV.2`, `RV.3` | `ID.RA-01`, `RS.MI-01` | A.8.8 |
| SEC-15 | Regulatory obligations | `PO.1` | `GV.OC-03` | A.5.31, A.5.34 |
| SEC-16 | AI / agent / MCP overlay | `PW.1`, `PW.5`; SP 800-218A | `GV.OV-01`, `PR.PS-06` | A.8.25, A.8.28 |

## Engineering pillars

| Pillar | NIST CSF 2.0 | ISO 27001:2022 Annex A |
|---|---|---|
| Stable and reliable (`STB`) | `PR.PS-01`, `PR.PS-06` | A.8.25, A.8.29, A.8.31, A.8.32 |
| Scalable and performant (`SCP`) | `ID.AM-08`, `PR.IR-04` | A.8.6 |
| Fault tolerant (`FLT`) | `PR.IR-03`, `RC.RP-01`, `RS.MA-01` | A.5.29, A.5.30, A.8.13, A.8.14 |
| Observable and monitored (`OBS`) | `DE.CM-01`, `DE.AE-02` | A.8.15, A.8.16, A.8.17 |
| Documented and understood (`DOC`) | `GV.RR-02`, `ID.AM-02` | A.5.9, A.5.37 |
| Decommissioning (`DOC-06`) | `PR.DS-11` | A.5.10, A.8.10 |

---

## What this mapping deliberately omits

- **SOC 2.** The Trust Services Criteria are an AICPA framework assessed by a licensed CPA firm
  over a defined period. Nothing an engineering tool produces maps onto a SOC 2 criterion in a
  way that survives contact with an auditor, and claiming otherwise creates contractual exposure
  for the party making the claim. If a client asks, the answer is: *"we produce engineering
  evidence; your auditor decides what it is worth."*
- **Operating effectiveness.** Every row above concerns whether a control is *designed and
  present*. Whether it *operated* consistently across a period is a different question that this
  assessment cannot answer.
- **Organizational controls.** Hiring, training, physical security, vendor management, business
  continuity beyond this service. Most of ISO 27001 lives outside a code repository.
- **Sector regimes.** GDPR, HIPAA, PCI DSS, DORA and their equivalents impose obligations well
  beyond software controls. Assess them as a separate overlay, and label them as such in the
  report.

---

## How to use it well

The mapping earns its place in exactly one conversation: a client's security team asks *"where
does your assessment fit with what we already do?"*, and this table answers in thirty seconds
instead of an hour.

Use it there. Do not use it as a coverage claim, and do not let it grow a percentage column — a
"78 % ISO coverage" number is indefensible the moment someone asks how it was computed.
