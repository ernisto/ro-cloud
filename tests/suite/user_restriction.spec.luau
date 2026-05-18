local cloud = require '@lib'

type config = { api_key: string, universe_id: number }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	local session = cloud.auth.apikey.login(config.api_key)
	local id = { universe_id = config.universe_id }

	runner.test('list', function()
		local res = cloud.user_restriction.list(session, id, { maxPageSize = 1 })
		assert(res.ok, `failed: {res.message}`)
		local list = (res.body :: any).userRestrictions
		assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
	end)

	runner.test('list_logs', function()
		local res = cloud.user_restriction.list_logs(session, id, { maxPageSize = 1 })
		assert((res :: any).ok, `failed: {(res :: any).message}`)
		local list = ((res :: any).body :: any).logs
		assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
	end)
end

return suite
