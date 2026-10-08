local web = require './web'
type endpoint<P, Q, B, R> = web.endpoint<P, Q, B, R>

-- defs
type date = string

export type place_data = {
	id: number,
	universeId: number,
	isRootPlace: boolean,
	currentSavedVersion: number,
	maxPlayersAllowed: number,
	created: date,
	updated: date,

	name: string,
	description: string,
	maxPlayerCount: number,
	socialSlotType: string,
	customSocialSlotsCount: number,
	allowCopying: boolean,
	isAllGenresAllowed: boolean,
	allowedGearTypes: { number },
}
export type place_patch = {
	name: string?,
	description: string?,
	maxPlayerCount: number?,
	socialSlotType: string?,
	customSocialSlotsCount: number?,
	allowCopying: boolean?,
	isAllGenresAllowed: boolean?,
	allowedGearTypes: { string }?,
}

local COOKIE: web.auth_spec = { cookie = {} }

local PLACE = table.freeze { place_id = 0 }
type place_path = typeof(PLACE)

-- module
return table.freeze {
	get = web.endpoint {
		base = 'https://develop.roblox.com/v2/places/{place_id}',
		method = 'GET',
		auth = COOKIE,
		path = PLACE,
	} :: endpoint<place_path, nil, nil, place_data>,

	update = web.endpoint {
		base = 'https://develop.roblox.com/v2/places/{place_id}',
		method = 'PATCH',
		auth = COOKIE,
		path = PLACE,
		content_type = 'application/json',
	} :: endpoint<place_path, nil, place_patch, place_data>,
}
