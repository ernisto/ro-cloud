local cloud = require '@lib'

local run = {}

function run.build_url()
	local req = cloud.universe.update:request(
		cloud.auth.new:api_key 'k',
		{ universe_id = 1 },
		{ vrEnabled = true, desktopEnabled = false }
	)
	assert(req.method == 'PATCH', req.method)
	assert(req.url == 'https://apis.roblox.com/cloud/v2/universes/1?updateMask=desktopEnabled%2CvrEnabled', req.url)
	assert(req.headers['x-api-key'] == 'k', 'missing api key header')
	assert(req.headers['Content-Type'] == 'application/json', 'missing content type')
end

function run.optional_path_segment()
	local auth = cloud.auth.new:api_key 'k'
	local unscoped =
		cloud.data_store.get_entry:request(auth, { universe_id = 1, data_store_id = 'store', entry_id = 'e' })
	local scoped = cloud.data_store.get_entry:request(
		auth,
		{ universe_id = 1, data_store_id = 'store', scope_id = 'sc', entry_id = 'e' }
	)
	assert(unscoped.url == 'https://apis.roblox.com/cloud/v2/universes/1/data-stores/store/entries/e', unscoped.url)
	assert(
		scoped.url == 'https://apis.roblox.com/cloud/v2/universes/1/data-stores/store/scopes/sc/entries/e',
		scoped.url
	)
end

function run.path_and_query()
	local auth = cloud.auth.new:api_key 'k'
	local req = cloud.user_restriction.list:request(auth, { universe_id = 1, place_id = 2 }, nil, { maxPageSize = 5 })
	assert(req.url == 'https://apis.roblox.com/cloud/v2/universes/1/places/2/user-restrictions?maxPageSize=5', req.url)
end

function run.body_encoding()
	local auth = cloud.auth.new:api_key 'k'
	local empty = cloud.universe.shutdown:request(auth, { universe_id = 1 })
	local empty_body = empty.body and buffer.tostring(empty.body)
	assert(empty_body == '{}', `expected empty json body, got {empty_body}`)

	local multipart = cloud.pass.update:request(auth, { universe_id = 1, pass_id = 2 }, { name = 'x' })
	local content_type = multipart.headers['Content-Type']
	assert(string.find(content_type, 'multipart/form-data; boundary=', 1, true), content_type)
	assert(
		multipart.body and string.find(buffer.tostring(multipart.body), 'name="name"', 1, true),
		'missing form field'
	)
end

function run.picks_accepted_credential()
	local auth = cloud.auth.new:api_key('k'):cookie 'c'
	auth.cookie_state.csrf_token = 't'
	local cookie_req = cloud.develop.get_groups:request(auth, nil, nil)
	assert(cookie_req.headers.Cookie == 'c' and cookie_req.headers['X-CSRF-TOKEN'] == 't', 'expected cookie auth')
	assert(not cookie_req.headers['x-api-key'], 'cookie-only api got api key')

	local ok =
		pcall(cloud.universe.get.request, cloud.universe.get, cloud.auth.new:cookie 'c', { universe_id = 1 }, nil)
	assert(not ok, 'expected error without accepted credential')
end

function run.json_encode()
	local function json(value: any): string
		return buffer.tostring(cloud.json.encode(value))
	end
	assert(json { 1, 2, 'a"\n' :: any } == '[1,2,"a\\"\\n"]', json { 1, 2, 'a"\n' :: any })
	assert(json {} == '{}', json {})
	assert(json(102181929056899) == '102181929056899', json(102181929056899))
	assert(json { a = { b = true } } == '{"a":{"b":true}}', json { a = { b = true } })
end

return run
