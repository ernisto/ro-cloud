local cloud = require '@lib'

type config = { cookie: string? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	local session = cloud.auth.cookie.login(config.cookie)

	runner.test('get_user_universes', function()
		local data = cloud.develop.get_user_universes(session)
		assert(type(data.data) == 'table', 'expected data.data to be a table')
	end)

	runner.test('get_groups', function()
		local data = cloud.develop.get_groups(session)
		assert(type(data) == 'table', 'expected array of groups')
	end)

	runner.test('get_group_universes: skipped without group in result', function()
		local groups = cloud.develop.get_groups(session)
		if #groups == 0 then return end

		local data = cloud.develop.get_group_universes(session, { group_id = groups[1].id })
		assert(type(data.data) == 'table', 'expected data.data to be a table')
	end)
end

return suite
