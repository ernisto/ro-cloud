local cloud = require '@lib'
local config = require '../config'
local fetch = require('@utils/fetch').fetch

local auth = config.auth
local run = {}

local focus = {}
local skip = {}

function skip.create_universe()
	local res = fetch(cloud.universe.create, auth, nil, { groupId = 16774807, templatePlaceId = 95206881 })
	assert(res.ok)
end

function run.get_user_universes()
	local res = fetch(cloud.develop.get_user_universes, auth)
	assert(res.ok and type(res.body.data) == 'table', 'expected data.data to be a table')
end

function run.get_groups()
	local res = fetch(cloud.develop.get_groups, auth)
	assert(res.ok and type(res.body) == 'table', 'expected array of groups')
end

function run.get_group_universes()
	local group_res = fetch(cloud.develop.get_groups, auth)
	assert(group_res.ok)
	if #group_res.body.data == 0 then return end

	local res = fetch(cloud.develop.get_group_universes, auth, { group_id = group_res.body.data[1].id })
	assert(res.ok and type(res.body.data) == 'table', 'expected data.data to be a table')
end

if not auth.cookie_state then warn 'COOKIE required for develop.spec tests' end
return if auth.cookie_state then { run = run, skip = skip, focus = focus } else { run = {}, skip = run, focus = focus }
