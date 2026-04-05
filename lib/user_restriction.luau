local auth = require './auth'
type json = auth.json_object

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

-- functions
local function list(
	session: auth.apikey_session | auth.oauth2_session,
	subject: universe_identity | place_identity,
	query: page_query?
): json
	local path = if (subject :: any).place_id
		then `cloud/v2/universes/{subject.universe_id}/places/{(subject :: any).place_id}/user-restrictions`
		else `cloud/v2/universes/{subject.universe_id}/user-restrictions`

	return auth.request_json(session, path, 'GET', nil, query)
end

local function get(
	session: auth.apikey_session | auth.oauth2_session,
	subject: restriction_identity | place_restriction_identity
): restriction
	local path = if (subject :: any).place_id
		then `cloud/v2/universes/{subject.universe_id}/places/{(subject :: any).place_id}/user-restrictions/{subject.user_restriction_id}`
		else `cloud/v2/universes/{subject.universe_id}/user-restrictions/{subject.user_restriction_id}`

	return auth.request_json(session, path, 'GET')
end

local function update(
	session: auth.apikey_session | auth.oauth2_session,
	subject: restriction_identity | place_restriction_identity,
	data: restriction,
	idempotency_key: string?
): restriction
	local path = if (subject :: any).place_id
		then `cloud/v2/universes/{subject.universe_id}/places/{(subject :: any).place_id}/user-restrictions/{subject.user_restriction_id}`
		else `cloud/v2/universes/{subject.universe_id}/user-restrictions/{subject.user_restriction_id}`

	local query = { updateMask = auth.mask_from(data), ['idempotencyKey.key'] = idempotency_key }
	return auth.request_json(session, path, 'PATCH', data, query)
end

local function list_logs(
	session: auth.apikey_session | auth.oauth2_session,
	subject: universe_identity,
	query: page_query?
): json
	local path = `cloud/v2/universes/{subject.universe_id}/user-restrictions:listLogs`
	return auth.request_json(session, path, 'GET', nil, query)
end

-- module
return table.freeze {
	list = list,
	get = get,
	update = update,
	list_logs = list_logs,
}
