local web = require './web'
type endpoint<P, Q, B, R> = web.endpoint<P, Q, B, R>

-- defs
type social_network_profiles = {
	facebook: string?,
	twitter: string?,
	youtube: string?,
	twitch: string?,
	guilded: string?,
	visibility: string?,
}

export type user_data = {
	path: string?,
	createTime: string?,
	id: string?,
	name: string?,
	displayName: string?,
	about: string?,
	locale: string?,
	premium: boolean?,
	idVerified: boolean?,
	socialNetworkProfiles: social_network_profiles?,
}

export type authenticated_user = { id: number, name: string, displayName: string }

export type inventory_item = {
	path: string?,
	assetDetails: any?,
	badgeDetails: any?,
	gamePassDetails: any?,
	privateServerDetails: any?,
}

export type notification = { path: string?, id: string?, source: any?, payload: any? }

export type subscription = {
	path: string?,
	createTime: string?,
	updateTime: string?,
	active: boolean?,
	willRenew: boolean?,
	lastBillingTime: string?,
	nextRenewTime: string?,
	expireTime: string?,
	state: string?,
	user: string?,
}

-- TODO: complete from Roblox cloud docs
export type inventory_page = { inventoryItems: { inventory_item }, nextPageToken: string? }

local COOKIE: web.auth_spec = { cookie = {} }
local READ: web.auth_spec = { apikey = { scope = { ['user.advanced:read'] = true, ['user.social:read'] = true } } }
local INVENTORY_READ: web.auth_spec = { apikey = { scope = { ['user.inventory-item:read'] = true } } }
local NOTIFICATION_WRITE: web.auth_spec = { apikey = { scope = { ['user.user-notification:write'] = true } } }
local SUBSCRIPTION_READ: web.auth_spec =
	{ apikey = { scope = { ['universe.subscription-product.subscription:read'] = true } } }

local USER = table.freeze { user_id = 0 }
local SUBSCRIPTION = table.freeze { universe_id = 0, subscription_product_id = '', subscription_id = '' }
local PAGE = table.freeze { maxPageSize = 0 :: number?, pageToken = '' :: string?, filter = '' :: string? }
type user_path = typeof(USER)
type subscription_path = typeof(SUBSCRIPTION)
export type page_query = typeof(PAGE)

-- module
return table.freeze {
	get = web.endpoint {
		base = 'https://apis.roblox.com/cloud/v2/users/{user_id}',
		method = 'GET',
		-- both scopes are optional, each one unlocks more fields
		auth = READ,
		ratelimit = { apikey = 1000 },
		path = USER,
	} :: endpoint<user_path, nil, nil, user_data>,

	-- the user owning the cookie
	get_authenticated = web.endpoint {
		base = 'https://users.roblox.com/v1/users/authenticated',
		method = 'GET',
		auth = COOKIE,
		path = nil,
	} :: endpoint<nil, nil, nil, authenticated_user>,

	list_inventory = web.endpoint {
		base = 'https://apis.roblox.com/cloud/v2/users/{user_id}/inventory-items',
		method = 'GET',
		auth = INVENTORY_READ,
		ratelimit = { apikey = 100 },
		path = USER,
		query = PAGE,
	} :: endpoint<user_path, page_query, nil, inventory_page>,

	send_notification = web.endpoint {
		base = 'https://apis.roblox.com/cloud/v2/users/{user_id}/notifications',
		method = 'POST',
		auth = NOTIFICATION_WRITE,
		ratelimit = { apikey = 240_000 },
		path = USER,
		content_type = 'application/json',
	} :: endpoint<user_path, nil, notification, notification>,

	get_subscription = web.endpoint {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/subscription-products/{subscription_product_id}/subscriptions/{subscription_id}',
		method = 'GET',
		auth = SUBSCRIPTION_READ,
		ratelimit = { apikey = 500 },
		path = SUBSCRIPTION,
		query = { view = '' :: string? },
	} :: endpoint<subscription_path, { view: string? }, nil, subscription>,
}
