local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local test = require '@std/test'

local api_key = cloud.auth.api_key

test.suite('auth', function(s)
	s:case('introspect', function(t)
		local res = fetch(api_key.introspect, config.auth())
		assert(res.ok, `failed: {res.message}`)
		t.that(res.body.name, 'missing name')
		t.that(api_key.usable(res.body), 'key not usable')
	end)

	s:case('has_scope', function(t)
		local res = fetch(api_key.introspect, config.auth())
		assert(res.ok, `failed: {res.message}`)

		local info = res.body
		local granted = info.scopes[1]
		t.that(granted, 'no scopes granted')
		t.that(api_key.has_scope(info, granted.name .. ':' .. granted.operations[1]), 'granted scope failed check')
		t.that(not api_key.has_scope(info, 'nonexistent.scope:read'), 'unknown scope passed check')
	end)
end)
