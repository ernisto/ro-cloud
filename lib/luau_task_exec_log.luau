local auth = require './auth'
local luau_task_exec = require './luau_task_exec'

-- defs
type date = string

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

-- functions
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
type list_flat = (session: auth.apikey_session, subject: luau_task_exec.identity, query: flat_query) -> response_flat
type list_structured = (
	session: auth.apikey_session,
	subject: luau_task_exec.identity,
	query: structured_query
) -> response_structured

local function list(session: auth.apikey_session, subject: luau_task_exec.identity, query: query): response
	return auth.request_json(session, `cloud/v2/{subject.path}/logs`, 'GET', query :: any) :: any
end

-- module
return table.freeze {
	list = list :: list,
}
