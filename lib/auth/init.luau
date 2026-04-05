local net = require '@lune/net'
local serde = require '@lune/serde'

local form = require '@self/form'
local oauth = require '@self/oauth'
export type oauth2_session = oauth.session

local user = require '@self/user'
export type cookie_session = user.session

local api = require '@self/api'
export type apikey_session = api.session

-- defs
export type session = oauth2_session | cookie_session | apikey_session
export type json = number | boolean | string | { json } | json_object?
export type json_object = { [string]: json }
export type query_params = {}

local API_ENDPOINT = 'https://apis.roblox.com/'

-- helpers
local function build_query_string(params: query_params?): string
	if not params then return '' end
	local parts = {}
	for k, v in params do
		table.insert(parts, `{k}={tostring(v)}`)
	end
	return if #parts > 0 then '?' .. table.concat(parts, '&') else ''
end

-- functions
local function request(
	session: session,
	path: string,
	method: net.HttpMethod,
	content_type: string?,
	data: string | buffer?
)
	return if (session :: any).api_key
		then api.request(session :: any, path, method, content_type, data)
		elseif (session :: any).cookie then user.request(session :: any, path, method, content_type, data)
		else oauth.request(session :: any, path, method, content_type, data)
end

local function request_json(
	session: session,
	path: string,
	method: net.HttpMethod,
	data: json_object?,
	query: query_params?
): any -- json, but convertable to any struct
	local full_path = API_ENDPOINT .. path .. build_query_string(query)
	local response = request(session, full_path, method, 'application/json', data and serde.encode('json', data))
	local body = serde.decode('json', response.body)

	assert(response.ok, `Request fail [{response.statusCode}]: {response.statusMessage}\n{body and body.message or ''}`)
	return body
end

local function request_form(
	session: session,
	path: string,
	method: net.HttpMethod,
	fields: { [string]: (string | number | boolean | buffer)? },
	query: query_params?
)
	local f = form()
	for name, value in fields do
		if type(value) == 'buffer' then
			f.file(name, 'icon.png', 'image/png', value)
		else
			f.text(name, value :: any)
		end
	end
	local full_path = API_ENDPOINT .. path .. build_query_string(query)
	local response = request(session, full_path, method, `multipart/form-data; boundary={f.boundary}`, f.build())

	local body = if response.body:match '^{' then serde.decode('json', response.body) else {}

	assert(response.ok, `Request fail [{response.statusCode}]: {response.statusMessage}\n{body.errorMessage or ''}`)
	return body
end

-- module
return table.freeze {
	request_json = request_json,
	request_form = request_form,
	request = request,

	oauth = oauth,
	user = user,
	api = api,
}
