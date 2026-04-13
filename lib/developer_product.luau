local auth = require './auth'
local universe = require './universe'

-- defs
export type identity = { universe_id: number, product_id: number }

export type product_patch = product_create_data & { name: string?, storePageEnabled: boolean? }
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

type page_query = { maxPageSize: number?, pageToken: string? }
export type product_page = {
	developerProducts: { product_data },
	nextPageToken: string,
}

-- functions
local function create(session: auth.session, subject: universe.identity, data: product_create_data)
	local url = `https://apis.roblox.com/developer-products/v2/universes/{subject.universe_id}/developer-products`
	return auth.request_json(session, 'POST', url, nil, auth.form(data)) :: auth.http_result<product_data>
end
local function update(session: auth.session, product: identity, data: product_patch)
	local url =
		`https://apis.roblox.com/developer-products/v2/universes/{product.universe_id}/developer-products/{product.product_id}`
	return auth.request_json(session, 'PATCH', url, nil, auth.form(data)) :: auth.http_result<nil>
end
local function get(session: auth.session, product: identity)
	local url =
		`https://apis.roblox.com/developer-products/v2/universes/{product.universe_id}/developer-products/{product.product_id}/creator`
	return auth.request_json(session, 'GET', url) :: auth.http_result<product_data>
end
local function list(session: auth.session, subject: universe.identity, query: page_query?)
	local url =
		`https://apis.roblox.com/developer-products/v2/universes/{subject.universe_id}/developer-products/creator`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<product_page>
end

-- module
return table.freeze {
	create = create,
	update = update,
	get = get,
	list = list,
}
