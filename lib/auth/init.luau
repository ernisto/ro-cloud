local api_key = require '@self/api_key'
local cookie = require '@self/cookie'
local web = require './web'

-- defs
export type session = web.auth
export type api_key_introspection = api_key.introspection

-- class
local session_mt = {}
session_mt.__index = session_mt

function session_mt.api_key(self, key: string)
	local new = table.clone(self)
	new.api_key_state = { key = key }
	return setmetatable(new, session_mt)
end

function session_mt.cookie(self, cookie_value: string)
	local new = table.clone(self)
	new.cookie_state = { cookie = cookie_value }
	return setmetatable(new, session_mt)
end

-- module
return table.freeze {
	new = setmetatable({}, session_mt) :: any,
	api_key = api_key,
	cookie = cookie,
}
