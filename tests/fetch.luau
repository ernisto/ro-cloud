local cloud = require '@lib'
local json = require '@std/json'
local net = require '@std/net'

-- defs
export type http_result<R, E> = http_success<R> | http_fail<E>
export type http_success<R> = { ok: true, code: number, message: string, body: R }
export type http_fail<E> = { ok: false, code: number, message: string, body: E }

-- helpers
local function send(req: cloud.request): net.Response
	return net.request(req.url, {
		method = req.method :: any,
		headers = req.headers,
		body = if req.body then buffer.tostring(req.body) else nil,
	})
end

local function decode(raw: string): any
	if not string.match(raw, '^%s*[%[{]') then return nil end

	local ok, body = pcall(json.deserialize, raw)
	return if ok then body else nil
end

-- functions
local function fetch<P, Q, B, R, E>(
	def: cloud.endpoint<P, Q, B, R, E>,
	auth: cloud.auth,
	path: P,
	body: B,
	query: Q?
): http_result<R, E>
	local req = def:request(auth, path, body, query)
	local res = send(req)

	-- cookie apis hand out a csrf token on the first 403; cached in the session for next calls
	local token = res.headers['x-csrf-token']
	if res.status == 403 and token and req.headers.Cookie and auth.cookie_state then
		auth.cookie_state.csrf_token = token
		res = send(def:request(auth, path, body, query))
	end

	local decoded = decode(res.body)
	local err = type(decoded) == 'table' and decoded.errors and decoded.errors[1]

	return {
		ok = res.ok and not err,
		code = if err then err.code else res.status,
		message = if err then err.message else `http {res.status}`,
		body = decoded,
	} :: any
end

-- module
return table.freeze { fetch = fetch, send = send }
