local cloud = require '@lib'
local config = require '../config'

local universe = { universe_id = config.universe_id }
local store: any = {
	universe_id = config.universe_id,
	data_store_id = config.data_store_id,
	scope_id = config.scope_id,
}
local run = {}

function run.list_stores()
	local res = cloud.data_store.list_stores(config.session, universe, { maxPageSize = 1 })
	assert(res.ok, `failed: {res.message}`)
	local list = (res.body :: any).dataStores
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

function run.list_entries()
	local res = cloud.data_store.list_entries(config.session, store, { maxPageSize = 1 })
	if res.code == 404 then
		print(`         skipped query check: store '{config.data_store_id}' not found`)
		return
	end
	assert(res.ok, `failed: {res.message}`)
	local list = (res.body :: any).dataStoreEntries
	assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
end

return run
