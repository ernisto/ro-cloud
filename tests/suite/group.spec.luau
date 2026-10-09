local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch

local auth = config.auth
local run = {}

function run.get()
	local res = fetch(cloud.group.get, auth, { group_id = config.group_id })
	assert(res.ok and res.body.path, 'missing path')
end

function run.list_roles()
	local res = fetch(cloud.group.list_roles, auth, { group_id = config.group_id }, nil, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.groupRoles
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

function run.list_memberships()
	local res = fetch(cloud.group.list_memberships, auth, { group_id = config.group_id }, nil, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.groupMemberships
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

return run
