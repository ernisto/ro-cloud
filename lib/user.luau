local auth = require './auth'
type json = auth.json_object

-- defs
export type identity = { user_id: number }
export type subscription_identity = { universe_id: number, subscription_product_id: string, subscription_id: string }

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

type page_query = { maxPageSize: number?, pageToken: string?, filter: string? }

-- functions
local function get(session: auth.apikey_session | auth.oauth2_session, subject: identity)
	local url = `https://apis.roblox.com/cloud/v2/users/{subject.user_id}`
	return auth.request_json(session, 'GET', url) :: auth.http_result<user_data>
end

local function list_inventory(session: auth.apikey_session | auth.oauth2_session, subject: identity, query: page_query?)
	local url = `https://apis.roblox.com/cloud/v2/users/{subject.user_id}/inventory-items`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<json>
end

local function send_notification(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	notification: notification
)
	local url = `https://apis.roblox.com/cloud/v2/users/{subject.user_id}/notifications`
	return auth.request_json(session, 'POST', url, nil, notification) :: auth.http_result<notification>
end

local function get_subscription(
	session: auth.apikey_session | auth.oauth2_session,
	subject: subscription_identity,
	view: string?
)
	local url =
		`https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/subscription-products/{subject.subscription_product_id}/subscriptions/{subject.subscription_id}`
	return auth.request_json(session, 'GET', url, { view = view }) :: auth.http_result<subscription>
end

-- module
return table.freeze {
	get = get,
	list_inventory = list_inventory,
	send_notification = send_notification,
	get_subscription = get_subscription,
}
