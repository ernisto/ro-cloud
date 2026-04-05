local net = require '@lune/net'

-- defs
export type session = { api_key: string }

-- functions
local function login(api_key: string): session
	return table.freeze { api_key = api_key }
end

-- methods
local function request(
	session: session,
	path: string,
	method: net.HttpMethod,
	content_type: string?, -- unknown
	data: string | buffer?
)
	local headers = { ['Content-Type'] = content_type, ['x-api-key'] = session.api_key }
	return net.request { url = path, method = method, body = data, headers = headers :: any }
end

-- module
return table.freeze { login = login, request = request }
