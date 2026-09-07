---
name: secure-container-images
description: >
  Builds and reviews hardened container images against the CIS Docker Benchmark, NIST SP
  800-190 and the OWASP Docker Security Cheat Sheet. Use this skill whenever the user wants
  to write or review a Dockerfile or Containerfile, build or harden a container image, set
  up a multi-stage build, write a docker-compose or Kubernetes security context, reduce
  image attack surface, configure image scanning or signing, or containerize a service —
  including an LLM/agent/MCP service. Also trigger on mentions of Docker, Podman, Buildah,
  OCI images, distroless, container escape, image provenance or SBOM, and on questions like
  "is this Dockerfile secure?" or "why is my image so big?".
  Not for application-code security — that is `secure-dev`. Not for the release decision —
  that is `production-readiness-gate`.
---

# Secure Container Images

Hardened, minimal, reproducible images for Docker, Podman and Buildah.

**Anchors** — every control below names its source, so a client's auditor can check it:

| Anchor | Used for |
|---|---|
| [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker) (v1.8.0) | Control IDs for build and runtime hardening |
| [NIST SP 800-190](https://csrc.nist.gov/pubs/sp/800/190/final) — *Application Container Security Guide* | Risk model: image, registry, orchestrator, container, host |
| [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html) | Practical build rules |
| [OWASP Top 10:2025 A03](https://owasp.org/Top10/2025/) · [NIST SSDF](https://csrc.nist.gov/pubs/sp/800/218/final) `PS.*` | Supply-chain integrity, SBOM, signing |

> CIS control numbering is stable across recent revisions but not guaranteed. When a specific
> control ID matters for an audit, verify it against the benchmark version the client is held
> to, and say which version you checked.

**Two modes.** *Generate* — write a secure Dockerfile for a stack. *Validate* — review an
existing one and produce findings with a corrected file. Both follow the same steps.

---

## Step 1 — Context

| Question | Why it matters |
|---|---|
| Language and runtime? | Selects the base image and build pattern |
| Solution type (P1–R2, per `secure-dev`)? | Sets how strict the controls need to be |
| Internet-facing? | Determines network and egress hardening |
| Build-time dependencies? | Decides whether a multi-stage build is required |
| Runtime: Docker, Podman, Buildah? Orchestrated by Kubernetes? | Changes where runtime controls are expressed |
| Does it run or call an LLM, agent or MCP server? | Adds the overlay in Step 2.11 |

If the user does not give a classification, default to **C1** and say so in the first line of
the output.

---

## Step 2 — Controls

### 2.1 Base image — CIS 4.2, 4.9 · NIST 800-190 §4.1

Smallest image that works. Fewer packages means fewer CVEs and less to exploit after a
compromise.

| Stack | Base | Note |
|---|---|---|
| Python | `python:<ver>-slim` or `-alpine` | Alpine's musl breaks some compiled wheels; slim is the safer default |
| Node.js | `node:<ver>-alpine` or `-slim` | Same trade-off |
| Java | `eclipse-temurin:<ver>-jre-alpine`, or a `jlink` runtime on `alpine` | JRE only — no compiler in production |
| Go | `gcr.io/distroless/static-debian12:nonroot` | Static binary; `scratch` only if you also copy CA certs |
| .NET | `mcr.microsoft.com/dotnet/runtime:<ver>-alpine` | Runtime only, no SDK |
| Anything | A distroless or Chainguard-style image | No shell, no package manager — a large step up |

- **Pin the full version, and pin the digest for anything above I1**:
  `python:3.12.11-slim-bookworm@sha256:…`. A floating tag makes the build non-reproducible and
  silently changes what ships (CIS 4.2).
- Prefer official or verified-publisher images, or the client's internal registry.
- Apply available OS patches in the build (CIS 4.9) — `apt-get upgrade` / `apk upgrade` — and
  rebuild on a schedule. An image is only as patched as the day it was built.

### 2.2 Non-root — CIS 4.1 · CIS 5.4 (no privileged) · NIST 800-190 §4.4

Containers run as root by default, and root inside a container is one kernel bug away from root
on the host.

```dockerfile
# Debian/Ubuntu-based
RUN set -eux; \
    groupadd -g 10001 -r app && \
    useradd  -u 10001 -r -g app -d /app -s /usr/sbin/nologin app
```

```dockerfile
# Alpine-based
RUN set -eux; \
    addgroup -g 10001 -S app && \
    adduser  -u 10001 -S -G app -h /app -s /sbin/nologin app
```

- **UID ≥ 10000, explicit and numeric.** Below 1000 collides with host system accounts; a
  numeric `USER 10001` (rather than a name) is what Kubernetes `runAsNonRoot` can verify.
- `USER` goes **after** the last instruction that needs write access and **before** `CMD`.
- No login shell. The application user never needs one.
- Set `runAsNonRoot: true` in Kubernetes so the cluster refuses an image that ignored this.

### 2.3 Multi-stage builds — NIST 800-190 §4.1.2

Compilers, package managers, test frameworks and build secrets are liabilities in a production
image. Keep them in a builder stage.

```dockerfile
FROM python:3.12.11-slim-bookworm AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12.11-slim-bookworm
COPY --from=builder /install /usr/local
```

Complete per-stack templates: `references/templates.md`.

### 2.4 Dependencies — A03:2025 · SSDF `PS.*`

- Pin every application dependency in a committed lockfile.
- Pin OS packages where the distro supports it (`apt-get install pkg=1.2.3-4`), and always use
  `--no-install-recommends`.
- Clean caches **in the same `RUN` layer** — a deleted file in a later layer is still in the
  image.
- Remove build dependencies: `apk add --virtual .build-deps … && … && apk del .build-deps`.
- Verify checksums or signatures for anything downloaded during the build. **Never
  `curl … | sh`** (CIS 4.7 in spirit; it is unverified remote code execution at build time).
- **Produce an SBOM per image** (`docker buildx build --sbom=true`, `syft`, or the scanner's
  output) and store it with the release.

### 2.5 Secrets — CIS 4.10 · CWE-798

Anything in a layer is extractable with `docker history` or by pulling the image.

- **Never** `ARG` or `ENV` for a secret — both persist in image metadata.
- **Never** `COPY` a `.env`, key, certificate or service-account file into the image.
- Build-time secrets use BuildKit mounts, which are not persisted:

  ```dockerfile
  RUN --mount=type=secret,id=npm_token \
      NPM_TOKEN="$(cat /run/secrets/npm_token)" npm ci --omit=dev
  ```
- Runtime secrets are injected from a secret manager or mounted as files — not baked, and
  preferably not passed as environment variables, which leak through `/proc`, crash dumps and
  `docker inspect`.
- Ship a `.dockerignore` that excludes at least `.git/`, `.env*`, `*.pem`, `*.key`, `*.crt`,
  `credentials.*`, `node_modules/`, `__pycache__/`, `*.log`.

### 2.6 Read-only filesystem — CIS 5.12

**A read-only root filesystem is a runtime setting, not a Dockerfile instruction.** `VOLUME` does
not make anything read-only — it declares a mount point and, if anything, creates a writable
anonymous volume. Do not use it for this.

```bash
docker run --read-only --tmpfs /tmp:rw,noexec,nosuid,size=64m myimage
```

```yaml
# Kubernetes
securityContext:
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 10001
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: RuntimeDefault
```

Design the application to write only to `/tmp` or an explicit volume. If it needs to write
elsewhere, that is a finding to fix in the application, not a reason to drop the control.

### 2.7 Capabilities, privileges and network — CIS 5.3, 5.4, 5.25, 5.29 · NIST 800-190 §4.4

```bash
docker run \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \        # only if binding a port < 1024 — better: bind 8080
  --security-opt=no-new-privileges:true \
  --read-only \
  --pids-limit=256 \
  --memory=512m --cpus=1.0 \
  myimage
```

- `--cap-drop=ALL` then add back only what is proven necessary (CIS 5.3).
- `no-new-privileges` blocks privilege escalation via setuid binaries (CIS 5.25).
- **Never `--privileged`** (CIS 5.4). Never mount the Docker socket into a container that does
  not need to be a build agent — it is equivalent to host root.
- `EXPOSE` only the ports the process listens on. Prefer an unprivileged port so no capability
  is needed at all.
- Resource limits are a security control: they contain a resource-exhaustion attack and a
  runaway loop equally (CIS 5.10, 5.11, 5.28).
- Podman runs rootless by default — keep it.

### 2.8 Health checks — CIS 4.6

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --spider --quiet http://127.0.0.1:8080/health || exit 1
```

**Use the shell form here.** `|| exit 1` is shell syntax; appended to the exec form
(`CMD ["wget", …] || exit 1`) it is silently ignored, which is a defect worth checking for in
review. For distroless or `scratch` images there is no shell and no `wget` — ship a tiny health
subcommand in your own binary (`CMD ["/app", "healthcheck"]`), or rely on the orchestrator's
probe instead.

### 2.9 Metadata and provenance — SSDF `PS.3`

```dockerfile
LABEL org.opencontainers.image.source="https://github.com/org/repo" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.licenses="Apache-2.0"
```

Use the OCI standard keys — scanners, registries and policy engines read them. `revision` is
what turns "which commit is in production?" into a lookup instead of an investigation.

### 2.10 Scanning, signing and admission — A03:2025 · SSDF `PS.2`, `PS.3`, `RV.1`

- Scan **in CI on every build** with Trivy, Grype, Snyk or the registry's scanner, and gate on
  the scanner's exit code. Scan the base image and the final image.
- **Re-scan on a schedule.** New CVEs are published against an image that has not changed.
- **Sign images** with cosign (Sigstore) or Notation, and **verify at admission** — an unverified
  signature is a signature nobody checks. Kyverno, Gatekeeper or the registry's policy engine.
- Emit and retain build **provenance** (SLSA attestations via `buildx --provenance=true`) so a
  release can be traced back to a commit and a builder.

### 2.11 Overlay — containers running or calling an LLM, agent or MCP server

Applies in addition to everything above. Full rationale in
`secure-dev/references/ai-mcp-controls.md`; the container-specific parts are:

- **Egress allowlist.** The workload reaches only the approved model provider endpoints. No
  arbitrary outbound. Enforce with a `NetworkPolicy`, an egress proxy or a service mesh — not
  with a configuration file the model can read.
- **Authenticated integration traffic.** mTLS or signed tokens between the container and any
  model or MCP endpoint on a Confidential or Restricted data path. Network placement is not
  authentication.
- **MCP servers are third-party code with tool-calling rights.** An MCP server image is
  reviewed, pinned by digest, and treated as a dependency with database access — because that is
  usually what it is. Do not pull a community MCP image by tag.
- **Credentials never reach the model.** Provider keys are used by the tool implementation
  server-side, never placed in prompts, tool descriptions or tool arguments, and never in
  `ENV` (see 2.5).
- **Bound consumption at the container too:** memory and PID limits stop a runaway agent loop
  from taking the node with it.

---

## Step 3 — Reviewing a Dockerfile

Check every item in `references/security-checklist.md`, then output:

```
## Container image review — <path> · <type P1–R2>

Critical: N · High: N · Medium: N · Low: N

### [CRITICAL] C1 — Runs as root
- Line: no USER instruction in the file
- CIS 4.1 · NIST 800-190 §4.4
- Risk: a container escape from root is root on the host; a compromised process can write
  anywhere in the image filesystem.
- Fix: <the exact lines to add>

… (ordered by severity)

### Corrected Dockerfile
<the complete corrected file>

### Not assessed
<Runtime settings not visible in the Dockerfile — capabilities, read-only root, network
policy. Name them and say where they are configured.>
```

Always hand back the **complete** corrected Dockerfile. Do not make the user apply a patch
list. And keep the last section honest: most of the highest-value controls in this document
(2.6, 2.7) live in the runtime configuration, so a Dockerfile-only review can never be a clean
bill of health.

---

## Step 4 — Runtime configuration

```yaml
# docker-compose.yml
services:
  app:
    image: registry.example.com/app@sha256:...   # digest, not tag
    read_only: true
    tmpfs:
      - /tmp:rw,noexec,nosuid,size=64m
    security_opt:
      - no-new-privileges:true
    cap_drop: ["ALL"]
    user: "10001:10001"
    pids_limit: 256
    deploy:
      resources:
        limits: { cpus: "1.0", memory: 512M }
    healthcheck:
      test: ["CMD-SHELL", "wget --spider --quiet http://127.0.0.1:8080/health || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3
    logging:
      driver: json-file
      options: { max-size: "10m", max-file: "3" }
```

Note `CMD-SHELL` in the compose healthcheck — the same exec-form trap as in 2.8.

For Kubernetes, the `securityContext` block in 2.6 is the minimum, plus a default-deny
`NetworkPolicy` and, where the cluster enforces it, the `restricted` Pod Security Standard.

---

## Step 5 — Podman and Buildah

Containerfile syntax is identical. The differences are operational and mostly in your favour:

- **Podman is rootless by default** — a genuine isolation boundary the daemon model does not
  give you. Do not disable it without a written reason.
- **Buildah builds without a daemon**, removing the build daemon from the attack surface.
- `podman build` / `buildah bud` accept the same file; `podman generate kube` will emit a
  manifest you can then harden with the `securityContext` above.

---

## References

- `references/templates.md` — complete secure Dockerfiles for Python, Node.js, Java, Go, .NET
- `references/security-checklist.md` — the validation checklist with severities and CIS anchors
- CIS Docker Benchmark · <https://www.cisecurity.org/benchmark/docker>
- NIST SP 800-190 · <https://csrc.nist.gov/pubs/sp/800/190/final>
- OWASP Docker Security Cheat Sheet · <https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html>
- Kubernetes Pod Security Standards · <https://kubernetes.io/docs/concepts/security/pod-security-standards/>
- Sigstore / cosign · <https://docs.sigstore.dev/>
