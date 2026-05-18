local auth = require './auth'

-- defs
export type universe_identity = { universe_id: number }
export type place_identity = { universe_id: number, place_id: number }
export type restriction_identity = { universe_id: number, user_restriction_id: string }
export type place_restriction_identity = { universe_id: number, place_id: number, user_restriction_id: string }

type game_join_restriction = {
	active: boolean?,
	startTime: string?,
	duration: string?,
	privateReason: string?,
	displayReason: string?,
	excludeAltAccounts: boolean?,
}

export type restriction = {
	path: string?,
	updateTime: string?,
	user: string?,
	gameJoinRestriction: game_join_restriction?,
}

export type restriction_log = {
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

type page_query = { maxPageSize: number?, pageToken: string? }

-- TODO: complete from Roblox cloud docs
export type restrictions_page = { userRestrictions: { restriction }, nextPageToken: string? }
-- TODO: complete from Roblox cloud docs
export type restriction_logs_page = { logs: { restriction_log }, nextPageToken: string? }

-- functions
local function list(
	session: auth.apikey_session | auth.oauth2_session,
	subject: universe_identity | place_identity,
	query: page_query?
)
	local url = if (subject :: any).place_id
		then `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/places/{(subject :: any).place_id}/user-restrictions`
		else `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/user-restrictions`

	return auth.request_json(session, 'GET', url, query) :: auth.http_result<restrictions_page>
end

local function get(
	session: auth.apikey_session | auth.oauth2_session,
	subject: restriction_identity | place_restriction_identity
)
	local url = if (subject :: any).place_id
		then `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/places/{(subject :: any).place_id}/user-restrictions/{subject.user_restriction_id}`
		else `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/user-restrictions/{subject.user_restriction_id}`

	return auth.request_json(session, 'GET', url) :: auth.http_result<restriction>
end

local function update(
	session: auth.apikey_session | auth.oauth2_session,
	subject: restriction_identity | place_restriction_identity,
	data: restriction,
	idempotency_key: string?
)
	local url = if (subject :: any).place_id
		then `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/places/{(subject :: any).place_id}/user-restrictions/{subject.user_restriction_id}`
		else `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/user-restrictions/{subject.user_restriction_id}`

	local query = { updateMask = auth.mask_from(data), ['idempotencyKey.key'] = idempotency_key }
	return auth.request_json(session, 'PATCH', url, query, data) :: auth.http_result<restriction>
end

local function list_logs(
	session: auth.apikey_session | auth.oauth2_session,
	subject: universe_identity,
	query: page_query?
)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/user-restrictions:listLogs`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<restriction_logs_page>
end

-- module
return table.freeze {
	list = list,
	get = get,
	update = update,
	list_logs = list_logs,
}
