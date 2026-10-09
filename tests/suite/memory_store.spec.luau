local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local test = require '@std/test'

test.suite('memory_store', function(s)
	s:case('list_sorted_map', function(t)
		local res = fetch(
			cloud.memory_store.list_sorted_map,
			config.auth(),
			{ universe_id = config.universe_id, sorted_map_id = config.sorted_map_id },
			nil,
			{ maxPageSize = 1 }
		)
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.items
		t.that(type(list) == 'table' and #list <= 1, 'maxPageSize=1 not honored')
	end)

	s:case('read_queue', function(t)
		local res = fetch(
			cloud.memory_store.read_queue,
			config.auth(),
			{ universe_id = config.universe_id, queue_id = config.queue_id },
			nil,
			{ count = 1 }
		)
		if res.code == 404 then
			print(`skipped query check: queue '{config.queue_id}' not found`)
			return
		end
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.items
		if list then t.that(type(list) == 'table' and #list <= 1, 'count=1 not honored') end
	end)
end)
