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
	method: net.HttpMethod,
	url: string,
	query: {}?,
	body: string | buffer?,
	content_type: string? -- unknown
)
	local headers: any = { ['Content-Type'] = content_type, ['x-api-key'] = session.api_key }
	return net.request { url = url, method = method, body = body, headers = headers :: any }
end

-- module
return table.freeze { login = login, request = request }
