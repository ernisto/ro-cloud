local cloud = require '@lib'

type config = { api_key: string, universe_id: number }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	local session = cloud.auth.apikey.login(config.api_key)
	local id = { universe_id = config.universe_id }

	runner.test('list', function()
		cloud.user_restriction.list(session, id)
	end)

	runner.test('list_logs', function()
		cloud.user_restriction.list_logs(session, id)
	end)
end

return suite
