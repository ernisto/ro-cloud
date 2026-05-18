local cloud = require '@lib'
local env = require '@utils/env'

local api_key = assert(env.str 'API_KEY', 'API_KEY required (--api-key or env)')
local cookie = env.str 'COOKIE'

return table.freeze {
	session = cloud.auth.apikey.login(api_key),
	cookie_session = if cookie then cloud.auth.cookie.login(cookie) else nil,

	universe_id = 7176734135,
	place_id = 102181929056899,
	user_id = 414709355,
	group_id = 16774807,
	asset_id = 102181929056899,
	pass_id = 1785918315,
	product_id = 3568215083,
	data_store_id = 'store',
	scope_id = 'scope',
	queue_id = 'queue',
	sorted_map_id = 'map',
}
