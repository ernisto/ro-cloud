local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local test = require '@std/test'

test.suite('develop', function(s)
	-- ponytail: cases pass without a cookie, the runner has no skip
	local function cookie(): boolean
		if config.auth().cookie_state then return true end
		print 'COOKIE required for develop tests, skipping'
		return false
	end

	s:case('get_user_universes', function(t)
		if not cookie() then return end
		local res = fetch(cloud.develop.get_user_universes, config.auth())
		assert(res.ok, `failed: {res.message}`)
		t.eq(type(res.body.data), 'table', 'expected data.data to be a table')
	end)

	s:case('get_groups', function(t)
		if not cookie() then return end
		local res = fetch(cloud.develop.get_groups, config.auth())
		assert(res.ok, `failed: {res.message}`)
		t.eq(type(res.body), 'table', 'expected array of groups')
	end)

	s:case('get_group_universes', function(t)
		if not cookie() then return end

		local group_res = fetch(cloud.develop.get_groups, config.auth())
		assert(group_res.ok, `failed: {group_res.message}`)

		if #group_res.body.data == 0 then return end

		local res = fetch(cloud.develop.get_group_universes, config.auth(), { group_id = group_res.body.data[1].id })
		assert(res.ok, `failed: {res.message}`)

		t.eq(type(res.body.data), 'table', 'expected data.data to be a table')
	end)
end)
