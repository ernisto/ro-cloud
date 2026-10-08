local web = require './web'
type endpoint<P, Q, B, R> = web.endpoint<P, Q, B, R>
type json = any

-- defs
type date = string

export type error_code =
	| 'ERROR_CODE_UNSPECIFIED' --	UNSPECIFIED
	| 'SCRIPT_ERROR' --	The task's script raised an unhandled error.
	| 'DEADLINE_EXCEEDED' --	The task exceeded the maximum allowed execution duration.
	| 'OUTPUT_SIZE_LIMIT_EXCEEDED' --	The task's outputs were too large.
	| 'INTERNAL_ERROR' --	The Task failed due to an internal system error.

-- shared
type task_base = { path: string, user: string, timeout: string? }
type done_base = task_base & { createTime: date, updateTime: date }

-- per-state types
export type pending_task = task_base & { state: 'QUEUED' | 'PROCESSING', script: string }
export type failed_task = done_base & { state: 'FAILED', error: { code: error_code, message: string? } }
export type complete_task = done_base & { state: 'COMPLETE', output: { results: { json } } }
export type cancelled_task = done_base & { state: 'CANCELLED' }

export type done_task = failed_task | complete_task | cancelled_task
export type task = pending_task | failed_task | complete_task | cancelled_task

export type task_input = { script: string, timeout: number? }

export type binary_input = { path: string?, content: buffer?, size: string? }
export type create_binary_input_request = { request_id: string? }
export type binary_input_response = { request_id: string?, uri: string? }

export type message_type =
	| 'MESSAGE_TYPE_UNSPECIFIED' --	UNSPECIFIED
	| 'OUTPUT' --	Corresponds to the MessageOutput enum value of the engine API.
	| 'INFO' --	Corresponds to the MessageInfo enum value of the engine API.
	| 'WARNING' --	Corresponds to the MessageWarning enum value of the engine API.
	| 'ERROR' --	Corresponds to the MessageError enum value of the engine API.

export type structured_message = {
	message: string,
	createTime: date,
	messageType: message_type,
}

export type task_log = structured_task_log | flat_task_log
export type structured_task_log = {
	path: string,
	structuredMessages: { structured_message },
}
export type flat_task_log = {
	path: string,
	messages: { string },
}

export type logs_page = { luauExecutionSessionTaskLogs: { task_log }, nextPageToken: string? }

local PLACE = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/places/{place_id}'
local READ: web.auth_spec = { apikey = { scope = { ['universe.place.luau-execution-session:read'] = true } } }
local WRITE: web.auth_spec = { apikey = { scope = { ['universe.place.luau-execution-session:write'] = true } } }

local LOGS = table.freeze {
	maxPageSize = 0 :: number?,
	pageToken = '' :: string?,
	-- 'FLAT' (default) fills `messages`, 'STRUCTURED' fills `structuredMessages`
	view = 'FLAT' :: ('VIEW_UNSPECIFIED' | 'FLAT' | 'STRUCTURED')?,
}
export type logs_query = typeof(LOGS)

local TASKS = table.freeze { universe_id = 0, place_id = 0, version = 0 :: number? }
local TASK = table.freeze { path = '' }
type tasks_path = typeof(TASKS)
type task_path = typeof(TASK)

-- module
return table.freeze {
	-- `version` is optional, defaults to the latest place version
	create = web.endpoint {
		base = `{PLACE}/luau-execution-session-tasks`,
		method = 'POST',
		auth = WRITE,
		ratelimit = { apikey = 5 },
		path = TASKS,
		content_type = 'application/json',
		request = function(self, auth, path, task)
			local base = if path.version
				then `{PLACE}/versions/\{version}/luau-execution-session-tasks`
				else `{PLACE}/luau-execution-session-tasks`
			return web.build(self, auth, { base = base, path = path, body = task })
		end,
	} :: endpoint<tasks_path, nil, task_input, pending_task>,

	-- `path` is the task path, as returned in `task.path`
	get = web.endpoint {
		base = 'https://apis.roblox.com/cloud/v2/{path}',
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 200 },
		path = TASK,
	} :: endpoint<task_path, nil, nil, task>,

	list_logs = web.endpoint {
		base = 'https://apis.roblox.com/cloud/v2/{path}/logs',
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 45 },
		path = TASK,
		query = LOGS,
	} :: endpoint<task_path, logs_query, nil, logs_page>,
}
