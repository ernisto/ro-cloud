local cloud = require '@lib'
local config = require '../config'
local fetch = require('@utils/fetch').fetch

local auth = config.auth
local run = {}

function run.list()
	local res = fetch(cloud.pass.list, auth, { universe_id = config.universe_id }, nil, { pageSize = 1 })
	assert(res.ok, `failed: {res.message}`)

	local list = res.body.gamePasses
	assert(type(list) == 'table' and #list <= 1, `pageSize=1 not honored (got {#list})`)
end

function run.get()
	local res = fetch(cloud.pass.get, auth, { universe_id = config.universe_id, pass_id = config.pass_id })
	assert(res.ok and res.body.name, 'missing name')
end

return run
