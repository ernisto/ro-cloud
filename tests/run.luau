local env = require '@utils/env'
local process = require '@lune/process'
local runner = require './runner'

local config = {
	api_key = env.str 'API_KEY',
	cookie = env.str 'COOKIE',
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

assert(config.api_key, 'API_KEY required (--api-key or env)')
assert(config.universe_id, 'UNIVERSE_ID required (--universe-id or env)')

local suites = {
	{ name = 'universe', suite = require './suite/universe' } :: any,
	{ name = 'place', suite = require './suite/place' },
	{ name = 'data_store', suite = require './suite/data_store' },
	{ name = 'memory_store', suite = require './suite/memory_store' },
	{ name = 'user_restriction', suite = require './suite/user_restriction' },
	{ name = 'game_pass', suite = require './suite/game_pass' },
	{ name = 'developer_product', suite = require './suite/developer_product' },
	{ name = 'user', suite = require './suite/user' },
	{ name = 'group', suite = require './suite/group' },
	{ name = 'asset', suite = require './suite/asset' },
	{ name = 'develop', suite = require './suite/develop' },
}

for _, entry in suites do
	print(`\n[{entry.name}]`)
	entry.suite.run(config, runner)
end

local p, f, s = runner.summary()
print(`\n{p} passed  {f} failed  {s} skipped`)
if f > 0 then process.exit(1) end
