local net = require '@lune/net'
local roblox = require '@lune/roblox'

-- defs
export type session = { api_key: nil, cookie: string }

-- functions
local function login(cookie: string?): session
	if not cookie then
		warn 'no cookie provided, getting your local cookie'
		cookie = roblox.getAuthCookie()
	end
	assert(cookie, `couldnt possible login`)
	return table.freeze { cookie = cookie }
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
	local headers: any = { ['Content-Type'] = content_type, ['Cookie'] = session.cookie }
	return net.request { url = url, method = method, body = body, headers = headers }
end

-- module
return table.freeze { login = login, request = request }
