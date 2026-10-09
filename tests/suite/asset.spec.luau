local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch

local auth = config.auth
local run = {}

function run.get()
	local res = fetch(cloud.asset.get, auth, { asset_id = config.asset_id })
	assert(res.ok and res.body.assetType, 'missing assetType')
end

function run.list_versions()
	local res = fetch(cloud.asset.list_versions, auth, { asset_id = config.asset_id }, nil, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.assetVersions
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

return run
