local net = require '@lune/net'
local roblox = require '@lune/roblox'
local serde = require '@lune/serde'

local api_key = require '@self/api_key'
local cookie = require '@self/cookie'
local form = require '@self/form'
local oauth = require '@self/oauth'

-- defs
export type session = oauth2_session | cookie_session | apikey_session
export type apikey_session = { api_key_state: api_key.state }
export type oauth2_session = { oauth_state: oauth.state }
export type cookie_session = { cookie_state: cookie.state }
export type api_key_introspection = api_key.introspection

export type json = number | boolean | string | { json } | json_object?
export type json_object = { [string]: json }
export type query_params = {}

export type http_result<R = nil, E = string> = http_success<R> | http_fail<E>
export type http_success<R> = { ok: true, code: number, message: string, body: R }
export type http_fail<E> = { ok: false, code: number, message: string, body: E }

-- helpers
local function mask_from(data: { [string]: any }): string
	local keys = {}
	for k in data do
		table.insert(keys, k)
	end
	return table.concat(keys, ',')
end

-- functions
local function request(
	session: session,
	method: net.HttpMethod,
	url: string,
	query: query_params?,
	body: string | buffer?,
	content_type: string?
)
	local any_session = session :: any
	local headers: any = {
		['Content-Type'] = content_type,
		['x-api-key'] = if any_session.api_key_state then any_session.api_key_state.key else nil,
		['Cookie'] = if any_session.cookie_state then any_session.cookie_state.cookie else nil,
		['Authorization'] = if any_session.oauth_state
			then `{any_session.oauth_state.token_type} {any_session.oauth_state.access_token}`
			else nil,
	}

	local res = net.request { url = url, method = method, body = body, headers = headers, query = query }

	if any_session.cookie_state and res.statusCode == 403 then
		local token = res.headers['x-csrf-token'] or res.headers['X-CSRF-TOKEN']
		if type(token) == 'string' then
			headers['X-CSRF-TOKEN'] = token
			res = net.request { url = url, method = method, body = body, headers = headers, query = query }
		end
	end

	return res
end

local function request_json<R, E>(
	session: session,
	method: net.HttpMethod,
	url: string,
	query: query_params?,
	data: string | {}?,
	content_type: string?
): http_result<R, E>
	local json_data = if type(data) == 'table' then serde.encode('json', data) else data
	local res = request(session, method, url, query, json_data, content_type or 'application/json')

	local body = string.match(res.body, '^{') and serde.decode('json', res.body)
	local err = type(body) == 'table' and body.errors and body.errors[1]

	local safe_res = if err
		then { body = body, headers = res.headers, message = err.message, code = err.code, ok = false }
		else { body = body, headers = res.headers, message = res.statusMessage, code = res.statusCode, ok = res.ok }

	return safe_res :: any
end

-- class
local session_mt = {}
session_mt.__index = session_mt

function session_mt.api_key(self, api_key: string)
	local new = table.clone(self)
	new.api_key_state = { key = api_key }

	return setmetatable(new, session_mt)
end

function session_mt.oauth(self, session: oauth.state)
	local new = table.clone(self)
	new.oauth_state = session

	return setmetatable(new, session_mt)
end

function session_mt.cookie(self, cookie_value: string)
	local new = table.clone(self)
	new.cookie_state = { cookie = cookie_value }

	return setmetatable(new, session_mt)
end

function session_mt.local_cookie(self)
	local cookie = roblox.getAuthCookie()
	assert(cookie, 'could not find your local cookie')

	return self:cookie(cookie)
end

-- module
return table.freeze {
	new = setmetatable({}, session_mt) :: any,
	request_json = request_json,
	request = request,

	mask_from = mask_from,
	form = form.by_table,

	api_key = api_key,
	cookie = cookie,
	oauth = oauth,
}
