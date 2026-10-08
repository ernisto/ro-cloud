local web = require './web'
type endpoint<P, Q, B, R> = web.endpoint<P, Q, B, R>

-- defs
export type product_patch = {
	name: string?,
	price: number?,
	description: string?,
	imageFile: buffer?,
	isForSale: boolean?,
	isRegionalPricingEnabled: boolean?,
	storePageEnabled: boolean?,
}
export type product_create_data = {
	name: string,
	price: number?,
	description: string?,
	imageFile: buffer?,
	isForSale: boolean?,
	isRegionalPricingEnabled: boolean?,
}
export type product_data = {
	name: string,
	universeId: number,
	productId: number,
	isForSale: boolean,
	description: string,
	storePageEnabled: boolean,
	iconImageAssetId: number,
	createdTimestamp: string,
	updatedTimestamp: string,
	priceInformation: {
		defaultPriceInRobux: number,
		enabledFeatures: { 'RegionalPricing' },
	},
}

export type product_page = {
	developerProducts: { product_data },
	nextPageToken: string,
}

local BASE = 'https://apis.roblox.com/developer-products/v2/universes/{universe_id}/developer-products'

local READ: web.auth_spec = { cookie = {}, apikey = { scope = { ['developer-product:read'] = true } } }
local WRITE: web.auth_spec = { cookie = {}, apikey = { scope = { ['developer-product:write'] = true } } }

local UNIVERSE = table.freeze { universe_id = 0 }
local ITEM = table.freeze { universe_id = 0, product_id = 0 }
local PAGE = table.freeze { pageSize = 0 :: number?, pageToken = '' :: string? }
type universe_path = typeof(UNIVERSE)
type product_path = typeof(ITEM)
export type page_query = typeof(PAGE)

-- module
return table.freeze {
	create = web.endpoint {
		base = BASE,
		method = 'POST',
		auth = WRITE,
		ratelimit = { apikey = 180 },
		path = UNIVERSE,
		content_type = 'multipart/form-data',
	} :: endpoint<universe_path, nil, product_create_data, product_data>,

	update = web.endpoint {
		base = `{BASE}/\{product_id}`,
		method = 'PATCH',
		auth = WRITE,
		ratelimit = { apikey = 180 },
		path = ITEM,
		content_type = 'multipart/form-data',
	} :: endpoint<product_path, nil, product_patch, nil>,

	get = web.endpoint {
		base = `{BASE}/\{product_id}/creator`,
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 600 },
		path = ITEM,
	} :: endpoint<product_path, nil, nil, product_data>,

	list = web.endpoint {
		base = `{BASE}/creator`,
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 600 },
		path = UNIVERSE,
		query = PAGE,
	} :: endpoint<universe_path, page_query, nil, product_page>,
}
