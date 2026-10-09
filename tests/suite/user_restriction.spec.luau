local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local test = require '@std/test'

test.suite('user_restriction', function(s)
	s:case('list', function(t)
		local res = fetch(
			cloud.user_restriction.list,
			config.auth(),
			{ universe_id = config.universe_id },
			nil,
			{ maxPageSize = 1 }
		)
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.userRestrictions
		t.that(type(list) == 'table' and #list <= 1, 'maxPageSize=1 not honored')
	end)

	s:case('list_logs', function(t)
		local res = fetch(
			cloud.user_restriction.list_logs,
			config.auth(),
			{ universe_id = config.universe_id },
			nil,
			{ maxPageSize = 1 }
		)
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.logs
		t.that(type(list) == 'table' and #list <= 1, 'maxPageSize=1 not honored')
	end)
end)
