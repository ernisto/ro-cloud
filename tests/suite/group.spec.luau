local cloud = require '@lib'

type config = { api_key: string, group_id: number? }
type runner = typeof(require '../runner')

local suite = {}

function suite.run(config: config, runner: runner)
	if not config.group_id then
		runner.skip('get', 'GROUP_ID not set')
		runner.skip('list_roles', 'GROUP_ID not set')
		runner.skip('list_memberships', 'GROUP_ID not set')
		return
	end

	local session = cloud.auth.apikey.login(config.api_key)
	local id = { group_id = config.group_id :: number }

	runner.test('get', function()
		local data = cloud.group.get(session, id)
		assert(data.ok and data.body.path, 'missing path')
	end)

	runner.test('list_roles', function()
		local res = cloud.group.list_roles(session, id, { maxPageSize = 1 })
		assert(res.ok, `failed: {res.message}`)
		local list = (res.body :: any).groupRoles
		assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
	end)

	runner.test('list_memberships', function()
		local res = cloud.group.list_memberships(session, id, { maxPageSize = 1 })
		assert(res.ok, `failed: {res.message}`)
		local list = (res.body :: any).groupMemberships
		assert(type(list) == 'table' and #list <= 1, `maxPageSize=1 not honored (got {#list})`)
	end)
end

return suite
