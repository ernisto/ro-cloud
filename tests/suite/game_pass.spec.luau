local cloud = require '@lib'
local config = require '../config'

local universe = { universe_id = config.universe_id }
local id = { universe_id = config.universe_id, pass_id = config.pass_id }
local run = {}

function run.list()
	local res = cloud.pass.list(config.session, universe, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)
	local list = res.body.gamePasses
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

function run.get()
	local res = cloud.pass.get(config.session, id)
	assert(res.ok and res.body.name, 'missing name')
end

return run
