local cloud = require '@lib'
local config = require '../config'

local api_key = cloud.auth.api_key
local run = {}

function run.introspect()
	local info = api_key.await_introspect(config.session)
	assert(info.name, 'missing name')
	assert(api_key.usable(info), 'key not usable')

	local cached = select(1, api_key.introspect(config.session))
	assert(cached == info, 'introspection not cached')
end

function run.has_scope()
	local info = api_key.await_introspect(config.session)
	local granted = info.scopes[1]
	assert(granted, 'no scopes granted')
	assert(api_key.has_scope(info, granted.name .. ':' .. granted.operations[1]), 'granted scope failed check')
	assert(not api_key.has_scope(info, 'nonexistent.scope:read'), 'unknown scope passed check')
end

return run
