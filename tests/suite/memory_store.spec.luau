local cloud = require '@lib'
local config = require '../config'

local sorted_map = { universe_id = config.universe_id, sorted_map_id = config.sorted_map_id }
local queue = { universe_id = config.universe_id, queue_id = config.queue_id }
local run = {}

function run.list_sorted_map()
	local res = cloud.memory_store.list_sorted_map(config.session, sorted_map, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)
	local list = (res.body :: any).items
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

function run.read_queue()
	local res = cloud.memory_store.read_queue(config.session, queue, { count = 1 })
	if res.code == 404 then
		print(`         skipped query check: queue '{config.queue_id}' not found`)
		return
	end
	assert(res.ok, `failed: {res.message}`)
	local list = (res.body :: any).items
	if list then assert(type(list) == 'table' and #list <= 1, `count=1 not honored (got {#list})`) end
end

return run
