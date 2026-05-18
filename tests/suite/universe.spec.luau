local cloud = require '@lib'
local config = require '../config'

local id = { universe_id = config.universe_id }
local run = {}

function run.get()
	local data = cloud.universe.get(config.session, id)
	assert(data.ok and data.body.path, 'missing path')
end

function run.list_secrets()
	cloud.universe.list_secrets(config.session, id)
end

return run
