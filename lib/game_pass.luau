local auth = require './auth'
local universe = require './universe'

-- defs
export type identity = { universe_id: number, pass_id: number }
export type pass_data = {
	name: string,
	price: number?,
	description: string?,
	imageFile: buffer?,
	isForSale: boolean?,
	isRegionalPricingEnabled: boolean?,
}
export type pass_patch = pass_data & { name: string? }
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

type page_query = { maxPageSize: number?, pageToken: string? }
export type pass_page = {
	gamePasses: { pass_data },
	nextPageToken: string,
}

-- functions
local function create(session: auth.session, universe_id: number, data: pass_data): identity
	local url = `game-passes/v1/universes/{universe_id}/game-passes`
	local result = auth.request_form(session, url, 'POST', data)
	return { universe_id = universe_id, pass_id = result.gamePassId }
end
local function update(session: auth.session, pass: identity, data: pass_patch)
	local url = `game-passes/v1/universes/{pass.universe_id}/game-passes/{pass.pass_id}`
	auth.request_form(session, url, 'PATCH', data)
end
local function get(session: auth.session, pass: identity): pass_info
	local url = `game-passes/v1/universes/{pass.universe_id}/game-passes/{pass.pass_id}/creator`
	return auth.request_json(session, url, 'GET')
end
local function list(session: auth.session, subject: universe.identity, query: page_query?): pass_page
	local url = `game-passes/v1/universes/{subject.universe_id}/game-passes/creator`
	return auth.request_json(session, url, 'GET', nil, query)
end

-- module
return table.freeze {
	create = create,
	update = update,
	get = get,
	list = list,
}
