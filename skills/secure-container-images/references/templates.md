# Secure Container Image Templates

Complete templates per stack, implementing the controls in `SKILL.md`.

Three things every template below leaves to you, because they cannot be hard-coded:

1. **Pin the digest.** The `@sha256:…` placeholder is not decoration — resolve it and commit it
   for anything above I1.
2. **Bump the versions.** The versions here are illustrative. Use the current patch release of
   the runtime you are on.
3. **Apply the runtime flags.** Read-only root filesystem, dropped capabilities and
   `no-new-privileges` are *runtime* settings. A perfect Dockerfile run without them is not
   hardened. The run command is included with each template for that reason.

---

## Python

```dockerfile
# syntax=docker/dockerfile:1
# ---------- build ----------
FROM python:3.12.11-slim-bookworm@sha256:REPLACE_ME AS builder

WORKDIR /build

# Build deps only in this stage; they never reach the runtime image
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends build-essential libffi-dev; \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY src/ ./src/

# ---------- runtime ----------
FROM python:3.12.11-slim-bookworm@sha256:REPLACE_ME

LABEL org.opencontainers.image.source="https://github.com/org/repo" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.version="${APP_VERSION}"

# Patch the base, then drop the package lists
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    groupadd -g 10001 -r app; \
    useradd  -u 10001 -r -g app -d /app -s /usr/sbin/nologin app

ENV LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

COPY --from=builder /install /usr/local
WORKDIR /app
COPY --from=builder --chown=10001:10001 /build/src ./src

USER 10001:10001
EXPOSE 8080

# Shell form: `|| exit 1` is shell syntax and is ignored in exec form
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=3).status==200 else 1)" || exit 1

CMD ["python", "-m", "src.main"]
```

```bash
docker run --read-only --tmpfs /tmp:rw,noexec,nosuid,size=64m \
  --cap-drop=ALL --security-opt=no-new-privileges:true \
  --pids-limit=256 --memory=512m --cpus=1.0 \
  -p 8080:8080 myapp@sha256:...
```

> Alpine (`python:3.12-alpine`) produces a smaller image but uses musl, which breaks some
> compiled wheels and changes DNS resolution behaviour. Use slim unless you have measured that
> Alpine works for your dependency set.

---

## Node.js

```dockerfile
# syntax=docker/dockerfile:1
# ---------- build ----------
FROM node:22.11.0-bookworm-slim@sha256:REPLACE_ME AS builder

WORKDIR /build
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

COPY . .
RUN npm run build && npm prune --omit=dev

# ---------- runtime ----------
FROM node:22.11.0-bookworm-slim@sha256:REPLACE_ME

LABEL org.opencontainers.image.source="https://github.com/org/repo" \
      org.opencontainers.image.revision="${GIT_COMMIT}"

RUN set -eux; \
    apt-get update; apt-get upgrade -y --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production LANG=C.UTF-8
WORKDIR /app

# The official node images ship a `node` user at UID 1000; create a high-UID one instead
RUN set -eux; \
    groupadd -g 10001 -r app; \
    useradd  -u 10001 -r -g app -d /app -s /usr/sbin/nologin app

COPY --from=builder --chown=10001:10001 /build/node_modules ./node_modules
COPY --from=builder --chown=10001:10001 /build/dist         ./dist
COPY --from=builder --chown=10001:10001 /build/package.json ./

USER 10001:10001
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:3000/health',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))" || exit 1

CMD ["node", "dist/index.js"]
```

`--ignore-scripts` on `npm ci` blocks arbitrary code execution from a dependency's install
hooks, which is one of the more common supply-chain vectors. If a dependency genuinely needs its
postinstall script, run it explicitly for that package and say why in a comment.

---

## Java

```dockerfile
# syntax=docker/dockerfile:1
# ---------- build ----------
FROM eclipse-temurin:21.0.5_11-jdk-jammy@sha256:REPLACE_ME AS builder

WORKDIR /build
COPY . .
RUN ./mvnw -B -DskipTests package

# Minimal runtime containing only the modules the app needs
RUN set -eux; \
    jlink --add-modules "$(jdeps --ignore-missing-deps --print-module-deps --multi-release 21 target/app.jar)" \
          --strip-debug --no-man-pages --no-header-files --compress=zip-6 \
          --output /javaruntime

# ---------- runtime ----------
FROM debian:bookworm-slim@sha256:REPLACE_ME

LABEL org.opencontainers.image.source="https://github.com/org/repo" \
      org.opencontainers.image.revision="${GIT_COMMIT}"

RUN set -eux; \
    apt-get update; apt-get upgrade -y --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    groupadd -g 10001 -r app; \
    useradd  -u 10001 -r -g app -d /app -s /usr/sbin/nologin app

COPY --from=builder /javaruntime /opt/java
ENV JAVA_HOME=/opt/java PATH="/opt/java/bin:${PATH}" LANG=C.UTF-8

WORKDIR /app
COPY --from=builder --chown=10001:10001 /build/target/app.jar ./app.jar

USER 10001:10001
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD java -version >/dev/null 2>&1 || exit 1

ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-XX:+ExitOnOutOfMemoryError", \
  "-jar", "app.jar"]
```

The `HEALTHCHECK` above only proves the JVM starts. Prefer the orchestrator's HTTP readiness
probe against `/actuator/health` — a health check that cannot fail is worse than none, because
it reports green while the application is down.

---

## Go — distroless

```dockerfile
# syntax=docker/dockerfile:1
# ---------- build ----------
FROM golang:1.23.4-bookworm@sha256:REPLACE_ME AS builder

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build \
      -trimpath -ldflags="-s -w" -o /app ./cmd/server

# ---------- runtime ----------
FROM gcr.io/distroless/static-debian12:nonroot@sha256:REPLACE_ME

LABEL org.opencontainers.image.source="https://github.com/org/repo" \
      org.opencontainers.image.revision="${GIT_COMMIT}"

COPY --from=builder /app /app
USER 65532:65532          # distroless `nonroot`
EXPOSE 8080

# No shell in distroless — the binary implements its own health subcommand
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD ["/app", "healthcheck"]

ENTRYPOINT ["/app"]
```

`-trimpath` removes local filesystem paths from the binary — a small information-disclosure fix
that also improves reproducibility.

**`scratch` vs `distroless/static`:** `scratch` is empty, so you must copy CA certificates and
timezone data yourself or every TLS call fails with an opaque error. `distroless/static` adds
~2 MB and includes both. Use distroless unless you have a specific reason.

---

## .NET

```dockerfile
# syntax=docker/dockerfile:1
# ---------- build ----------
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim@sha256:REPLACE_ME AS builder

WORKDIR /build
COPY *.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /publish --no-restore

# ---------- runtime ----------
FROM mcr.microsoft.com/dotnet/runtime:8.0-bookworm-slim@sha256:REPLACE_ME

LABEL org.opencontainers.image.source="https://github.com/org/repo" \
      org.opencontainers.image.revision="${GIT_COMMIT}"

RUN set -eux; \
    apt-get update; apt-get upgrade -y --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    groupadd -g 10001 -r app; \
    useradd  -u 10001 -r -g app -d /app -s /usr/sbin/nologin app

ENV DOTNET_RUNNING_IN_CONTAINER=true \
    ASPNETCORE_URLS=http://+:8080 \
    LANG=C.UTF-8

WORKDIR /app
COPY --from=builder --chown=10001:10001 /publish ./

USER 10001:10001
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8080/health || exit 1

ENTRYPOINT ["dotnet", "MyApp.dll"]
```

`DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true` shrinks the image but changes string comparison,
date parsing and sorting behaviour. Set it only if you have verified the application does not
depend on culture-aware operations.

---

## `.dockerignore` — every project

```
.git/
.github/
.gitlab-ci.yml
.vscode/
.idea/
**/.env
**/.env.*
**/*.pem
**/*.key
**/*.crt
**/*.p12
**/credentials.*
**/secrets.*
**/id_rsa*
node_modules/
__pycache__/
*.pyc
.venv/
venv/
target/
bin/
obj/
.pytest_cache/
.coverage
coverage/
*.log
*.tmp
Dockerfile*
docker-compose*.yml
README.md
docs/
.DS_Store
Thumbs.db
```

`.git/` is first for a reason: copying it into an image ships every secret that was ever
committed and later removed.

---

## Build and verify

```bash
# Build with SBOM and provenance attestations
docker buildx build \
  --sbom=true --provenance=true \
  --secret id=npm_token,env=NPM_TOKEN \
  -t registry.example.com/app:${VERSION} --push .

# Scan, gating on exit code
trivy image --exit-code 1 --severity HIGH,CRITICAL registry.example.com/app:${VERSION}

# Sign, and verify what you signed
cosign sign registry.example.com/app:${VERSION}
cosign verify --certificate-identity-regexp '.*' --certificate-oidc-issuer-regexp '.*' \
  registry.example.com/app:${VERSION}

# Assert the image does not default to root
test "$(docker inspect --format '{{.Config.User}}' registry.example.com/app:${VERSION})" != ""
```

Replace the two `--certificate-*-regexp '.*'` values with the actual workflow identity and
issuer before this goes anywhere near a pipeline. A verification that accepts any signer accepts
an attacker's signature.
