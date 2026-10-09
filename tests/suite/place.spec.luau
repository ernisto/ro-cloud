local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local net = require '@std/net'
local test = require '@std/test'

test.suite('place', function(s)
	s:case('get_info', function(t)
		local res =
			fetch(cloud.place.get_info, config.auth(), { universe_id = config.universe_id, place_id = config.place_id })
		assert(res.ok, `failed: {res.message}`)
	end)

	s:case('download', function(t)
		local res = fetch(cloud.asset.download, config.auth(), { asset_id = config.place_id })
		assert(res.ok, `failed: {res.message}`)

		local file = net.request(res.body.location)
		t.that(file.ok and #file.body > 0, 'empty file')
	end)
end)
