local cloud = require '@lib'
local config = require '../config'

local id = { universe_id = config.universe_id }
local run = {}

function run.get()
	local res = cloud.universe.get(config.session, id)
	assert(res.ok and res.body.path, 'missing path')
end

function run.list_secrets()
	local res = cloud.universe_secret.list(config.session, id)
	assert(res.ok)
end

return run
