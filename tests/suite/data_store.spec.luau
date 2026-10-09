local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local test = require '@std/test'

test.suite('data_store', function(s)
	s:case('list_stores', function(t)
		local res = fetch(
			cloud.data_store.list_stores,
			config.auth(),
			{ universe_id = config.universe_id },
			nil,
			{ maxPageSize = 1 }
		)
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.dataStores
		t.that(type(list) == 'table' and #list <= 1, 'maxPageSize=1 not honored')
	end)

	s:case('list_entries', function(t)
		local res = fetch(
			cloud.data_store.list_entries,
			config.auth(),
			{ universe_id = config.universe_id, data_store_id = config.data_store_id, scope_id = config.scope_id },
			nil,
			{ maxPageSize = 1 }
		)
		if res.code == 404 then
			print(`skipped query check: store '{config.data_store_id}' not found`)
			return
		end
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.dataStoreEntries
		t.that(type(list) == 'table' and #list <= 1, 'maxPageSize=1 not honored')
	end)
end)
