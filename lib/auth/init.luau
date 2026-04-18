local net = require '@lune/net'
local serde = require '@lune/serde'

local apikey = require '@self/apikey'
local cookie = require '@self/cookie'
local form = require '@self/form'
local oauth = require '@self/oauth'

export type oauth2_session = oauth.session
export type cookie_session = cookie.session
export type apikey_session = apikey.session

-- defs
export type session = oauth2_session | cookie_session | apikey_session
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
	-- stylua: ignore
	return if any_session.api_key then apikey.request(any_session, method, url, query, body, content_type)
		elseif any_session.cookie then cookie.request(any_session, method, url, query, body, content_type)
		else oauth.request(any_session, method, url, query, body, content_type)
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

type user = { id: number, name: string, displayName: string }
local function get_user_info(session: cookie_session)
	return request_json(session, 'GET', 'https://users.roblox.com/v1/users/authenticated') :: http_result<user>
end

-- module
return table.freeze {
	get_user_info = get_user_info,
	request_json = request_json,
	request = request,

	mask_from = mask_from,
	form = form.by_table,

	apikey = apikey,
	cookie = cookie,
	oauth = oauth,
}
