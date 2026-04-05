local auth = require './auth'
local operation = require './operation'
local place = require './place'
local serde = require '@lune/serde'

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

-- functions
local function create(
	session: auth.apikey_session,
	subject: place.identity | place.version_identity,
	task: task_input
): pending_task
	local path = `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/`
	if subject.version ~= nil then
		path ..= `versions/{subject.version}/`
	end
	return auth.request_json(session, path .. 'luau-execution-session-tasks', 'POST', task)
end

local function get(session: auth.apikey_session, subject: identity): task
	return auth.request_json(session, `cloud/v2/{subject.path}`, 'GET')
end

local function wait_for_task(session: auth.apikey_session, subject: identity): done_task?
	return operation.poll_for_result(session, subject.path) :: any
end

local function create_binary_input(
	session: auth.apikey_session,
	subject: { universe_id: number },
	request: create_binary_input_request,
	data: buffer
): binary_input_response
	local path = `cloud/v2/universes/{subject.universe_id}/luau-execution-session-task-binary-inputs`
	return auth.request_form(session, path, 'POST', {
		request = serde.encode('json', request),
		content = data,
	})
end

local function get_task_by_path(session: auth.apikey_session, path: string): task
	return auth.request_json(session, `cloud/v2/{path}`, 'GET')
end

-- module
return table.freeze {
	create = create,
	get = get,
	wait_for_task = wait_for_task,
	create_binary_input = create_binary_input,
	get_task_by_path = get_task_by_path,
}
