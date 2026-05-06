# pi-alpine

Alpine‑based Docker wrapper for [Pi coding agent](https://pi.dev) with pre‑installed CLI tools and a set of default runtime extensions.

## Quick Start

Build:
```bash
docker build --build-arg PI_VERSION=0.72.0 -t pi-alpine:latest .
```

Run (maps host `~/.pi` config and extensions to `/home/node/.pi`):
```bash
docker run -it --rm -v ~/.pi:/home/node/.pi -v $(pwd):/work pi-alpine:latest
```

## Base Image

`node:22-alpine` (Node.js 22 LTS, Alpine Linux, meets Pi's `>=20` requirement)

## Included Tools

### Core
- `pi` – Pi coding agent (pinned via `PI_VERSION`; default 0.72.0)
- `git` – Version control
- `uv` – Python package manager (from Alpine edge/community)
- `ripgrep` (`rg`), `fd` – Fast file search
- `python3`, `jq`, `curl`, `ca-certificates`
- `build-base`, `openssh-client` – Build tools & SSH
- ...

### Optional (for `pi-hashline-readmap` and extended workflows)
- `ast-grep` – Structural code search (powers `ast_search` tool)
- `nushell` – Structured shell (powers `nu` tool)
- `difftastic` – Semantic diffs for edit summaries
- `shellcheck` – Shell script linting
- `yq` – YAML/XML/JSON processor
- `scc` – Code complexity analysis

## Default Extensions

Extensions are installed at container runtime (if not already present in `/home/node/.pi`):
- `pi-hashline-readmap` – Hash‑anchored editing, structural file maps, symbol‑aware navigation
- `pi-extmgr` – Extension manager
- `npm:@juicesharp/rpiv-btw` – RPIV BTW extension
- `npm:@heart-of-gold/toolkit` – Toolkit extension

## Customization

Override Pi version at build time:
```bash
docker build --build-arg PI_VERSION=0.72.0 -t pi-alpine:latest .
```

Override default extensions at build time:
```bash
docker build --build-arg EXTENSIONS="npm:my-ext npm:awesome-ext" -t pi-alpine:latest .
```

Or at runtime:
```bash
docker run -e EXTENSIONS="npm:my-ext" -v ~/.pi:/home/node/.pi -v $(pwd):/work pi-alpine:latest
```

To skip extension installation entirely, set `EXTENSIONS` to an empty string. Please note that extensions previuosly installed still might be visible.

## Notes

- Extensions are installed at container runtime into `/home/node/.pi` (or host's `~/.pi` if mounted).
- To persist extensions across runs, mount host `~/.pi` with `-v ~/.pi:/home/node/.pi`.
- Edge/community repo is used temporarily to install `uv` and other tools not in stable Alpine repos.
- Uses `node` user (UID/GID 1000) from base image.

## Next Steps

- Add `docker-compose.yml` for easier volume / env management.
- Add support for host SSH keys via volume mount.
