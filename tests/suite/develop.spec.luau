local cloud = require '@lib'

type config = { cookie: string? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	local session = cloud.auth.cookie.login(config.cookie)

	runner.test('get_user_universes', function()
		local data = cloud.develop.get_user_universes(session)
		assert(data.ok and type(data.body.data) == 'table', 'expected data.data to be a table')
	end)

	runner.test('get_groups', function()
		local res = cloud.develop.get_groups(session)
		assert(res.ok and type(res.body) == 'table', 'expected array of groups')
	end)

	runner.test('get_group_universes: skipped without group in result', function()
		local group_res = cloud.develop.get_groups(session)
		assert(group_res.ok)
		if #group_res.body == 0 then return end

		local res = cloud.develop.get_group_universes(session, { group_id = group_res.body[1].id })
		assert(res.ok and type(res.body.data) == 'table', 'expected data.data to be a table')
	end)
end

return suite
