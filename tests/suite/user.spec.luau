local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch

local auth = config.auth
local run = {}

function run.get()
	local res = fetch(cloud.user.get, auth, { user_id = config.user_id })
	assert(res.ok and res.body.path, 'missing path')
end

function run.list_inventory()
	local res = fetch(cloud.user.list_inventory, auth, { user_id = config.user_id }, nil, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.inventoryItems
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

return run
