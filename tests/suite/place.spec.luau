local cloud = require '@lib'
local config = require '../config'

local id = { universe_id = config.universe_id, place_id = config.place_id }
local run = {}

function run.get_info()
	local res = cloud.place.get_info(config.session, id)
	assert(res, 'no response')
end

function run.download()
	local res = cloud.place.download(config.session, { place_id = config.place_id })
	assert(res.ok and buffer.len(res.body) > 0, 'empty buffer')
end

return run
