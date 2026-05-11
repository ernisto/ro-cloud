local cloud = require '@lib'

type config = { api_key: string, universe_id: number, product_id: number? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	local session = cloud.auth.apikey.login(config.api_key)
	local universe = { universe_id = config.universe_id }

	runner.test('list', function()
		local res = cloud.product.list(session, universe, { maxPageSize = 1 })
		assert(res.ok, `failed: {res.message}`)
		local list = res.body.developerProducts
		assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
	end)

	if not config.product_id then
		runner.skip('get', 'PRODUCT_ID not set')
		return
	end

	local id = { universe_id = config.universe_id, product_id = config.product_id :: number }

	runner.test('get', function()
		local data = cloud.product.get(session, id)
		assert(data.ok and data.body.name, 'missing name')
	end)
end

return suite
