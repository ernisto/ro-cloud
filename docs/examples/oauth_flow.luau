local auth = require '@lib/auth'
local env = require '@utils/env'
local oauth = require '@lib/auth/oauth'

local fs = require '@lune/fs'
local net = require '@lune/net'
local serde = require '@lune/serde'
local task = require '@lune/task'

-- config
local CLIENT_ID = env.str 'CLIENT_ID' or error 'CLIENT_ID not found'
local CLIENT_SECRET = env.str 'CLIENT_SECRET' or error 'CLIENT_SECRET not found'
local REDIRECT_URI = 'http://localhost:3000/callback'
local SCOPES = {
	'openid',
	'profile',
}

-- functions
local function load_session(): oauth.session?
	return fs.isFile 'session.json' and serde.decode('json', fs.readFile 'session.json')
end
local function save_session(session: oauth.session?)
	if session then
		fs.writeFile('session.json', serde.encode('json', session, true))
	else
		fs.removeFile 'session.json'
	end
end

local function await_session(): oauth.session
	while true do
		local session = load_session()
		if session then return session end
		task.wait(1 / 5)
	end
end
local function await_authorize(): oauth.session
	local auth_url, code_verifier = oauth.create_authorization_url(CLIENT_ID, REDIRECT_URI, 'state_123', SCOPES :: any)
	local auth_callback_server = net.serve(3000, function(req)
		assert(req.path == '/callback', `invalid path: ${req.path}`)

		local code = req.query.code
		assert(code, `auth code not found`)

		-- for some reason lune crashes if we yield here
		task.spawn(function()
			local session = oauth.exchange_code_for_token(CLIENT_ID, CLIENT_SECRET, code, REDIRECT_URI, code_verifier)
			save_session(session)
		end)

		return {
			status = 200,
			headers = {
				['Content-Type'] = 'text/html',
			},
			body = [[
				<h1>Successfully authorized!</h1>
				<p>You can close this window and return to the terminal.</p>
				<script>window.close()</script>
			]],
		}
	end)
	print(`Open this URL in your browser: {auth_url}`)
	print 'Waiting for authorization...'

	local session = await_session()
	auth_callback_server.stop()

	return session
end

local function try_refresh_session(session: oauth.session): oauth.session?
	local success, new_session = pcall(oauth.refresh_token, CLIENT_ID, CLIENT_SECRET, session.refresh_token)
	save_session(success and new_session or nil)

	return new_session
end
local function maybe_fresh_session(session: oauth.session): oauth.session?
	if oauth.is_session_expired(session) then
		warn 'Session expired, refreshing...'
		return try_refresh_session(session)
	end

	return session
end

local last_session = load_session()
last_session = last_session and maybe_fresh_session(last_session)
local session = last_session or await_authorize()

print('Access Token:', session.access_token:sub(1, 10) .. '...')
print('Refresh Token:', session.refresh_token and (session.refresh_token:sub(1, 10) .. '...') or 'N/A')
print('ID Token:', session.id_token and (session.id_token:sub(1, 10) .. '...') or 'N/A')
print('Expires in:', session.expires_in, 'seconds')
print('Scopes:', table.concat(session.scope, ', '))

print 'Testing access to API...'
local response = auth.request_json(session, 'GET', 'oauth/v1/userinfo')

print 'API response:'
print(response)
