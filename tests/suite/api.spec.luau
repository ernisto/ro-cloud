local cloud = require '@lib'
local test = require '@std/test'

test.suite('api', function(s)
	s:case('build_url', function(t)
		local req = cloud.universe.update:request(
			cloud.auth.new:api_key 'k',
			{ universe_id = 1 },
			{ vrEnabled = true, desktopEnabled = false }
		)
		t.eq(req.method, 'PATCH')
		t.eq(req.url, 'https://apis.roblox.com/cloud/v2/universes/1?updateMask=desktopEnabled%2CvrEnabled')
		t.eq(req.headers['x-api-key'], 'k', 'missing api key header')
		t.eq(req.headers['Content-Type'], 'application/json', 'missing content type')
	end)

	s:case('optional_path_segment', function(t)
		local auth = cloud.auth.new:api_key 'k'
		local unscoped =
			cloud.data_store.get_entry:request(auth, { universe_id = 1, data_store_id = 'store', entry_id = 'e' })
		local scoped = cloud.data_store.get_entry:request(
			auth,
			{ universe_id = 1, data_store_id = 'store', scope_id = 'sc', entry_id = 'e' }
		)
		t.eq(unscoped.url, 'https://apis.roblox.com/cloud/v2/universes/1/data-stores/store/entries/e')
		t.eq(scoped.url, 'https://apis.roblox.com/cloud/v2/universes/1/data-stores/store/scopes/sc/entries/e')
	end)

	s:case('path_and_query', function(t)
		local auth = cloud.auth.new:api_key 'k'
		local req = cloud.user_restriction.list:request(
			auth,
			{ universe_id = 1, place_id = 2 },
			nil,
			{ maxPageSize = 5 }
		)
		t.eq(req.url, 'https://apis.roblox.com/cloud/v2/universes/1/places/2/user-restrictions?maxPageSize=5')
	end)

	s:case('body_encoding', function(t)
		local auth = cloud.auth.new:api_key 'k'
		local empty = cloud.universe.shutdown:request(auth, { universe_id = 1 })
		t.eq(empty.body and buffer.tostring(empty.body), '{}', 'expected empty json body')

		local multipart = cloud.pass.update:request(auth, { universe_id = 1, pass_id = 2 }, { name = 'x' })
		t.strContains(multipart.headers['Content-Type'], 'multipart/form-data; boundary=')
		t.strContains(
			multipart.body and buffer.tostring(multipart.body) or '',
			'name="name"',
			nil,
			'missing form field'
		)
	end)

	s:case('picks_accepted_credential', function(t)
		local auth = cloud.auth.new:api_key('k'):cookie 'c'
		auth.cookie_state.csrf_token = 't'
		local cookie_req = cloud.develop.get_groups:request(auth, nil, nil)
		t.eq(cookie_req.headers.Cookie, 'c', 'expected cookie auth')
		t.eq(cookie_req.headers['X-CSRF-TOKEN'], 't', 'expected csrf token')
		t.eq(cookie_req.headers['x-api-key'], nil :: any, 'cookie-only api got api key')

		t.throws(cloud.universe.get.request, cloud.universe.get, cloud.auth.new:cookie 'c', { universe_id = 1 }, nil)
	end)

	s:case('json_encode', function(t)
		local function json(value: any): string
			return buffer.tostring(cloud.json.encode(value))
		end
		t.eq(json { 1, 2, 'a"\n' :: any }, '[1,2,"a\\"\\n"]')
		t.eq(json {}, '{}')
		t.eq(json(102181929056899), '102181929056899')
		t.eq(json { a = { b = true } }, '{"a":{"b":true}}')
	end)
end)
