local cloud = require '@lib'
local config = require '../config'

local id = { universe_id = config.universe_id, place_id = config.place_id }
local run = {}

function run.get_info()
	local data = cloud.place.get_info(config.session, id)
	assert(data, 'no response')
end

function run.download()
	local data = cloud.place.download(config.session, { place_id = config.place_id })
	assert(data.ok and buffer.len(data.body) > 0, 'empty buffer')
end

return run
