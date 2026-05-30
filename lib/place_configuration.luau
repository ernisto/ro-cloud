local auth = require '@lib/auth'

type date = string

-- defs
export type identity = { place_id: number }

export type place_data = {
	id: number,
	universeId: number,
	name: string,
	description: string,
	isRootPlace: boolean?,
	maxPlayerCount: number?,
	socialSlotType: string?,
	customSocialSlotsCount: number?,
	allowCopying: boolean?,
	currentSavedVersion: number?,
	isAllGenresAllowed: boolean?,
	allowedGearTypes: { number }?,
	maxPlayersAllowed: number?,
	created: date?,
	updated: date?,
}
export type place_patch = {
	name: string?,
	description: string?,
	maxPlayerCount: number?,
	socialSlotType: string?,
	customSocialSlotsCount: number?,
	allowCopying: boolean?,
	allowedGearTypes: { string }?,
	isAllGenresAllowed: boolean?,
}

-- functions
local function get(session: auth.cookie_session, subject: identity)
	local url = `https://develop.roblox.com/v2/places/{subject.place_id}`
	return auth.request_json(session, 'GET', url) :: auth.http_result<place_data>
end
local function update(session: auth.cookie_session, subject: identity, patch: place_patch)
	local url = `https://develop.roblox.com/v2/places/{subject.place_id}`
	return auth.request_json(session, 'PATCH', url, nil, patch) :: auth.http_result<place_data>
end

-- module
return table.freeze {
	get = get,
	update = update,
}
