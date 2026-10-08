local cloud = require '@lib'
local config = require '../config'
local fetch = require('@utils/fetch').fetch

local auth = config.auth
local run = {}

function run.list_sorted_map()
	local res = fetch(
		cloud.memory_store.list_sorted_map,
		auth,
		{ universe_id = config.universe_id, sorted_map_id = config.sorted_map_id },
		nil,
		{ maxPageSize = 1 }
	)
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.items
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

function run.read_queue()
	local res = fetch(
		cloud.memory_store.read_queue,
		auth,
		{ universe_id = config.universe_id, queue_id = config.queue_id },
		nil,
		{ count = 1 }
	)
	if res.code == 404 then
		print(`         skipped query check: queue '{config.queue_id}' not found`)
		return
	end
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.items
	if list then assert(type(list) == 'table' and #list <= 1, `count=1 not honored (got {#list})`) end
end

return run
