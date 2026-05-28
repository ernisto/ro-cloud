local auth = require './auth'
type json = auth.json_object

-- defs
export type identity = { universe_id: number }

type date = string
type social_link = { title: string?, uri: string? }

type age_rating =
	| 'AGE_RATING_UNSPECIFIED'
	| 'AGE_RATING_ALL'
	| 'AGE_RATING_9_PLUS'
	| 'AGE_RATING_13_PLUS'
	| 'AGE_RATING_17_PLUS'

type visibility =
	| 'VISIBILITY_UNSPECIFIED'
	| 'PUBLIC' --	The universe is public.
	| 'PRIVATE' --	The universe is private. All active players are immediately removed from all running servers.

-- shared
type universe_social_links = {
	facebookSocialLink: social_link?,
	twitterSocialLink: social_link?,
	youtubeSocialLink: social_link?,
	twitchSocialLink: social_link?,
	discordSocialLink: social_link?,
	robloxGroupSocialLink: social_link?,
	guildedSocialLink: social_link?,
}
type universe_platform_flags = {
	voiceChatEnabled: boolean?,
	desktopEnabled: boolean?,
	mobileEnabled: boolean?,
	tabletEnabled: boolean?,
	consoleEnabled: boolean?,
	vrEnabled: boolean?,
}

-- per-function types
export type universe_patch = universe_social_links & universe_platform_flags & {
	privateServerPriceRobux: number?,
}
export type universe_data = universe_social_links & universe_platform_flags & {
	path: string,
	createTime: date,
	updateTime: date,
	displayName: string,
	description: string,
	user: string?,
	group: string?,
	visibility: visibility,
	ageRating: age_rating,
	rootPlace: string,
	privateServerPriceRobux: number?,
}
export type message = { topic: string, message: string }

export type create_params = { templatePlaceId: number, groupId: number? }
export type create_response = { universeId: number, rootPlaceId: number? }

-- functions
local function create(session: auth.cookie_session, params: create_params)
	local url = 'https://apis.roblox.com/universes/v1/universes/create'
	local query = { groupId = params.groupId }
	return auth.request_json(session, 'POST', url, query, params) :: auth.http_result<create_response>
end
local function get(session: auth.apikey_session | auth.oauth2_session, subject: identity)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}`
	return auth.request_json(session, 'GET', url) :: auth.http_result<universe_data>
end
local function update(session: auth.apikey_session | auth.oauth2_session, subject: identity, patch: universe_patch)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}`
	return auth.request_json(session, 'PATCH', url, patch) :: auth.http_result<universe_data>
end
local function publish_message(session: auth.apikey_session | auth.oauth2_session, subject: identity, message: message)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}:publishMessage`
	return auth.request_json(session, 'POST', url, nil, message) :: auth.http_result<nil>
end
local function shutdown(session: auth.apikey_session | auth.oauth2_session, subject: identity)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}:restartServers`
	return auth.request_json(session, 'POST', url) :: auth.http_result<nil>
end

-- module
return table.freeze {
	create = create,
	get = get,
	update = update,
	publish_message = publish_message,
	shutdown = shutdown,
}
