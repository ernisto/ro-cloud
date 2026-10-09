local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local test = require '@std/test'

test.suite('universe', function(s)
	s:case('get', function(t)
		local res = fetch(cloud.universe.get, config.auth(), { universe_id = config.universe_id })
		assert(res.ok, `failed: {res.message}`)
		t.that(res.body.path, 'missing path')
	end)

	s:case('list_secrets', function(t)
		local res = fetch(cloud.universe_secret.list, config.auth(), { universe_id = config.universe_id })
		assert(res.ok, `failed: {res.message}`)
	end)
end)
