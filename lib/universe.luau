local web = require './web'

-- defs
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

-- per-api types
-- flat (no intersection): luau can't check table literals against an optional intersection body
export type universe_patch = {
	facebookSocialLink: social_link?,
	twitterSocialLink: social_link?,
	youtubeSocialLink: social_link?,
	twitchSocialLink: social_link?,
	discordSocialLink: social_link?,
	robloxGroupSocialLink: social_link?,
	guildedSocialLink: social_link?,
	voiceChatEnabled: boolean?,
	desktopEnabled: boolean?,
	mobileEnabled: boolean?,
	tabletEnabled: boolean?,
	consoleEnabled: boolean?,
	vrEnabled: boolean?,
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

local UNIVERSE = table.freeze { universe_id = 0 }
type universe_path = typeof(UNIVERSE)

local COOKIE: web.auth_spec = { cookie = {} }
local NONE: web.auth_spec = { apikey = { scope = {} } }
local WRITE: web.auth_spec = { apikey = { scope = { ['universe:write'] = true } } }
local PUBLISH: web.auth_spec = { apikey = { scope = { ['universe-messaging-service:publish'] = true } } }

-- module
return table.freeze {
	create = web.endpoint<<nil, nil, create_params, create_response>> {
		base = 'https://apis.roblox.com/universes/v1/universes/create',
		method = 'POST',
		auth = COOKIE,
		path = nil,
		content_type = 'application/json',
		request = function(self, auth, _, params)
			return web.build(self, auth, { query = { groupId = params.groupId }, body = params })
		end,
	},

	get = web.endpoint<<universe_path, nil, nil, universe_data>> {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}',
		method = 'GET',
		auth = NONE,
		ratelimit = { apikey = 100 },
		path = UNIVERSE,
	},

	update = web.endpoint<<universe_path, nil, universe_patch, universe_data>> {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}',
		method = 'PATCH',
		auth = WRITE,
		ratelimit = { apikey = 100 },
		path = UNIVERSE,
		content_type = 'application/json',
		request = web.with_update_mask,
	},

	publish_message = web.endpoint<<universe_path, nil, message, nil>> {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}:publishMessage',
		method = 'POST',
		auth = PUBLISH,
		ratelimit = { apikey = 5000 },
		path = UNIVERSE,
		content_type = 'application/json',
	},

	shutdown = web.endpoint<<universe_path, nil, nil, nil>> {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}:restartServers',
		method = 'POST',
		auth = WRITE,
		ratelimit = { apikey = 30 },
		path = UNIVERSE,
		content_type = 'application/json',
	},
}
