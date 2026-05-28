local cloud = require '@lib'
local config = require '../config'

local id = { user_id = config.user_id }
local run = {}

function run.get()
	local res = cloud.user.get(config.session, id)
	assert(res.ok and res.body.path, 'missing path')
end

function run.list_inventory()
	local res = cloud.user.list_inventory(config.session, id, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.inventoryItems
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

return run
