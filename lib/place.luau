local web = require './web'
type json = { [string]: any }

-- defs
export type info = {
	path: string?,
	createTime: string?,
	updateTime: string?,
	displayName: string?,
	description: string?,
	serverSize: number?,
	root: boolean?,
	universeRuntimeCreation: boolean?,
	templatePlace: string?,
}
export type info_patch = { displayName: string?, description: string?, serverSize: number? }

export type instance = { path: string?, hasChildren: boolean?, engineInstance: any? }

export type create_params = { templatePlaceId: number }
export type create_response = { placeId: number }

local INSTANCE_URL =
	'https://apis.roblox.com/cloud/v2/universes/{universe_id}/places/{place_id}/instances/{instance_id}'

local UNIVERSE = table.freeze { universe_id = 0 }
local PLACE = table.freeze { universe_id = 0, place_id = 0 }
local INSTANCE = table.freeze { universe_id = 0, place_id = 0, instance_id = '' }
local UPLOAD = table.freeze { versionType = 'Saved' :: 'Saved' | 'Published' }
local PAGE = table.freeze { maxPageSize = 0 :: number?, pageToken = '' :: string? }
type universe_path = typeof(UNIVERSE)
type place_path = typeof(PLACE)
type instance_path = typeof(INSTANCE)
export type upload_query = typeof(UPLOAD)
export type page_query = typeof(PAGE)

local COOKIE: web.auth_spec = { cookie = {} }
local NONE: web.auth_spec = { apikey = { scope = {} } }
local PLACES_WRITE: web.auth_spec = { apikey = { scope = { ['universe-places:write'] = true } } }
local WRITE: web.auth_spec = { apikey = { scope = { ['universe.place:write'] = true } } }
local INSTANCE_READ: web.auth_spec = { apikey = { scope = { ['universe.place.instance:read'] = true } } }
local INSTANCE_WRITE: web.auth_spec = { apikey = { scope = { ['universe.place.instance:write'] = true } } }

-- module
return table.freeze {
	create = web.endpoint<<universe_path, nil, create_params, create_response>> {
		base = 'https://apis.roblox.com/universes/v1/user/universes/{universe_id}/places',
		method = 'POST',
		auth = COOKIE,
		path = UNIVERSE,
		content_type = 'application/json',
	},

	-- place file as `.rbxl` / `.rbxlx` bytes; `versionType = 'Published'` publishes instead of only saving
	upload = web.endpoint<<place_path, upload_query, buffer, { versionNumber: number }>> {
		base = 'https://apis.roblox.com/universes/v1/{universe_id}/places/{place_id}/versions',
		method = 'POST',
		auth = PLACES_WRITE,
		ratelimit = { apikey = 30 },
		path = PLACE,
		query = UPLOAD,
		content_type = 'application/octet-stream',
	},

	get_info = web.endpoint<<place_path, nil, nil, info>> {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/places/{place_id}',
		method = 'GET',
		auth = NONE,
		ratelimit = { apikey = 100 },
		path = PLACE,
	},

	update_info = web.endpoint<<place_path, nil, info_patch, info>> {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/places/{place_id}',
		method = 'PATCH',
		auth = WRITE,
		ratelimit = { apikey = 100 },
		path = PLACE,
		content_type = 'application/json',
		request = web.with_update_mask,
	},

	get_instance = web.endpoint<<instance_path, nil, nil, json>> {
		base = INSTANCE_URL,
		method = 'GET',
		auth = INSTANCE_READ,
		ratelimit = { apikey = 45 },
		path = INSTANCE,
	},

	update_instance = web.endpoint<<instance_path, nil, instance, json>> {
		base = INSTANCE_URL,
		method = 'PATCH',
		auth = INSTANCE_WRITE,
		ratelimit = { apikey = 45 },
		path = INSTANCE,
		content_type = 'application/json',
		request = web.with_update_mask,
	},

	list_instance_children = web.endpoint<<instance_path, page_query, nil, json>> {
		base = `{INSTANCE_URL}:listChildren`,
		method = 'GET',
		auth = INSTANCE_READ,
		ratelimit = { apikey = 45 },
		path = INSTANCE,
		query = PAGE,
	},
}
