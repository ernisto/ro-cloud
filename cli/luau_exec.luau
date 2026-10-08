local fs = require '@lune/fs'
local stdio = require '@lune/stdio'
local task = require '@lune/task'

local cli = require '@utils/cli'
local cloud = require '@lib'
local env = require '@utils/env'
local fetch = require('@utils/fetch').fetch
local process = require '@lune/process'

-- cli
assert(cli.str(1) == 'luau', `no command '{cli.str(1)}'\navailable commands: 'luau'`)
assert(cli.str(2) == 'exec', `no sub-command '{cli.str(2)}'\navailable sub-commands: 'exec'`)

local universe_id = cli.num(3) or error 'universe_id <number> arg missing'
local place_id = cli.num(4) or error 'place_id <number> arg missing'
local api_key = cli.str 'api-key' or env.str 'API_KEY' or error '--api-key missing'
local poll_rate = cli.num 'poll-rate' or 3
local timeout = cli.num 'timeout'
local place_version = cli.num 'version'
local focus = cli.bool 'focus'

local script_path = cli.str 'script-path'
local script_content = (if script_path then fs.readFile(script_path) else cli.str 'script')
	or error '--script "<code>" or --script-path <path> arg missing'

local last_state

-- functions
local function core_log(msg: string)
	if focus then return end
	stdio.write(stdio.style 'dim' .. msg .. stdio.style 'reset' .. '\n')
end
local function poll_for_completion(auth: cloud.auth, task_path: string)
	while true do
		task.wait(poll_rate)

		local res = fetch(cloud.luau_task_exec.get, auth, { path = task_path })
		if res.code == 404 then
			error(`{stdio.color 'yellow'}failed to poll task ({res.code}): {res.message}{stdio.color 'reset'}`)
		elseif not res.ok then
			print(`{stdio.color 'yellow'}failed to poll task ({res.code}): {res.message}{stdio.color 'reset'}`)
			continue
		end

		local task_data = res.body
		if task_data.state ~= 'PROCESSING' and task_data.state ~= 'QUEUED' then return task_data end

		if task_data.state ~= last_state then
			core_log(`-- {task_data.state} --`)
			last_state = task_data.state
		end
	end
end
local function fetch_new_logs(auth: cloud.auth, task_path: string)
	local log_res = fetch(
		cloud.luau_task_exec.list_logs,
		auth,
		{ path = task_path },
		nil,
		{ view = 'FLAT' :: 'FLAT', maxPageSize = 10_000 }
	)
	if not log_res.ok then
		error(`{stdio.color 'red'}failed to fetch log page ({log_res.code}): {log_res.message}{stdio.color 'reset'}`)
	end

	for _, log in log_res.body.luauExecutionSessionTaskLogs do
		for _, msg in (log :: cloud.luau_task_flat_log).messages do
			print(msg)
		end
	end
end

-- run
local auth = cloud.auth.new:api_key(api_key)

core_log(`Creating task... `)
local task_input = { script = script_content, timeout = timeout }
local create_res = fetch(
	cloud.luau_task_exec.create,
	auth,
	{ universe_id = universe_id, place_id = place_id, version = place_version },
	task_input
)

if not create_res.ok then
	print(`{stdio.color 'red'}Failed to create task ({create_res.code}): {create_res.message}{stdio.color 'reset'}`)
	return process.exit(1)
end
local pending_task = create_res.body
last_state = pending_task.state

core_log(`-- {last_state} --`)
local completed_task = poll_for_completion(auth, pending_task.path)

fetch_new_logs(auth, completed_task.path)
if completed_task.state == 'FAILED' then
	local err = completed_task.error

	print(`{stdio.color 'red'}[{err.code}] {err.message or ''}{stdio.color 'reset'}\n`)
	return process.exit(1)
end
