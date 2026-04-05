local cloud = require '@lib'

type config = { api_key: string, universe_id: number, data_store_id: string?, scope_id: string? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	local session = cloud.auth.apikey.login(config.api_key)
	local universe = { universe_id = config.universe_id }

	runner.test('list_stores', function()
		cloud.data_store.list_stores(session, universe)
	end)

	if not config.data_store_id then
		runner.skip('list_entries', 'DATA_STORE_ID not set')
		return
	end

	local store: any = {
		universe_id = config.universe_id,
		data_store_id = config.data_store_id,
		scope_id = config.scope_id,
	}

	runner.test('list_entries', function()
		cloud.data_store.list_entries(session, store)
	end)
end

return suite
