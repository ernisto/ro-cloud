local cloud = require '@lib'

type config = { api_key: string, universe_id: number, sorted_map_id: string?, queue_id: string? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	local session = cloud.auth.apikey.login(config.api_key)

	if config.sorted_map_id then
		local id = { universe_id = config.universe_id, sorted_map_id = config.sorted_map_id :: string }
		runner.test('list_sorted_map', function()
			cloud.memory_store.list_sorted_map(session, id)
		end)
	else
		runner.skip('list_sorted_map', 'SORTED_MAP_ID not set')
	end

	if config.queue_id then
		local id = { universe_id = config.universe_id, queue_id = config.queue_id :: string }
		runner.test('read_queue', function()
			cloud.memory_store.read_queue(session, id, { count = 1 })
		end)
	else
		runner.skip('read_queue', 'QUEUE_ID not set')
	end
end

return suite
