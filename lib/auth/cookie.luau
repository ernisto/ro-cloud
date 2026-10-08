local net = require '@lune/net'
local serde = require '@lune/serde'

-- defs
local AUTHENTICATED_URL = 'https://users.roblox.com/v1/users/authenticated'

export type user = { id: number, name: string, displayName: string }
export type state = { cookie: string, user_info: user? }
export type session = { cookie_state: state }

-- functions
local function request(session: session, method: net.HttpMethod, url: string, body: string?)
	local headers: any = {
		['Content-Type'] = 'application/json',
		['Cookie'] = session.cookie_state.cookie,
	}

	local res = net.request { url = url, method = method, body = body, headers = headers }

	if res.statusCode == 403 then
		local token = res.headers['x-csrf-token'] or res.headers['X-CSRF-TOKEN']
		if type(token) == 'string' then
			headers['X-CSRF-TOKEN'] = token
			res = net.request { url = url, method = method, body = body, headers = headers }
		end
	end

	return res
end

local function get_info(session: session): (user?, string?)
	local cached = session.cookie_state.user_info
	if cached then return cached, nil end

	local res = request(session, 'GET', AUTHENTICATED_URL)
	if not res.ok then return nil, res.statusMessage end

	local info = serde.decode('json', res.body) :: user
	session.cookie_state.user_info = info
	return info, nil
end

local function await_info(session: session): user
	local info, err = get_info(session)
	return info or error(`getting authenticated user failed: {err}`)
end

-- module
return table.freeze { get_info = get_info, await_info = await_info }
