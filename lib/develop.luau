local place_configuration = require './place_configuration'
local web = require './web'
type endpoint<P, Q, B, R> = web.endpoint<P, Q, B, R>

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

type page<Element> = { nextPageCursor: string?, prevPageCursor: string, data: { Element } }

type place_page<Element> = { previousPageCursor: string?, nextPageCursor: string?, data: { Element } }

local COOKIE: web.auth_spec = { cookie = {} }

local PAGE = table.freeze {
	limit = 0 :: number?,
	cursor = '' :: string?,
	sortOrder = 'Asc' :: ('Asc' | 'Desc')?,
	isArchived = false :: boolean?,
}
local PLACE_LIST = table.freeze {
	isUniverseCreation = false :: boolean?,
	limit = 0 :: number?,
	cursor = '' :: string?,
	sortOrder = 'Asc' :: ('Asc' | 'Desc')?,
}
export type page_query = typeof(PAGE)
export type place_list_query = typeof(PLACE_LIST)

-- module
return table.freeze {
	get_user_universes = web.endpoint {
		base = 'https://develop.roblox.com/v1/user/universes',
		method = 'GET',
		auth = COOKIE,
		path = nil,
		query = PAGE,
	} :: endpoint<nil, page_query, nil, page<dev_universe>>,

	get_group_universes = web.endpoint {
		base = 'https://develop.roblox.com/v1/groups/{group_id}/universes',
		method = 'GET',
		auth = COOKIE,
		path = { group_id = 0 },
		query = PAGE,
	} :: endpoint<{ group_id: number }, page_query, nil, page<dev_universe>>,

	get_groups = web.endpoint {
		base = 'https://develop.roblox.com/v1/user/groups/canmanagegamesoritems',
		method = 'GET',
		auth = COOKIE,
		path = nil,
	} :: endpoint<nil, nil, nil, { data: { dev_group } }>,

	list_universe_places = web.endpoint {
		base = 'https://develop.roblox.com/v1/universes/{universe_id}/places',
		method = 'GET',
		auth = COOKIE,
		path = { universe_id = 0 },
		query = PLACE_LIST,
	} :: endpoint<
		{ universe_id: number },
		place_list_query,
		nil,
		place_page<place_configuration.place_data>
	>,
}
