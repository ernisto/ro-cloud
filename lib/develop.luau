local auth = require '@lib/auth'

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
local function get_user_universes(session: auth.cookie_session, query: page_query?)
	local url = `https://develop.roblox.com/v1/user/universes`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<page<dev_universe>>
end

local function get_group_universes(session: auth.cookie_session, subject: { group_id: number }, query: page_query?)
	local url = `https://develop.roblox.com/v1/groups/{subject.group_id}/universes`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<page<dev_universe>>
end

local function get_groups(session: auth.cookie_session)
	local url = `https://develop.roblox.com/v1/user/groups/canmanagegamesoritems`
	return auth.request_json(session, 'GET', url) :: auth.http_result<{ dev_group }>
end

-- module
return table.freeze {
	get_group_universes = get_group_universes,
	get_user_universes = get_user_universes,
	get_groups = get_groups,
}
