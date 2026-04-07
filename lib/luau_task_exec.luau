local auth = require './auth'
local place = require './place'

type json = auth.json

-- defs
type date = string
type task_path = string

export type error_code =
	| 'ERROR_CODE_UNSPECIFIED' --	UNSPECIFIED
	| 'SCRIPT_ERROR' --	The task's script raised an unhandled error.
	| 'DEADLINE_EXCEEDED' --	The task exceeded the maximum allowed execution duration.
	| 'OUTPUT_SIZE_LIMIT_EXCEEDED' --	The task's outputs were too large.
	| 'INTERNAL_ERROR' --	The Task failed due to an internal system error.

-- shared
type task_base = identity & { user: string, timeout: string? }
type done_base = task_base & { createTime: date, updateTime: date }

-- per-state types
export type pending_task = task_base & { state: 'QUEUED' | 'PROCESSING', script: string }
export type failed_task = done_base & { state: 'FAILED', error: { code: error_code, message: string? } }
export type complete_task = done_base & { state: 'COMPLETE', output: { results: { json } } }
export type cancelled_task = done_base & { state: 'CANCELLED' }

export type done_task = failed_task | complete_task | cancelled_task
export type task = pending_task | failed_task | complete_task | cancelled_task

export type identity = { path: string }
export type task_input = { script: string, timeout: string? }

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

type response = response_flat | response_structured
type response_flat = { luauExecutionSessionTaskLogs: { flat_task_log }, nextPageToken: string? }
type response_structured = { luauExecutionSessionTaskLogs: { structured_task_log }, nextPageToken: string? }

type query = structured_query | flat_query
type structured_query = {
	max_page_size: number?,
	page_token: string?,
	view: nil
		| 'UNSPECIFIED' --	The luau execution session task log view is not specified; the default will be used.
		| 'STRUCTURED', --	If this view is selected, the structuredMessages field will be populated (and the messages field will not). Each entry of the structuredMessages array contains the log message plus additional metadata (see LogMessage for details).
}
type flat_query = {
	max_page_size: number?,
	page_token: string?,
	view: 'FLAT', --	If this view is selected, the messages field will be populated (and the structuredMessages field will not). Each entry of the messages array contains only the log message, without additional medata. This is the default.
}

type list = list_flat & list_structured
type list_flat = (session: auth.apikey_session, subject: identity, query: flat_query) -> response_flat
type list_structured = (
	session: auth.apikey_session,
	subject: identity,
	query: structured_query
) -> response_structured

-- functions
local function create(session: auth.apikey_session, subject: place.identity | place.version_identity, task: task_input)
	local path = if (subject :: any).version
		then `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/versions/{(subject :: any).version}/luau-execution-session-tasks`
		else `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/luau-execution-session-tasks`

	return auth.request_json(session, 'POST', path, task) :: auth.http_result<pending_task>
end

local function get(session: auth.apikey_session, subject: identity)
	return auth.request_json(session, 'GET', `cloud/v2/{subject.path}`) :: auth.http_result<task>
end

local function list(session: auth.apikey_session, subject: identity, query: query)
	return auth.request_json(session, 'GET', `cloud/v2/{subject.path}/logs`, query) :: auth.http_result<response>
end

-- module
return table.freeze {
	create = create,
	get = get,
	list_logs = list,
}
