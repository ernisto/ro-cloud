local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local test = require '@std/test'

test.suite('developer_product', function(s)
	s:case('list', function(t)
		local res = fetch(
			cloud.product.list,
			config.auth(),
			{ universe_id = config.universe_id },
			nil,
			{ pageSize = 1 }
		)
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.developerProducts
		t.that(type(list) == 'table' and #list <= 1, 'pageSize=1 not honored')
	end)

	s:case('get', function(t)
		local res = fetch(
			cloud.product.get,
			config.auth(),
			{ universe_id = config.universe_id, product_id = config.product_id }
		)
		assert(res.ok, `failed: {res.message}`)
		t.that(res.body.name, 'missing name')
	end)
end)
