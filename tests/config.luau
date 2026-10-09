local cloud = require '@lib'
local fs = require '@std/fs'
local process = require '@std/process'

local session: cloud.auth?

local function auth(): cloud.auth
	if session then return session end

	local dotenv = {}
	if fs.exists '.env' then
		for key, val in string.gmatch(fs.readFileToString '.env', [[([%w_]+)%s*=%s*["']?([^"'%c]*)]]) do
			dotenv[key] = val
		end
	end

	local api_key = dotenv.API_KEY or process.env.API_KEY
	local cookie = dotenv.COOKIE or process.env.COOKIE

	if not api_key then print 'missing API_KEY env var' end
	if not cookie then print 'missing COOKIE env var and no local cookie found' end

	local new = cloud.auth.new
	new = if api_key then new:api_key(api_key) else new
	new = if cookie then new:cookie(cookie) else new
	session = new
	return new
end

return table.freeze {
	auth = auth,

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
