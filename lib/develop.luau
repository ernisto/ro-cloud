local auth = require '@lib/auth'
local serde = require '@lune/serde'

type date = string

export type dev_group = { name: string, id: number }
export type dev_universe = {
	id: number,
	name: string,
	creatorType: 'User' | 'Group',
	creatorName: string,
	creatorTargetId: number,
	created: date,
	updated: date,
	isActive: boolean,
	isArchived: boolean,
	rootPlaceId: number,
	privacyType: 'Public' | 'Private' | 'Group',
}

type page_query = { limit: number?, cursor: string?, sortOrder: 'Asc' | 'Desc', isArchived: boolean? }
type page<Element> = { nextPageToken: string?, prevPageToken: string, data: { Element } }

-- functions
local function get_user_universes(session: auth.cookie_session, query: page_query?): page<dev_universe>
	local res = auth.request(session, `https://develop.roblox.com/v1/user/universes`, 'GET', nil, nil, query)
	local body = serde.decode('json', res.body)

	assert(res.ok, res.statusMessage)
	return body
end

local function get_group_universes(
	session: auth.cookie_session,
	subject: { group_id: number },
	query: page_query?
): page<dev_universe>
	local path = `https://develop.roblox.com/v1/groups/{subject.group_id}/universes`
	local res = auth.request(session, path, 'GET', nil, nil, query)
	local body = serde.decode('json', res.body)

	assert(res.ok, res.statusMessage)
	return body
end

local function get_groups(session: auth.cookie_session): { dev_group }
	local res = auth.request(session, `https://develop.roblox.com/v1/user/groups/canmanagegamesoritems`, 'GET')
	local body = serde.decode('json', res.body)

	assert(res.ok, res.statusMessage)
	return body.data
end

-- module
return table.freeze {
	get_group_universes = get_group_universes,
	get_user_universes = get_user_universes,
	get_groups = get_groups,
}
