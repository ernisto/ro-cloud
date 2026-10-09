# Project Index

`lib/` is runtime agnostic: every endpoint is a `web.endpoint { ... }` cast to `endpoint<Path, Query, Body, Response, ErrResponse = error>` inside its module's returned table. `path` / `query` fields are sample values (typing the `request` args); `def:request(auth, path?, body?, query?)` returns `{ url, method, headers, body: buffer? }`. Sending happens outside lib (`tests/fetch.luau` for lute). No runtime modules in `lib/`.

## lib/ (core)

| File | Purpose |
|------|---------|
| `lib/web/init.luau` | Module `web`. Types: `endpoint<P, Q, B, R, E = error>`, `definition<P, Q>`, `auth` (session: `{ api_key_state: { key }?, cookie_state: { cookie, csrf_token? }? }`), `auth_spec`, `ratelimit` (per minute), `request`, `error`, `method`. Functions: `endpoint(def)` — fills the default `request` (`build(self, auth, { path, body, query })`), freezes, returns `any`; `build(def, auth, { path?, query?, body?, content_type?, base? })` — fills `{name}` url templates from `path`, encodes + sorts `query`, picks the first credential the def accepts (api key → `x-api-key`, then cookie → `Cookie` + `X-CSRF-TOKEN`), sends `{}` for bodyless json endpoints, form-encodes table bodies on multipart endpoints, json-encodes other table bodies; `with_update_mask` (PATCH `request` adding `updateMask`); `encode` (url percent-encoding); `mask_from` (sorted `updateMask`). |
| `lib/web/json.luau` | `encode(value) -> buffer` — minimal json encoder (no decoder; runtime decodes responses). |
| `lib/web/form.luau` | Multipart form builder (vendored). `builder()`, `by_table(fields) -> (body: buffer, content_type)`; buffers become `icon.png` file parts. |
| `lib/auth/init.luau` | `new` session builder: `new:api_key(key)`, `new:cookie(cookie)` (each returns a cloned session). Also `api_key`, `cookie` submodules. Types `session` (= `web.auth`), `api_key_introspection`. |
| `lib/auth/api_key.luau` | `introspect` api (`POST api-keys/v1/introspect`); pure `usable(info)`, `has_scope(info, 'name:operation', target?)`. Types: `scope`, `introspection`. |
| `lib/auth/cookie.luau` | `get_info` api (= `user.get_authenticated`). |
| `lib/init.luau` | Re-exports every module (`web`, `auth`, `json`, `form`, resources; `product` = developer_product, `pass` = game_pass) and common types (`api`, `auth`, `request`, `error`, …). |

## lib/ (resources)

Listed as `name(path) body → query`: `path` keys fill the url, `body` is the request body, `query` keys go to the url query string. `?` = optional.

| File | Apis |
|------|------|
| `lib/universe.luau` | `create() create_params` (cookie, `groupId` copied to the query), `get(universe_id)`, `update(universe_id) patch` (updateMask), `publish_message(universe_id) message`, `shutdown(universe_id)` |
| `lib/universe_secret.luau` | `get_public_key(universe_id)`, `list(universe_id) → limit?, cursor?`, `create(universe_id) data`, `delete(universe_id, secret_id)`, `update(universe_id, secret_id) data` |
| `lib/universe_media.luau` | cookie-only legacy web apis: `upload_icon(universe_id) image`, `remove_icon() { placeId, placeIconId }`, `upload_thumbnail(universe_id) image`, `list_thumbnails(universe_id)`, `set_thumbnail_order(universe_id) { thumbnailIds }`, `delete_thumbnail(universe_id, thumbnail_id)` |
| `lib/universe_configuration.luau` | cookie: `get(universe_id)` (develop v1), `update(universe_id) patch` (develop v2) |
| `lib/place.luau` | `create(universe_id) params` (cookie), `upload(universe_id, place_id) file → versionType`, `get_info(universe_id, place_id)`, `update_info(universe_id, place_id) patch`, `get_instance(universe_id, place_id, instance_id)`, `update_instance(…, instance_id) data`, `list_instance_children(…, instance_id) → page` |
| `lib/place_configuration.luau` | cookie: `get(place_id)`, `update(place_id) patch` |
| `lib/asset.luau` | `download(asset_id) → version?` → `{ location }` (fetch the location separately), `create() { content, asset }`, `update(asset_id) { content?, asset }`, `get(asset_id) → readMask?`, `archive(asset_id)`, `restore(asset_id)`, `rollback(asset_id, version)`, `get_version(asset_id, version)`, `list_versions(asset_id) → page`, `get_operation(operation_id)` |
| `lib/data_store.luau` | `snapshot(universe_id)`, `list_stores(universe_id) → page`, `delete_store` / `undelete_store(universe_id, data_store_id)`; entries take `(universe_id, data_store_id, scope_id?, …)`: `list_entries → page`, `create_entry data → id?`, `get_entry` / `delete_entry(…, entry_id)`, `update_entry(…, entry_id) data → allowMissing?`, `increment_entry(…, entry_id) increment`, `list_entry_revisions(…, entry_id) → page`; ordered take `(universe_id, ordered_data_store_id, scope_id, …)`: `list_ordered_entries → page`, `create_ordered_entry { value } → id`, `get_ordered_entry(…, entry_id)`, `update_ordered_entry(…, entry_id) { value } → allowMissing?`, `delete_ordered_entry(…, entry_id)`, `increment_ordered_entry(…, entry_id) { amount }` |
| `lib/memory_store.luau` | `enqueue(universe_id, queue_id) item`, `read_queue(universe_id, queue_id) → count?, …`, `discard_queue(universe_id, queue_id) { readId }`, `list_sorted_map(universe_id, sorted_map_id) → page`, `get_sorted_map_item` / `delete_sorted_map_item(…, item_id)`, `set_sorted_map_item(…) item → id?`, `update_sorted_map_item(…, item_id) item → allowMissing?`, `flush(universe_id)` |
| `lib/user.luau` | `get(user_id)`, `get_authenticated()` (cookie, `users.roblox.com`), `list_inventory(user_id) → page`, `send_notification(user_id) notification`, `get_subscription(universe_id, subscription_product_id, subscription_id) → view?` |
| `lib/user_restriction.luau` | `(universe_id, place_id?, …)`: `list → page`, `get(…, user_restriction_id)`, `update(…, user_restriction_id) data → idempotencyKey.key?` (updateMask); `list_logs(universe_id) → page` |
| `lib/group.luau` | `get(group_id)`, `get_shout(group_id)`, `list_roles(group_id) → page`, `get_role(group_id, role_id)`, `list_memberships(group_id) → page`, `update_membership(group_id, membership_id) data`, `list_join_requests(group_id) → page`, `accept_join_request` / `decline_join_request(group_id, join_request_id)` |
| `lib/developer_product.luau` | api key or cookie: `create(universe_id) data`, `update(universe_id, product_id) data`, `get(universe_id, product_id)`, `list(universe_id) → page` — multipart bodies |
| `lib/game_pass.luau` | api key or cookie: `create(universe_id) data`, `update(universe_id, pass_id) data`, `get(universe_id, pass_id)`, `list(universe_id) → page` — multipart bodies |
| `lib/luau_task_exec.luau` | `create(universe_id, place_id, version?) task_input`, `get(path)`, `list_logs(path) → page, view?` (`path` = `task.path`) |
| `lib/develop.luau` | cookie, `develop.roblox.com`: `get_user_universes() → page`, `get_group_universes(group_id) → page`, `get_groups()`, `list_universe_places(universe_id) → page` |

## tests/

| File | Purpose |
|------|---------|
| `tests/config.luau` | `auth()` lazy session (`.env` / env `API_KEY`, `COOKIE` or local Studio cookie on Windows) and fixed resource ids. |
| `tests/fetch.luau` | `fetch(def, auth, path?, body?, query?)` → `http_result<R, E>` (`{ ok, code, message, body }`): sends via `@std/net`, retries once with the CSRF token on cookie 403 (caching it in `auth.cookie_state.csrf_token`), json-decodes the body, surfaces `errors[1]`. `send(request)`. |
| `tests/suite/api.spec.luau` | Offline: url/query/header building, path vs query split, optional path segments, credential selection, empty json / multipart bodies, json encoding. |
| `tests/suite/*.spec.luau` | `@std/test` suites run by `lute test`. Live read-only checks per resource (`auth`, `universe`, `place`, `data_store`, `memory_store`, `user_restriction`, `game_pass`, `developer_product`, `user`, `group`, `asset`, `develop`). |

## Scopes / ratelimits source

Roblox OpenAPI spec: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/cloud/openapi.json (`x-roblox-scopes`, `x-roblox-rate-limits.perApiKeyOwner`).
