# Container Image Security Checklist

Severity drives the CI gate: **CRITICAL or HIGH blocks**, MEDIUM and LOW warn.
Each row names its CIS Docker Benchmark control or its NIST SP 800-190 section so a finding can
be traced to a public source.

> Verify CIS control numbers against the benchmark version the client is held to, and record
> which version you checked. Numbering is stable across recent revisions but not guaranteed.

---

## CRITICAL — blocks the build

| # | Check | What to look for | Anchor | Fix |
|---|---|---|---|---|
| C1 | **Runs as root** | No `USER`, or `USER root` at the end | CIS 4.1 · 800-190 §4.4 | Add a numeric non-root user, UID ≥ 10000, before `CMD` |
| C2 | **Secret in a layer** | `ENV`/`ARG` holding a token or password; `COPY .env`, `COPY *.key`, `COPY *.pem`, service-account JSON | CIS 4.10 · CWE-798 | BuildKit `--mount=type=secret` at build; secret manager at runtime |
| C3 | **Privileged or socket-mounted** | `--privileged`, `--cap-add=ALL`, `SYS_ADMIN`, `/var/run/docker.sock` mounted | CIS 5.4, 5.31 | Drop all capabilities; never mount the daemon socket into an app container |
| C4 | **Unpinned base image** | `FROM node:latest`, `FROM python:3.12` | CIS 4.2 | Pin the full version; pin the digest for I2 and above |
| C5 | **Unverified remote execution at build** | `RUN curl … \| sh`, `wget -O- … \| bash` | 800-190 §4.1 · CWE-494 | Download, verify checksum or signature, then execute |
| C6 | **No image scanning anywhere** | No scanner step in CI, no registry scanning | A03:2025 · SSDF RV.1 | Add Trivy/Grype/Snyk gating on exit code |

## HIGH

| # | Check | What to look for | Anchor | Fix |
|---|---|---|---|---|
| H1 | **No multi-stage build** | Compiler, SDK, `devDependencies`, test framework present in the final image | 800-190 §4.1.2 | Split builder and runtime stages |
| H2 | **Missing `.dockerignore`** | Absent, or missing `.git/`, `.env*`, `*.key` | CIS 4.10 | Add a complete `.dockerignore` |
| H3 | **Writable root filesystem at runtime** | No `--read-only` / `readOnlyRootFilesystem: true`; **or `VOLUME ["/tmp"]` used as if it made the FS read-only** | CIS 5.12 | Set the runtime flag; `VOLUME` does not do this |
| H4 | **Capabilities not dropped** | No `--cap-drop=ALL` in run/compose/K8s | CIS 5.3 | Drop all, add back only what is proven necessary |
| H5 | **`no-new-privileges` unset** | Missing from run/compose; `allowPrivilegeEscalation` not `false` in K8s | CIS 5.25 | Set it |
| H6 | **Base packages not patched** | No `apt-get upgrade` / `apk upgrade` in the build, and no rebuild schedule | CIS 4.9 | Patch in build; rebuild on a schedule |
| H7 | **`ADD` instead of `COPY`** | `ADD` used for a local file | CIS 4.9 (OWASP CS) | Use `COPY` unless remote fetch or auto-extract is intended and verified |
| H8 | **Unpinned OS packages** | `apk add curl`, `apt-get install python3` with no version | SSDF PS | Pin versions; use `--no-install-recommends` |
| H9 | **No resource limits** | No memory/CPU/PID limits in compose or K8s | CIS 5.10, 5.11, 5.28 | Set limits — they are a containment control |
| H10 | **No SBOM or provenance** | No SBOM artifact, no build attestation | SSDF PS.3 | Emit SBOM + provenance per build; keep with the release |
| H11 | **Images unsigned or signatures unverified** | No cosign/Notation signing, or signing with no admission check | SSDF PS.2 | Sign at build, verify at admission |

## MEDIUM

| # | Check | What to look for | Anchor | Fix |
|---|---|---|---|---|
| M1 | **No HEALTHCHECK** | Absent, and no orchestrator probe either | CIS 4.6 | Add one, or document the probe that replaces it |
| M2 | **HEALTHCHECK exec form with `\|\| exit 1`** | `CMD ["wget", …] \|\| exit 1` — the `\|\| exit 1` is silently ignored | CIS 4.6 | Use shell form, or `CMD-SHELL` in compose |
| M3 | **Excessive `EXPOSE`** | More ports than the process listens on | 800-190 §4.4 | Expose only the listening port; prefer ≥1024 |
| M4 | **Package cache left in the layer** | No `rm -rf /var/lib/apt/lists/*` or `--no-cache` in the same `RUN` | CIS 4.9 | Clean in the same layer |
| M5 | **Missing OCI labels** | No `org.opencontainers.image.source` / `.revision` | SSDF PS.3 | Add the standard label set |
| M6 | **Oversized image** | >200 MB for an interpreted stack, >50 MB for Go | 800-190 §4.1 | Smaller base, multi-stage, drop unused packages |
| M7 | **No `WORKDIR`** | Defaults to `/` | OWASP CS | Set an explicit `WORKDIR` |
| M8 | **Unrestricted egress** | No NetworkPolicy, no egress proxy, container can reach anything | 800-190 §4.5 | Default-deny egress; allowlist what is needed |

## LOW

| # | Check | What to look for | Fix |
|---|---|---|---|
| L1 | Shell-form `CMD`/`ENTRYPOINT` | `CMD python main.py` | Use exec form so signals reach PID 1 |
| L2 | No locale set | Missing `LANG` | `ENV LANG=C.UTF-8` |
| L3 | Avoidable layers | Long chains of consecutive `RUN` | Combine with `&&` where it aids cache correctness |
| L4 | No non-root check in CI | Nothing asserts the built image's default user | Add `docker inspect --format '{{.Config.User}}'` assertion |

---

## AI / agent / MCP overlay

Only when the container runs or calls an LLM, an agent or an MCP server. Rationale:
`secure-dev/references/ai-mcp-controls.md`.

| # | Check | Severity | Fix |
|---|---|---|---|
| AI1 | Unrestricted egress to model providers | CRITICAL | NetworkPolicy or egress proxy allowlisting approved provider endpoints |
| AI2 | Unauthenticated container↔model/MCP traffic on a Confidential/Restricted path | CRITICAL | mTLS or signed tokens; network placement is not authentication |
| AI3 | Provider credentials in `ENV` or image layers | CRITICAL | Secret manager at runtime; never `ENV`, never a layer |
| AI4 | MCP server image pulled by tag, unreviewed | HIGH | Source-review, pin by digest, treat as a dependency with tool-calling rights |
| AI5 | No PID or memory limit on an agent workload | HIGH | Set both — an unbounded agent loop takes the node with it |
| AI6 | Tool-call authorization implemented in the system prompt | CRITICAL | Enforce in code at the tool layer |
| AI7 | No log of tool invocations | HIGH | Log request/actor/tool/outcome/model, without secrets |

---

## CI gate

| Gate | Rule |
|---|---|
| **Block** | Any CRITICAL or HIGH finding, or any CRITICAL/HIGH CVE from the image scanner without a time-bounded, approved waiver |
| **Warn** | Any MEDIUM or LOW |
| **Pass** | Neither |

Two rules that keep the gate honest:

- **A gate failure is evidence of a gap; a gate pass is not evidence of a secure image.** Half
  the controls here (read-only root, capabilities, egress, admission verification) are runtime
  settings this checklist can only observe if the runtime configuration is in the repository.
- **Never report "not checked" as "not present".** If the compose or Kubernetes manifest is not
  in the repo, list those items as *not assessed* with the artifact that would settle them.
