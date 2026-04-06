local cloud = require '@lib'

type config = { api_key: string, asset_id: number? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	if not config.asset_id then
		runner.skip('get', 'ASSET_ID not set')
		runner.skip('list_versions', 'ASSET_ID not set')
		return
	end

	local session = cloud.auth.apikey.login(config.api_key)
	local id = { asset_id = config.asset_id :: number }

	runner.test('get', function()
		local data = cloud.asset.get(session, id)
		assert(data.ok and data.body.assetType, 'missing assetType')
	end)

	runner.test('list_versions', function()
		cloud.asset.list_versions(session, id)
	end)
end

return suite
