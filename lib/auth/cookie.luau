local runtime = require '@utils/runtime'

-- defs
export type session = { api_key: nil, cookie: string }

local function get_local_cookie()
	error 'not implemented yet' -- TODO
end

-- functions
local function login(cookie: string?): session
	if not cookie then
		warn 'no cookie provided, getting your local cookie'
		cookie = get_local_cookie()
	end
	assert(cookie, `couldnt possible login`)
	return table.freeze { cookie = cookie }
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
	local headers: any = { ['Content-Type'] = content_type, ['Cookie'] = session.cookie }
	local res = runtime.net.request { url = url, method = method, body = body, headers = headers }

	if res.statusCode == 403 then
		local token = res.headers['x-csrf-token'] or res.headers['X-CSRF-TOKEN']
		if type(token) == 'string' then
			headers['X-CSRF-TOKEN'] = token
			res = runtime.net.request { url = url, method = method, body = body, headers = headers }
		end
	end
	return res
end

-- module
return table.freeze { login = login, request = request }
