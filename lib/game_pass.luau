local web = require './web'
type endpoint<P, Q, B, R> = web.endpoint<P, Q, B, R>

-- defs
export type pass_data = {
	name: string,
	price: number?,
	description: string?,
	imageFile: buffer?,
	isForSale: boolean?,
	isRegionalPricingEnabled: boolean?,
}
export type pass_patch = {
	name: string?,
	price: number?,
	description: string?,
	imageFile: buffer?,
	isForSale: boolean?,
	isRegionalPricingEnabled: boolean?,
}
export type pass_info = {
	name: string,
	isForSale: boolean,
	description: string,
	iconAssetId: number,
	gamePassId: number,
	createdTimestamp: string,
	updatedTimestamp: string,
	priceInformation: {
		defaultPriceInRobux: number,
		enabledFeatures: { 'RegionalPricing' },
	},
}

export type pass_page = {
	gamePasses: { pass_info },
	nextPageToken: string,
}

local BASE = 'https://apis.roblox.com/game-passes/v1/universes/{universe_id}/game-passes'

-- api key or cookie
local READ: web.auth_spec = { cookie = {}, apikey = { scope = { ['game-pass:read'] = true } } }
local WRITE: web.auth_spec = { cookie = {}, apikey = { scope = { ['game-pass:write'] = true } } }

local UNIVERSE = table.freeze { universe_id = 0 }
local ITEM = table.freeze { universe_id = 0, pass_id = 0 }
local PAGE = table.freeze { pageSize = 0 :: number?, pageToken = '' :: string? }
type universe_path = typeof(UNIVERSE)
type pass_path = typeof(ITEM)
export type page_query = typeof(PAGE)

-- module
return table.freeze {
	create = web.endpoint {
		base = BASE,
		method = 'POST',
		auth = WRITE,
		ratelimit = { apikey = 300 },
		path = UNIVERSE,
		content_type = 'multipart/form-data',
	} :: endpoint<universe_path, nil, pass_data, pass_info>,

	update = web.endpoint {
		base = `{BASE}/\{pass_id}`,
		method = 'PATCH',
		auth = WRITE,
		ratelimit = { apikey = 300 },
		path = ITEM,
		content_type = 'multipart/form-data',
	} :: endpoint<pass_path, nil, pass_patch, nil>,

	get = web.endpoint {
		base = `{BASE}/\{pass_id}/creator`,
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 600 },
		path = ITEM,
	} :: endpoint<pass_path, nil, nil, pass_info>,

	list = web.endpoint {
		base = `{BASE}/creator`,
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 600 },
		path = UNIVERSE,
		query = PAGE,
	} :: endpoint<universe_path, page_query, nil, pass_page>,
}
