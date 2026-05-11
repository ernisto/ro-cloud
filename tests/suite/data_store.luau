local cloud = require '@lib'

type config = { api_key: string, universe_id: number, data_store_id: string?, scope_id: string? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	local session = cloud.auth.apikey.login(config.api_key)
	local universe = { universe_id = config.universe_id }

	runner.test('list_stores', function()
		local res = cloud.data_store.list_stores(session, universe, { maxPageSize = 1 })
		assert(res.ok, `failed: {res.message}`)
		local list = (res.body :: any).dataStores
		assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
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
		local res = cloud.data_store.list_entries(session, store, { maxPageSize = 1 })
		assert(res.ok, `failed: {res.message}`)
		local list = (res.body :: any).dataStoreEntries
		assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
	end)
end

return suite
