local form = require '@self/form'
local json = require '@self/json'

-- defs
export type api_key_state = { key: string }
export type cookie_state = { cookie: string, csrf_token: string? }
export type auth = { api_key_state: api_key_state?, cookie_state: cookie_state? }

export type request = { url: string, method: method, headers: { [string]: string }, body: buffer? }
export type method = 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE'

export type endpoint<Path, Query, Body, Response, ErrResponse = error> = {
	base: string,
	method: method,
	auth: auth_spec,
	ratelimit: ratelimit?,

	-- samples of the `{name}` url segments / url query string, they type `request` args
	-- path/body/query are optional everywhere: luau fails to infer generics across modules otherwise
	path: Path,
	body: Body,
	query: Query,

	content_type: string?,
	responses: { ['200']: Response, [string]: ErrResponse }?,

	request: (
		self: endpoint<Path, Query, Body, Response, ErrResponse>,
		auth,
		path: Path,
		body: Body,
		query: Query?
	) -> request,
}

export type endpoint_definition<Path, Query> = {
	base: string,
	method: method,
	auth: auth_spec,
	ratelimit: ratelimit?,
	path: Path, -- `nil` when there's neither path nor query (generic inference needs one of them)
	query: Query?,
	content_type: string?,
	request: ((self: any, auth: auth, path: Path, body: any, query: Query?) -> request)?,
}

export type ratelimit = { apikey: number? } -- requests per minute
export type auth_spec = { apikey: { scope: { [string]: true } }?, cookie: {}? }
export type error = {
	code: (string | number)?,
	message: string?,
	errors: { { code: number, message: string } }?,
}

-- helpers
local function encode(s: string): string
	return (string.gsub(s, '[^%w%-%._~]', function(c)
		return string.format('%%%02X', string.byte(c))
	end))
end

local function auth_headers(def: endpoint<any, any, any, any>, auth: auth): { [string]: string }
	local key, cookie = auth.api_key_state, auth.cookie_state
	return if def.auth.apikey and key
		then { ['x-api-key'] = key.key }
		elseif def.auth.cookie and cookie then {
			['Cookie'] = cookie.cookie,
			['X-CSRF-TOKEN'] = if cookie.csrf_token then cookie.csrf_token else nil,
		} :: any
		else error(`no credential accepted by {def.method} {def.base}`)
end

-- functions
type build_opts = {
	path: any,
	query: any,
	body: any,
	content_type: string?,
	base: string?, -- overrides `def.base`, for optional path segments
}

local function build(endpoint: any, auth: auth, options: build_opts?): request
	local opts: build_opts = options or {}
	local path: { [string]: any } = opts.path or {}

	local url = string.gsub(opts.base or endpoint.base, '{([%w_]+)}', function(name)
		local value = path[name]
		return if value ~= nil then tostring(value) else error(`missing path parameter '{name}' for {endpoint.base}`)
	end)

	local parts = {}
	local query: { [string]: any } = opts.query or {}

	for key, value in query do
		table.insert(parts, `{encode(key)}={encode(tostring(value))}`)
	end
	if #parts > 0 then
		table.sort(parts)
		url ..= '?' .. table.concat(parts, '&')
	end

	local headers = auth_headers(endpoint, auth)
	local body, content_type = opts.body, opts.content_type or endpoint.content_type

	if body == nil and content_type == 'application/json' then body = {} end
	if type(body) == 'table' then
		if content_type == 'multipart/form-data' then
			body, content_type = form.by_table(body)
		else
			body = json.encode(body)
		end
	end
	if body ~= nil then headers['Content-Type'] = content_type or 'application/json' end

	return { url = url, method = endpoint.method, headers = headers, body = body }
end

local function mask_from(data: { [string]: any }): string
	local keys = {}
	for key in data do
		table.insert(keys, key)
	end

	table.sort(keys)
	return table.concat(keys, ',')
end

local function default_request(self: any, auth: auth, path: any, body: any, query: any): request
	return build(self, auth, { path = path, body = body, query = query })
end

local function with_update_mask(self: any, auth: auth, path: any, body: { [string]: any }, query: any): request
	local params: any = if query then table.clone(query) else {}
	params.updateMask = mask_from(body)
	return build(self, auth, { path = path, body = body, query = params })
end

-- returns `any` (cast it to `endpoint<...>`): `Query` in the return type breaks inference when both samples are set
local function endpoint<Path, Query>(def: endpoint_definition<Path, Query>): any
	if not def.request then def.request = default_request end
	return table.freeze(def)
end

-- module
return table.freeze {
	build = build,
	endpoint = endpoint,
	encode = encode,
	mask_from = mask_from,
	with_update_mask = with_update_mask,
}
