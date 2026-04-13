local net = require '@lune/net'
local roblox = require '@lune/roblox'
local serde = require '@lune/serde'

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
	path: string,
	method: net.HttpMethod,
	content_type: string?, -- unknown
	data: string | buffer?
)
	local headers: any = { ['Content-Type'] = content_type :: any, ['Cookie'] = `.ROBLOSECURITY={session.cookie}` }
	return net.request { url = path, method = method, body = data, headers = headers }
end

type user = { id: number, name: string, displayName: string }
local function get_user_info(session: session): user
	local res = request(session, 'https://users.roblox.com/v1/users/authenticated', 'GET')
	assert(res.ok, res.statusMessage)

	return serde.decode('json', res.body)
end

-- module
return table.freeze { login = login, request = request, get_user_info = get_user_info }
