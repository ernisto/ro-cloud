local cloud = require '@lib'
local config = require '../config'
local fetch = require('@utils/fetch').fetch

local auth = config.auth
local run = {}

function run.get()
	local res = fetch(cloud.universe.get, auth, { universe_id = config.universe_id })
	assert(res.ok and res.body.path, 'missing path')
end

function run.list_secrets()
	local res = fetch(cloud.universe_secret.list, auth, { universe_id = config.universe_id })
	assert(res.ok, `failed: {res.message}`)
end

return run
