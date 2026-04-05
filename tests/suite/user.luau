local cloud = require '@lib'

type config = { api_key: string, user_id: number? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	if not config.user_id then
		runner.skip('get', 'USER_ID not set')
		runner.skip('list_inventory', 'USER_ID not set')
		return
	end

	local session = cloud.auth.apikey.login(config.api_key)
	local id = { user_id = config.user_id :: number }

	runner.test('get', function()
		local data = cloud.user.get(session, id)
		assert(data.path, 'missing path')
	end)

	runner.test('list_inventory', function()
		cloud.user.list_inventory(session, id)
	end)
end

return suite
