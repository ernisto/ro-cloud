local cloud = require '@lib'
local config = require '../config'

local session = assert(config.cookie_session, 'COOKIE required for develop tests')
local run = {}

function run.get_user_universes()
	local data = cloud.develop.get_user_universes(session)
	assert(data.ok and type(data.body.data) == 'table', 'expected data.data to be a table')
end

function run.get_groups()
	local res = cloud.develop.get_groups(session)
	assert(res.ok and type(res.body) == 'table', 'expected array of groups')
end

function run.get_group_universes()
	local group_res = cloud.develop.get_groups(session)
	assert(group_res.ok)
	if #group_res.body.data == 0 then return end

	local res = cloud.develop.get_group_universes(session, { group_id = group_res.body[1].id })
	assert(res.ok and type(res.body.data) == 'table', 'expected data.data to be a table')
end

return run
