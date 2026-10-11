local web = require './web'

-- defs
type game_join_restriction = {
	active: boolean?,
	startTime: string?,
	duration: string?,
	privateReason: string?,
	displayReason: string?,
	excludeAltAccounts: boolean?,
}

export type restriction_data = {
	path: string?,
	updateTime: string?,
	user: string?,
	gameJoinRestriction: game_join_restriction?,
}

export type restriction_patch = { gameJoinRestriction: game_join_restriction? }

export type restriction_log_data = {
	user: string?,
	place: string?,
	moderator: { gameJoinRestrictionType: string? }?,
	createTime: string?,
	active: boolean?,
	startTime: string?,
	duration: string?,
	privateReason: string?,
	displayReason: string?,
	excludeAltAccounts: boolean?,
}

-- TODO: complete from Roblox cloud docs
export type restrictions_page = { userRestrictions: { restriction_data }, nextPageToken: string? }
-- TODO: complete from Roblox cloud docs
export type restriction_logs_page = { logs: { restriction_log_data }, nextPageToken: string? }

local UNIVERSE = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/user-restrictions'
local PLACE = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/places/{place_id}/user-restrictions'

local READ: web.auth_spec = { apikey = { scope = { ['universe.user-restriction:read'] = true } } }
local WRITE: web.auth_spec = { apikey = { scope = { ['universe.user-restriction:write'] = true } } }
local RATELIMIT: web.ratelimit = { apikey = 9000 }

local SUBJECT = table.freeze { universe_id = 0, place_id = 0 :: number? }
local RESTRICTION = table.freeze { universe_id = 0, place_id = 0 :: number?, user_restriction_id = '' }
local UPDATE = table.freeze { ['idempotencyKey.key'] = '' :: string? }
local PAGE = table.freeze { maxPageSize = 0 :: number?, pageToken = '' :: string? }
local LOGS = table.freeze { maxPageSize = 0 :: number?, pageToken = '' :: string?, filter = '' :: string? }
type subject_path = typeof(SUBJECT)
type restriction_path = typeof(RESTRICTION)
export type update_query = typeof(UPDATE)
export type page_query = typeof(PAGE)
export type logs_query = typeof(LOGS)

-- helpers
-- restrictions live on the universe, or on a single place when `place_id` is given
local function subject_request(suffix: string)
	return function(self: any, auth: web.auth, path: subject_path, body: any, query: any): web.request
		local base = (if path.place_id then PLACE else UNIVERSE) .. suffix
		return web.build(self, auth, { base = base, path = path, body = body, query = query })
	end
end
local restriction_request = subject_request '/{user_restriction_id}'

-- module
return table.freeze {
	list = web.endpoint<<subject_path, page_query, nil, restrictions_page>> {
		base = UNIVERSE,
		method = 'GET',
		auth = READ,
		ratelimit = RATELIMIT,
		path = SUBJECT,
		query = PAGE,
		request = subject_request '',
	},

	get = web.endpoint<<restriction_path, nil, nil, restriction_data>> {
		base = `{UNIVERSE}/\{user_restriction_id}`,
		method = 'GET',
		auth = READ,
		ratelimit = RATELIMIT,
		path = RESTRICTION,
		request = restriction_request,
	},

	update = web.endpoint<<restriction_path, update_query, restriction_patch, restriction_data>> {
		base = `{UNIVERSE}/\{user_restriction_id}`,
		method = 'PATCH',
		auth = WRITE,
		ratelimit = RATELIMIT,
		path = RESTRICTION,
		query = UPDATE,
		content_type = 'application/json',
		request = function(self, auth, path, data, query)
			local params: any = if query then table.clone(query) else {}
			params.updateMask = web.mask_from(data)
			return restriction_request(self, auth, path, data, params)
		end,
	},

	list_logs = web.endpoint<<{ universe_id: number }, logs_query, nil, restriction_logs_page>> {
		base = `{UNIVERSE}:listLogs`,
		method = 'GET',
		auth = READ,
		ratelimit = RATELIMIT,
		path = { universe_id = 0 },
		query = LOGS,
	},
}
