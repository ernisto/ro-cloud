local cloud = require '@lib'

type config = { api_key: string, universe_id: number }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	local session = cloud.auth.apikey.login(config.api_key)
	local id = { universe_id = config.universe_id }

	runner.test('get', function()
		local data = cloud.universe.get(session, id)
		assert(data.path, 'missing path')
	end)

	runner.test('list_secrets', function()
		cloud.universe.list_secrets(session, id)
	end)
end

return suite
