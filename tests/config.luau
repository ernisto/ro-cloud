local cloud = require '@lib'
local env = require '@utils/env'

local api_key = env.str 'API_KEY'
local cookie = env.str 'COOKIE'

if not api_key then warn 'missing API_KEY env var' end
if not cookie then warn 'missing COOKIE env var' end

local s = cloud.auth.new
s = if api_key then s:api_key(api_key) else s
s = if cookie then s:cookie(cookie) else s:local_cookie()

return table.freeze {
	session = s,

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
