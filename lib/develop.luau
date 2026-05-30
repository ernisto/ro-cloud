local auth = require '@lib/auth'
local group = require '@lib/group'
local place_configuration = require '@lib/place_configuration'
local universe = require '@lib/universe'

-- defs
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

type page_query = { limit: number?, cursor: string?, sortOrder: 'Asc' | 'Desc'?, isArchived: boolean? }
type page<Element> = { nextPageCursor: string?, prevPageCursor: string, data: { Element } }

type place_list_query = { isUniverseCreation: boolean?, limit: number?, cursor: string?, sortOrder: 'Asc' | 'Desc'? }
type place_page<Element> = { previousPageCursor: string?, nextPageCursor: string?, data: { Element } }

-- functions
local function get_user_universes(session: auth.cookie_session, query: page_query?)
	local url = `https://develop.roblox.com/v1/user/universes`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<page<dev_universe>>
end

local function get_group_universes(session: auth.cookie_session, subject: group.identity, query: page_query?)
	local url = `https://develop.roblox.com/v1/groups/{subject.group_id}/universes`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<page<dev_universe>>
end

local function get_groups(session: auth.cookie_session)
	local url = `https://develop.roblox.com/v1/user/groups/canmanagegamesoritems`
	return auth.request_json(session, 'GET', url) :: auth.http_result<{ data: { dev_group } }>
end

local function list_universe_places(session: auth.cookie_session, subject: universe.identity, query: place_list_query?)
	local url = `https://develop.roblox.com/v1/universes/{subject.universe_id}/places`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<place_page<place_configuration.place_data>>
end

-- module
return table.freeze {
	get_group_universes = get_group_universes,
	get_user_universes = get_user_universes,
	get_groups = get_groups,
	list_universe_places = list_universe_places,
}
