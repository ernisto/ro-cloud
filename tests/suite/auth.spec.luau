local cloud = require '@lib'
local config = require '../config'
local fetch = require('@utils/fetch').fetch

local auth = config.auth
local run = {}

local api_key = cloud.auth.api_key

function run.introspect()
	local res = fetch(api_key.introspect, auth)
	assert(res.ok, `failed: {res.message}`)
	assert(res.body.name, 'missing name')
	assert(api_key.usable(res.body), 'key not usable')
end

function run.has_scope()
	local res = fetch(api_key.introspect, auth)
	assert(res.ok, `failed: {res.message}`)

	local info = res.body
	local granted = info.scopes[1]
	assert(granted, 'no scopes granted')
	assert(api_key.has_scope(info, granted.name .. ':' .. granted.operations[1]), 'granted scope failed check')
	assert(not api_key.has_scope(info, 'nonexistent.scope:read'), 'unknown scope passed check')
end

return run
