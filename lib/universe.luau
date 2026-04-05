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

export type secret = {
	id: string?,
	secret: string?,
	key_id: string?,
	domain: string?,
	create_time: string?,
	update_time: string?,
}

export type secret_create = { secret: string }
export type secret_patch = { secret: string? }
export type public_key = { key_id: string?, public_key: string? }

-- functions
local function get(session: auth.apikey_session | auth.oauth2_session, subject: identity): universe_data
	return auth.request_json(session, `cloud/v2/universes/{subject.universe_id}`, 'GET')
end
local function update(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	patch: universe_patch
): universe_data
	return auth.request_json(session, `cloud/v2/universes/{subject.universe_id}`, 'PATCH', patch)
end
local function publish_message(session: auth.apikey_session | auth.oauth2_session, subject: identity, message: message)
	return auth.request_json(session, `cloud/v2/universes/{subject.universe_id}:publishMessage`, 'POST', message)
end
local function shutdown(session: auth.apikey_session | auth.oauth2_session, subject: identity)
	return auth.request_json(session, `cloud/v2/universes/{subject.universe_id}:restartServers`, 'POST')
end

local function list_secrets(session: auth.apikey_session | auth.oauth2_session, subject: identity): json
	return auth.request_json(session, `cloud/v2/universes/{subject.universe_id}/secrets`, 'GET')
end

local function create_secret(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	data: secret_create
): secret
	return auth.request_json(session, `cloud/v2/universes/{subject.universe_id}/secrets`, 'POST', data)
end

local function delete_secret(session: auth.apikey_session | auth.oauth2_session, subject: identity, secret_id: string)
	auth.request_json(session, `cloud/v2/universes/{subject.universe_id}/secrets/{secret_id}`, 'DELETE')
end

local function update_secret(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	secret_id: string,
	data: secret_patch
): secret
	return auth.request_json(session, `cloud/v2/universes/{subject.universe_id}/secrets/{secret_id}`, 'PATCH', data)
end

local function get_public_key(session: auth.apikey_session | auth.oauth2_session, subject: identity): public_key
	return auth.request_json(session, `cloud/v2/universes/{subject.universe_id}/secrets/public-key`, 'GET')
end

-- module
return table.freeze {
	get = get,
	update = update,
	publish_message = publish_message,
	shutdown = shutdown,
	list_secrets = list_secrets,
	create_secret = create_secret,
	delete_secret = delete_secret,
	update_secret = update_secret,
	get_public_key = get_public_key,
}
