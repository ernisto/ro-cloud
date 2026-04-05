local cloud = require '@lib'

type config = { api_key: string, universe_id: number, place_id: number? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	if not config.place_id then
		runner.skip('get_info', 'PLACE_ID not set')
		runner.skip('download', 'PLACE_ID not set')
		return
	end

	local session = cloud.auth.apikey.login(config.api_key)
	local place_id = config.place_id :: number
	local id = { universe_id = config.universe_id, place_id = place_id }

	runner.test('get_info', function()
		local data = cloud.place.get_info(session, id)
		assert(data, 'no response')
	end)

	runner.test('download', function()
		local data = cloud.place.download(session, { place_id = place_id })
		assert(buffer.len(data) > 0, 'empty buffer')
	end)
end

return suite
