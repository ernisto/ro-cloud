local net = require '@lune/net'
local pkce = require '@self/pkce'
local serde = require '@lune/serde'
local types = require '@self/types'

-- defs
local API_ENDPOINT = 'https://apis.roblox.com/'

export type permission = types.permission
export type session = types.session
export type oauth_error = types.oauth_error

-- functions
local function create_authorization_url(
	client_id: string,
	redirect_uri: string,
	state: string,
	scopes: { permission }
): (string, string)
	local code_verifier = pkce.generate_code_verifier()
	local code_challenge = pkce.generate_code_challenge.S256(code_verifier)

	return (API_ENDPOINT .. 'oauth/v1/authorize')
		.. `?client_id={client_id}`
		.. `&code_challenge={code_challenge}`
		.. `&code_challenge_method=S256`
		.. `&redirect_uri={redirect_uri}`
		.. `&scope={table.concat(scopes, ' ')}`
		.. `&response_type=code`
		.. `&state={state}`,
		code_verifier
end

local function parse_token_response(response: net.FetchResponse): session
	if not response.ok then
		local error_data = serde.decode('json', response.body) :: oauth_error
		error(`OAuth error: {error_data.error} - {error_data.error_description or 'No description'}`)
	end

	local token_data = serde.decode('json', response.body)
	local now = os.time()

	return {
		access_token = token_data.access_token,
		refresh_token = token_data.refresh_token,
		id_token = token_data.id_token,
		token_type = token_data.token_type,
		expires_in = token_data.expires_in,
		scope = string.split(token_data.scope, ' ') :: any,
		created_at = now,
		expires_at = now + token_data.expires_in,
	}
end

local function exchange_code_for_token(
	client_id: string,
	client_secret: string,
	code: string,
	redirect_uri: string,
	code_verifier: string
): session
	local response = net.request {
		url = API_ENDPOINT .. 'oauth/v1/token',
		method = 'POST',
		headers = {
			['Content-Type'] = 'application/x-www-form-urlencoded',
		},
		body = `grant_type=authorization_code`
			.. `&code={net.urlEncode(code)}`
			.. `&redirect_uri={net.urlEncode(redirect_uri)}`
			.. `&client_id={net.urlEncode(client_id)}`
			.. `&client_secret={net.urlEncode(client_secret)}`
			.. `&code_verifier={net.urlEncode(code_verifier)}`,
	}

	return parse_token_response(response)
end

local function refresh_token(client_id: string, client_secret: string, refresh_token: string): session
	local response = net.request {
		url = API_ENDPOINT .. 'oauth/v1/token',
		method = 'POST',
		headers = {
			['Content-Type'] = 'application/x-www-form-urlencoded',
		},
		body = `grant_type=refresh_token`
			.. `&refresh_token={net.urlEncode(refresh_token)}`
			.. `&client_id={net.urlEncode(client_id)}`
			.. `&client_secret={net.urlEncode(client_secret)}`,
	}

	return parse_token_response(response)
end

local function is_session_expired(session: session): boolean
	return os.time() >= session.expires_at
end

-- methods
local function request(session: session, path: string, method: net.HttpMethod, content_type: string?, body: string?)
	assert(not is_session_expired(session), 'Session has expired. Please refresh the token.')
	return net.request {
		url = path,
		method = method,
		headers = {
			['Authorization'] = `{session.token_type} {session.access_token}`,
			['Content-Type'] = content_type :: any,
		},
		body = body,
	}
end

-- module
return table.freeze {
	create_authorization_url = create_authorization_url,
	exchange_code_for_token = exchange_code_for_token,
	refresh_token = refresh_token,
	is_session_expired = is_session_expired,
	request = request,
}
