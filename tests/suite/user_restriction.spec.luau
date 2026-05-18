local cloud = require '@lib'
local config = require '../config'

local id = { universe_id = config.universe_id }
local run = {}

function run.list()
	local res = cloud.user_restriction.list(config.session, id, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)
	local list = (res.body :: any).userRestrictions
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

function run.list_logs()
	local res = cloud.user_restriction.list_logs(config.session, id, { maxPageSize = 1 })
	assert((res :: any).ok, `failed: {(res :: any).message}`)
	local list = ((res :: any).body :: any).logs
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

return run
