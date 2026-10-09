local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch
local test = require '@std/test'

test.suite('asset', function(s)
	s:case('get', function(t)
		local res = fetch(cloud.asset.get, config.auth(), { asset_id = config.asset_id })
		assert(res.ok, `failed: {res.message}`)
		t.that(res.body.assetType, 'missing assetType')
	end)

	s:case('list_versions', function(t)
		local res = fetch(
			cloud.asset.list_versions,
			config.auth(),
			{ asset_id = config.asset_id },
			nil,
			{ maxPageSize = 1 }
		)
		assert(res.ok, `failed: {res.message}`)

		local list = res.body.assetVersions
		t.that(type(list) == 'table' and #list <= 1, 'maxPageSize=1 not honored')
	end)
end)
