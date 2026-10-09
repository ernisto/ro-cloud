local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local test = require '@std/test'

test.suite('user', function(s)
	s:case('get', function(t)
		local res = fetch(cloud.user.get, config.auth(), { user_id = config.user_id })
		assert(res.ok, `failed: {res.message}`)
		t.that(res.body.path, 'missing path')
	end)

	s:case('list_inventory', function(t)
		local res = fetch(
			cloud.user.list_inventory,
			config.auth(),
			{ user_id = config.user_id },
			nil,
			{ maxPageSize = 1 }
		)
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.inventoryItems
		t.that(type(list) == 'table' and #list <= 1, 'maxPageSize=1 not honored')
	end)
end)
