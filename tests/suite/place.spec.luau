local cloud = require '@lib'
local config = require '../config'
local net = require '@lune/net'
local fetch = require('@utils/fetch').fetch

local auth = config.auth
local run = {}

function run.get_info()
	local res = fetch(cloud.place.get_info, auth, { universe_id = config.universe_id, place_id = config.place_id })
	assert(res.ok, `failed: {res.message}`)
end

function run.download()
	local res = fetch(cloud.asset.download, auth, { asset_id = config.place_id })
	assert(res.ok, `failed: {res.message}`)

	local file = net.request(res.body.location)
	assert(file.ok and #file.body > 0, 'empty file')
end

return run
