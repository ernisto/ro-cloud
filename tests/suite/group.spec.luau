local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local test = require '@std/test'

test.suite('group', function(s)
	s:case('get', function(t)
		local res = fetch(cloud.group.get, config.auth(), { group_id = config.group_id })
		assert(res.ok, `failed: {res.message}`)
		t.that(res.body.path, 'missing path')
	end)

	s:case('list_roles', function(t)
		local res = fetch(
			cloud.group.list_roles,
			config.auth(),
			{ group_id = config.group_id },
			nil,
			{ maxPageSize = 1 }
		)
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.groupRoles
		t.that(type(list) == 'table' and #list <= 1, 'maxPageSize=1 not honored')
	end)

	s:case('list_memberships', function(t)
		local res = fetch(
			cloud.group.list_memberships,
			config.auth(),
			{ group_id = config.group_id },
			nil,
			{ maxPageSize = 1 }
		)
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.groupMemberships
		t.that(type(list) == 'table' and #list <= 1, 'maxPageSize=1 not honored')
	end)
end)
