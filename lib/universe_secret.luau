local auth = require '@lib/auth'
local universe = require '@lib/universe'

-- defs
export type secret = {
	id: string?,
	secret: string?,
	key_id: string?,
	domain: string?,
	create_time: string?,
	update_time: string?,
}

export type secret_create = { id: string, secret: string, key_id: string, domain: string }
export type secret_patch = { secret: string? }
export type public_key = { key_id: string?, public_key: string? }

type secrets_page = { nextPageCursor: 'n' | string, previousPageCursor: 'p' | string, secrets: { secret } }

-- functions
local function get_public_key(session: auth.apikey_session | auth.oauth2_session, subject: universe.identity)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/secrets/public-key`
	return auth.request_json(session, 'GET', url) :: auth.http_result<public_key>
end

local function list_secrets(session: auth.apikey_session | auth.oauth2_session, subject: universe.identity)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/secrets`
	return auth.request_json(session, 'GET', url) :: auth.http_result<secrets_page>
end

local function create_secret(
	session: auth.apikey_session | auth.oauth2_session,
	subject: universe.identity,
	data: secret_create
)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/secrets`
	return auth.request_json(session, 'POST', url, nil, data) :: auth.http_result<secret>
end

local function delete_secret(
	session: auth.apikey_session | auth.oauth2_session,
	subject: universe.identity,
	secret_id: string
)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/secrets/{secret_id}`
	return auth.request_json(session, 'DELETE', url) :: auth.http_result<nil>
end

local function update_secret(
	session: auth.apikey_session | auth.oauth2_session,
	subject: universe.identity,
	secret_id: string,
	data: secret_patch
)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/secrets/{secret_id}`
	return auth.request_json(session, 'PATCH', url, nil, data) :: auth.http_result<secret>
end

-- module
return table.freeze {
	get_public_key = get_public_key,
	create = create_secret,
	delete = delete_secret,
	update = update_secret,
	list = list_secrets,
}
