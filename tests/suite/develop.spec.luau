local cloud = require '@lib'
local config = require '../config'

local session = config.cookie_session :: cloud.cookie_session

local focus = {}
local skip = {}
local run = {}

function skip.create_universe()
	local data = cloud.universe.create(session, { groupId = 16774807, templatePlaceId = 95206881 })
	assert(data.ok)
end

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

if not session then warn(`COOKIE required for develop.spec tests`) end
return if session then { run = run, skip = skip, focus = focus } else { run = {}, skip = run, focus = focus }
