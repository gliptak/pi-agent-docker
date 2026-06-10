# pi-ubuntu
Debian 12 Bookworm based Docker wrapper for [Pi coding agent](https://pi.dev) with pre-installed CLI tools and a set of default runtime extensions.

Debian base means tools like `@ast-grep/cli` and other npm binaries work out of the box.

## Quick Start

Build:
```bash
docker build --build-arg PI_VERSION=0.75.5 -t pi-agent:latest .
```

Run (maps host `~/.pi` config and extensions to `/home/node/.pi`):
```bash
docker run -it --rm -v ~/.pi:/home/node/.pi -v $(pwd):/work pi-agent:latest
```

## Base Image

[`node:22-bookworm-slim`](Dockerfile#L4) (Debian 12 Bookworm, Node.js 22 LTS)

## Included Tools

### Core
- `pi` — Pi coding agent (pinned via `PI_VERSION`)
- `git` — Version control
- `uv` — Python package manager (via pip)
- `ripgrep` (`rg`), `fd` — Fast file search
- `python3`, `jq`, `curl`, `ca-certificates`
- `build-essential`, `openssh-client`, `sudo` — Build tools, SSH & privilege elevation

### Structural code search
- [`@ast-grep/cli`](Dockerfile#L66) — Structural code search via npm

### Structured shell
- [`nu`](Dockerfile#L42) — Nushell structured shell, powers the `nu` tool (prebuilt binary)

### Extended workflows
- [`difftastic`](Dockerfile#L42) - Semantic diffs for edit summaries
- [`shellcheck`](Dockerfile#L22) — Shell script linting
- [`yq`](Dockerfile#L35) — YAML/XML/JSON processor
- [`scc`](Dockerfile#L42) — Code complexity analysis

## Default Extensions

Extensions are installed at container runtime (if not already present in `/home/node/.pi`):
- `pi-hashline-readmap` — Hash-anchored editing, structural file maps, symbol-aware navigation
- `pi-extmgr` — Extension manager
- `pi-btw` — BTW extension
- `npm:@heart-of-gold/toolkit` — Toolkit extension

## Customization

Override Pi version at build time:
```bash
docker build --build-arg PI_VERSION=0.75.5 -t pi-agent:latest .
```

Override default extensions at build time:
```bash
docker build --build-arg EXTENSIONS="npm:my-ext npm:awesome-ext" -t pi-agent:latest .
```

Or at runtime:
```bash
docker run -e EXTENSIONS="npm:my-ext" -v ~/.pi:/home/node/.pi -v $(pwd):/work pi-agent:latest
```

To skip extension installation entirely, set `EXTENSIONS` to an empty string. Please note that extensions previously installed still might be visible.

## Notes

- Extensions are installed at container runtime into `/home/node/.pi` (or host's `~/.pi` if mounted).
- To persist extensions across runs, mount host `~/.pi` with `-v ~/.pi:/home/node/.pi`.
- `node` user (UID/GID 1000) from the base image has passwordless `sudo`.
- Based on `node:22-bookworm-slim` (Debian 12 Bookworm). Tools like `@ast-grep/cli` install from npm without issue.
- Tools not in Debian repos (nushell, difftastic, scc, yq) are downloaded as prebuilt binaries from GitHub releases.
- `uv` is installed via pip.

## Next Steps

- Add `docker-compose.yml` for easier volume / env management.
- Add support for host SSH keys via volume mount.
