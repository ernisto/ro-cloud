# Project Index

## lib/auth/

| File | Purpose |
|------|---------|
| `lib/auth/init.luau` | Dispatcher: `request_json`, `request_form`, `request` — routes to the correct backend based on session type. Defines shared types: `session`, `json`, `json_object`, `query_params`. Base URL: `https://apis.roblox.com/`. |
| `lib/auth/apikey.luau` | API key session: `login(api_key) -> session`, `request(session, path, method, content_type, data)`. Injects `x-api-key` header. |
| `lib/auth/cookie.luau` | Cookie session backend. |
| `lib/auth/oauth/init.luau` | OAuth2 PKCE flow: `create_authorization_url`, `exchange_code_for_token`, `refresh_token`, `is_session_expired`, `request`. |
| `lib/auth/oauth/types.luau` | Types only: `session`, `oauth_error`. No functions. |
| `lib/auth/form.luau` | Multipart form builder (vendored). Returns a builder with `.text()`, `.file()`, `.build()`. |

## lib/ (resources)

| File | Identity type | Exported functions |
|------|---------------|--------------------|
| `lib/universe.luau` | `{ universe_id }` | `get`, `update`, `publish_message`, `shutdown`, `list_secrets`, `create_secret`, `delete_secret`, `update_secret`, `get_public_key` |
| `lib/place.luau` | `{ universe_id, place_id, version? }` | `upload`, `download`, `get_info`, `update_info`, `get_instance`, `update_instance`, `list_instance_children` |
| `lib/asset.luau` | `{ asset_id }` | `create`, `update`, `get`, `archive`, `restore`, `get_version`, `list_versions`, `rollback`, `get_operation`, `wait_for_operation` |
| `lib/data_store.luau` | `store_identity { universe_id, data_store_id, scope_id? }` / `entry_identity` | `list_stores`, `delete_store`, `undelete_store`, `snapshot`, `list_entries`, `create_entry`, `get_entry`, `update_entry`, `delete_entry`, `increment_entry`, `list_entry_revisions`, + ordered-datastore variants |
| `lib/memory_store.luau` | `queue_identity` / `sorted_map_identity` | `enqueue`, `read_queue`, `discard_queue`, `list_sorted_map`, `get_sorted_map_item`, `set_sorted_map_item`, `update_sorted_map_item`, `delete_sorted_map_item`, `flush` |
| `lib/user.luau` | `{ user_id }` | `get`, `list_inventory`, `send_notification`, `get_subscription` |
| `lib/user_restriction.luau` | `restriction_identity` / `place_restriction_identity` | `list`, `get`, `update`, `list_logs` |
| `lib/group.luau` | `{ group_id }` | `get`, `get_shout`, `list_roles`, `get_role`, `list_memberships`, `update_membership`, `list_join_requests`, `accept_join_request`, `decline_join_request` |
| `lib/developer_product.luau` | `{ universe_id, product_id }` | (see file) |
| `lib/game_pass.luau` | `{ pass_id }` | (see file) |
| `lib/luau_task_exec.luau` | `{ path }` (task path) | `create`, `get`, `wait_for_task`, `create_binary_input`, `get_task_by_path` |
| `lib/luau_task_exec_log.luau` | — | Log parsing for Luau execution task output |
| `lib/operation.luau` | — | `get_operation`, `poll_for_result` — exponential backoff poller (10 attempts, 2× delay starting at 1s) |

## utils/

| File | Purpose |
|------|---------|
| `utils/cli.luau` | CLI arg parser. Returns `str(key)`, `num(key|pos)`, `uint(key|pos)`, `bool(flag)`, `forwarded`. Supports `--key value`, `--key=value`, `-f`, `--` forwarding. |
| `utils/bytes.luau` | Byte helpers. |
| `utils/env.luau` | Environment variable helpers. |

## cli/

| File | Purpose |
|------|---------|
| `cli/download_place.luau` | Downloads a place file. Args: `<place_id>` `--output <path>` `--api-key <key>` `--cache <seconds>`. |

## docs/

| File | Purpose |
|------|---------|
| `docs/examples/oauth_flow.luau` | Full OAuth2 PKCE flow: authorize in browser → exchange code → persist session.json → auto-refresh on expiry. |

## tests/

| File | Purpose |
|------|---------|
| `tests/run.luau` | Entry point. Reads config from CLI args / env vars, runs all suites, prints summary. Exit code 1 on any failure. |
| `tests/suite/universe.luau` | Tests `get`, `list_secrets`. Requires: `api_key`, `universe_id`. |
| `tests/suite/place.luau` | Tests `get_info`, `download`. Requires: `place_id`. |
| `tests/suite/data_store.luau` | Tests `list_stores`, `list_entries`. `list_entries` requires `data_store_id`. |
| `tests/suite/memory_store.luau` | Tests `list_sorted_map` (needs `sorted_map_id`), `read_queue` (needs `queue_id`). |
| `tests/suite/user_restriction.luau` | Tests `list`, `list_logs`. Requires: `universe_id`. |
| `tests/suite/game_pass.luau` | Tests `list`, `get` (needs `pass_id`). |
| `tests/suite/developer_product.luau` | Tests `list`, `get` (needs `product_id`). |
| `tests/suite/user.luau` | Tests `get`, `list_inventory`. Requires: `user_id`. |
| `tests/suite/group.luau` | Tests `get`, `list_roles`, `list_memberships`. Requires: `group_id`. |
| `tests/suite/asset.luau` | Tests `get`, `list_versions`. Requires: `asset_id`. |

## API endpoint map

| Module | API base path |
|--------|--------------|
| `universe` | `cloud/v2/universes/{id}` |
| `place` | `cloud/v2/universes/{id}/places/{id}` (info/instances); `universes/v1/…` (upload); `assetdelivery.roblox.com` (download) |
| `asset` | `assets/v1/assets/{id}` |
| `data_store` | `cloud/v2/universes/{id}/data-stores/{id}` |
| `memory_store` | `cloud/v2/universes/{id}/memory-store/…` |
| `user` | `cloud/v2/users/{id}` |
| `user_restriction` | `cloud/v2/universes/{id}/user-restrictions/{id}` |
| `group` | `cloud/v2/groups/{id}` |
| `luau_task_exec` | `cloud/v2/universes/{id}/places/{id}/luau-execution-session-tasks` |
| `operation` | `cloud/v2/{operation_path}` |
