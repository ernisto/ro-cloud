## Overview

`ro-cloud` is a [pesde](https://pesde.dev) package providing a Luau library for the [Roblox Open Cloud API](https://create.roblox.com/docs/cloud/open-cloud). The library (`lib/`) is **runtime agnostic**: it never requires `@lune/*` (or any runtime module), it only describes apis and builds requests. [Lune](https://lune-org.github.io/docs) is used only by `utils/`, `cli/` and `tests/`.

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

- `lib/` — the published, runtime agnostic library (entry point: `lib/init.luau`). Must not require `@lune/*`, `@utils` or anything runtime specific.
  - `lib/web/` — generic web plumbing, not tied to any resource:
    - `lib/web/init.luau` (`web`) — the `endpoint<>` type, `web.endpoint {}` constructor, `auth`/`request` types, `build` (url templating from `path`, query encoding, auth headers, json / multipart body encoding) and `with_update_mask`
    - `lib/web/json.luau` — minimal json encoder (decoding is left to the runtime)
    - `lib/web/form.luau` — multipart form builder
  - `lib/auth/` — session builder (`auth.new:api_key(key):cookie(cookie)`), `auth.api_key` (`introspect` api + pure `has_scope` / `usable`), `auth.cookie` (`get_info` api)
  - One file per resource: `universe`, `universe_secret`, `universe_media`, `universe_configuration`, `place`, `place_configuration`, `asset`, `data_store`, `memory_store`, `user`, `user_restriction`, `group`, `developer_product`, `game_pass`, `luau_task_exec`, `develop`
- `utils/` — Lune helpers not part of the public API (`fetch.luau` sends lib requests, `cli.luau`, `bytes.luau`, `env.luau`)
- `cli/` — standalone Lune scripts that use the library
- `docs/examples/` — runnable example scripts

### Patterns

Every endpoint is a `web.endpoint {}` of type `endpoint<Path, Query, Body, Response, ErrResponse = error>` (`lib/web/init.luau`):

```luau
local WRITE: web.auth_spec = { apikey = { scope = { ['universe:write'] = true } }, cookie = {} }

local UNIVERSE = table.freeze { universe_id = 0 }
type universe_path = typeof(UNIVERSE)

return table.freeze {
	update = web.endpoint {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}', -- url template, filled from `path`
		method = 'PATCH',
		auth = WRITE, -- accepted credentials (always an alias)
		ratelimit = { apikey = 100 }, -- requests per minute, per api key owner
		path = UNIVERSE, -- sample of the `{name}` segments
		query = { allowMissing = false :: boolean? }, -- sample of the url query string, when any
		content_type = 'application/json', -- only when there's a body
		request = web.with_update_mask, -- optional, defaults to `build(self, auth, { path, body, query })`
	} :: endpoint<universe_path, { allowMissing: boolean? }, universe_patch, universe_data>,
}
```

- `auth` values are always module-level `UPPER_CASE` aliases (`local READ: web.auth_spec = ...`, or `scoped '...'` helpers), never inline tables.
- Defs live inside the module's returned table, built with `web.endpoint {}` and typed with a `:: endpoint<...>` cast (`web.endpoint` returns `any`).
- `path` / `query` are sample values (shared ones as frozen `UPPER_CASE` tables with `type x = typeof(X)`); optional fields use `0 :: number?`. Endpoints with neither set `path = nil` (generic inference needs one of them).
- `def:request(auth, path?, body?, query?)` returns `{ url, method, headers, body }` (`body` is always a `buffer?`; `json.encode` and form bodies produce buffers). Path keys only fill the url, query keys only go to the query string.
- Json endpoints without a body send `{}`; table bodies on `multipart/form-data` endpoints are form-encoded by `build`.
- Custom `request` only for extra logic: `web.with_update_mask` (PATCH `updateMask`), optional path segments (data store `scope_id`, user restriction `place_id`, task `version`) pass `base` to `build`.
- `body` / `responses` are type-only fields (never set at runtime).
- Body types are flat tables, not intersections (luau can't check literals against an optional intersection).
- Scopes and ratelimits come from Roblox's OpenAPI spec (`x-roblox-scopes`, `x-roblox-rate-limits`) at https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/cloud/openapi.json — don't guess them; omit `ratelimit` when unknown.
- Each module returns a frozen table of endpoints.
- Generic inference of `Response` through the type-only fields needs the new type solver (`LuauSolverV2`).

`auth` is a session: `cloud.auth.new:api_key(key):cookie(cookie)` (`{ api_key_state?, cookie_state? }`).

Sending requests (Lune): `fetch(cloud.universe.get, cloud.auth.new:api_key(key), { universe_id = 1 }, body?, query?)` from `utils/fetch.luau` returns `{ ok, code, message, body }` and handles the cookie CSRF retry.

Type check: `luau-lsp analyze --platform=standard --flag:LuauSolverV2=true lib/*.luau lib/auth/*.luau lib/web/*.luau`

### Type aliases

`.luaurc` defines aliases used throughout:
- `@lune/*` — Lune standard library (never in `lib/`)
- `@lib` → `./lib`
- `@utils` → `./utils`
- `@pkg` → `./lune_packages`
- `@self` — resolves within the current package (pesde convention)

## Integration Tests

```bash
lune run tests/run.luau
```

Credentials come from `.env` (TOML format) or environment variables (`API_KEY`, `COOKIE`; cookie falls back to the local Roblox Studio cookie). Resource ids live in `tests/config.luau`. `tests/suite/api.spec.luau` checks request building offline; the rest hit the live api and only perform read operations — no data is modified.

## Project Index

`.claude/index.md` contains a detailed index of every module, its identity type, exported functions, and API endpoint map. Always read it at the start of a session and keep it updated whenever modules are added, removed, or their exports change.

### Luau style (from `stylua.toml`)

- Single quotes preferred (`AutoPreferSingle`)
- No call parentheses where optional (`call_parentheses = 'None'`)
- `if`/`then` on same line for simple statements (`collapse_simple_statement = 'ConditionalOnly'`)
- `sort_requires` enabled — keep requires sorted
- Strict type mode (`.luaurc`: `"languageMode": "strict"`)
