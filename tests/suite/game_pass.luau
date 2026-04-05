local cloud = require '@lib'

type config = { api_key: string, universe_id: number, pass_id: number? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	local session = cloud.auth.apikey.login(config.api_key)
	local universe = { universe_id = config.universe_id }

	runner.test('list', function()
		cloud.pass.list(session, universe)
	end)

	if not config.pass_id then
		runner.skip('get', 'PASS_ID not set')
		return
	end

	local id = { universe_id = config.universe_id, pass_id = config.pass_id :: number }

	runner.test('get', function()
		local data = cloud.pass.get(session, id)
		assert(data.name, 'missing name')
	end)
end

return suite
