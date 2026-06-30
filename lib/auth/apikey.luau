local runtime = require '@utils/runtime'

-- defs
export type session = { api_key: string }

-- functions
local function login(api_key: string): session
	return table.freeze { api_key = api_key }
end

-- methods
local function request(
	session: session,
	method: string,
	url: string,
	query: {}?,
	body: string | buffer?,
	content_type: string? -- unknown
)
	local headers: any = { ['Content-Type'] = content_type, ['x-api-key'] = session.api_key }
	return runtime.net.request { url = url, method = method, body = body, headers = headers, query = query }
end

-- module
return table.freeze { login = login, request = request }
