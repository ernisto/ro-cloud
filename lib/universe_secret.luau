local web = require './web'

-- defs
export type secret_data = {
	id: string?,
	secret: string?,
	key_id: string?,
	domain: string?,
	create_time: string?,
	update_time: string?,
}

export type secret_creation = { id: string, secret: string, key_id: string, domain: string }
export type secret_patch = { secret: string? }
export type public_key = { key_id: string?, public_key: string? }

export type secrets_page = { nextPageCursor: 'n' | string, previousPageCursor: 'p' | string, secrets: { secret_data } }

local UNIVERSE = table.freeze { universe_id = 0 }
local SECRET = table.freeze { universe_id = 0, secret_id = '' }
local PAGE = table.freeze { limit = 0 :: number?, cursor = '' :: string? }
type universe_path = typeof(UNIVERSE)
type secret_path = typeof(SECRET)
export type page_query = typeof(PAGE)

local READ: web.auth_spec = { apikey = { scope = { ['universe.secret:read'] = true } } }
local WRITE: web.auth_spec = { apikey = { scope = { ['universe.secret:write'] = true } } }
local RATELIMIT: web.ratelimit = { apikey = 120 }

local SECRETS = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/secrets'

-- module
return table.freeze {
	get_public_key = web.endpoint<<universe_path, nil, nil, public_key>> {
		base = `{SECRETS}/public-key`,
		method = 'GET',
		auth = READ,
		ratelimit = RATELIMIT,
		path = UNIVERSE,
	},

	list = web.endpoint<<universe_path, page_query, nil, secrets_page>> {
		base = SECRETS,
		method = 'GET',
		auth = READ,
		ratelimit = RATELIMIT,
		path = UNIVERSE,
		query = PAGE,
	},

	create = web.endpoint<<universe_path, nil, secret_creation, secret_data>> {
		base = SECRETS,
		method = 'POST',
		auth = WRITE,
		ratelimit = RATELIMIT,
		path = UNIVERSE,
		content_type = 'application/json',
	},

	delete = web.endpoint<<secret_path, nil, nil, nil>> {
		base = `{SECRETS}/\{secret_id}`,
		method = 'DELETE',
		auth = WRITE,
		ratelimit = RATELIMIT,
		path = SECRET,
	},

	update = web.endpoint<<secret_path, nil, secret_patch, secret_data>> {
		base = `{SECRETS}/\{secret_id}`,
		method = 'PATCH',
		auth = WRITE,
		ratelimit = RATELIMIT,
		path = SECRET,
		content_type = 'application/json',
	},
}
