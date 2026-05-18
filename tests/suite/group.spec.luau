local cloud = require '@lib'
local config = require '../config'

local id = { group_id = config.group_id }
local run = {}

function run.get()
	local data = cloud.group.get(config.session, id)
	assert(data.ok and data.body.path, 'missing path')
end

function run.list_roles()
	local res = cloud.group.list_roles(config.session, id, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.groupRoles
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

function run.list_memberships()
	local res = cloud.group.list_memberships(config.session, id, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.groupMemberships
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

return run
