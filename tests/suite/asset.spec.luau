local cloud = require '@lib'
local config = require '../config'

local id = { asset_id = config.asset_id }
local run = {}

function run.get()
	local data = cloud.asset.get(config.session, id)
	assert(data.ok and data.body.assetType, 'missing assetType')
end

function run.list_versions()
	local res = cloud.asset.list_versions(config.session, id, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)
	local list = (res.body :: any).assetVersions
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

return run
