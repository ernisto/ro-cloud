local cloud = require '@lib'
local env = require '@utils/env'
local roblox = require '@lune/roblox'

local api_key = env.str 'API_KEY'
local cookie = env.str 'COOKIE' or roblox.getAuthCookie()

if not api_key then warn 'missing API_KEY env var' end
if not cookie then warn 'missing COOKIE env var and no local cookie found' end

local session = cloud.auth.new
session = if api_key then session:api_key(api_key) else session
session = if cookie then session:cookie(cookie) else session

return table.freeze {
	auth = session,

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
