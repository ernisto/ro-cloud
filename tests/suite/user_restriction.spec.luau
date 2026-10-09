local cloud = require '@lib'
local config = require '../config'
local fetch = require('../fetch').fetch

local auth = config.auth
local run = {}

function run.list()
	local res = fetch(cloud.user_restriction.list, auth, { universe_id = config.universe_id }, nil, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.userRestrictions
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

function run.list_logs()
	local res = fetch(
		cloud.user_restriction.list_logs,
		auth,
		{ universe_id = config.universe_id },
		nil,
		{ maxPageSize = 1 }
	)
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.logs
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

return run
