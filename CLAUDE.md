# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`ro-cloud` is a [pesde](https://pesde.dev) package providing a Luau library for the [Roblox Open Cloud API](https://create.roblox.com/docs/cloud/open-cloud). It runs in the [Lune](https://lune-org.github.io/docs) runtime (a Luau scripting environment).

## Toolchain

Managed via **Rokit** (`aftman.toml`):
- `lune` — runtime for executing `.luau` scripts
- `stylua` — code formatter
- `luau-lsp` — language server

Install tools: `rokit install`
Install dependencies: `pesde install`

## Common Commands

```bash
# Run a script
lune run <script_path>

# Run a CLI script (example)
lune run cli/download_place.luau -- <place_id> --output out.rbxl --api-key <key>

# Format code
stylua .

# Check formatting without writing
stylua --check .
```

## Code Architecture

### Module structure

- `lib/` — the published library (entry point: `lib/init.luau`)
  - `lib/auth/` — authentication layer: `apikey`, `cookie`, `oauth` (PKCE flow). `lib/auth/init.luau` dispatches `request_json` / `request_form` to the right auth backend based on session type.
  - One file per resource: `universe`, `place`, `asset`, `data_store`, `memory_store`, `user`, `user_restriction`, `group`, `developer_product`, `game_pass`, `luau_task_exec`, `luau_task_exec_log`, `operation`
- `utils/` — shared helpers not part of the public API (`cli.luau`, `bytes.luau`, `env.luau`)
- `cli/` — standalone Lune scripts that use the library
- `docs/examples/` — runnable example scripts

### Patterns

Every resource module follows the same shape:
1. `export type identity` — minimal selector (e.g. `{ universe_id: number }`)
2. `export type <resource>_data` — full response type
3. Pure functions that each take `(session, identity, ...)` and call `auth.request_json` or `auth.request_form`
4. Returned as a frozen table

`auth.request_json(session, path, method, data?, query?)` is the single HTTP entry point. `path` is relative to `https://apis.roblox.com/`.

### Type aliases

`.luaurc` defines aliases used throughout:
- `@lune/*` — Lune standard library
- `@lib` → `./lib`
- `@utils` → `./utils`
- `@pkg` → `./lune_packages`
- `@self` — resolves within the current package (pesde convention)

## Integration Tests

```bash
lune run tests/run.luau
```

All vars can also be set in `.env` (TOML format) or as environment variables (`API_KEY`, `UNIVERSE_ID`, `PLACE_ID`, …). Tests that are missing their required IDs are automatically skipped. Tests only perform read operations — no data is modified.

## Project Index

`.claude/index.md` contains a detailed index of every module, its identity type, exported functions, and API endpoint map. Always read it at the start of a session and keep it updated whenever modules are added, removed, or their exports change.

### Luau style (from `stylua.toml`)

- Single quotes preferred (`AutoPreferSingle`)
- No call parentheses where optional (`call_parentheses = 'None'`)
- `if`/`then` on same line for simple statements (`collapse_simple_statement = 'ConditionalOnly'`)
- `sort_requires` enabled — keep requires sorted
- Strict type mode (`.luaurc`: `"languageMode": "strict"`)
