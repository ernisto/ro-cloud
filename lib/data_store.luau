local auth = require './auth'
local universe = require './universe'
type json = auth.json_object

-- defs
export type store_identity = { universe_id: number, data_store_id: string, scope_id: string? }
export type entry_identity = store_identity & { entry_id: string }

export type ordered_store_identity = { universe_id: number, ordered_data_store_id: string, scope_id: string }
export type ordered_entry_identity = {
	universe_id: number,
	ordered_data_store_id: string,
	scope_id: string,
	entry_id: string,
}

export type data_store = { path: string?, createTime: string?, expireTime: string?, state: string?, id: string? }
export type entry = {
	path: string?,
	id: string?,
	createTime: string?,
	revisionId: string?,
	revisionCreateTime: string?,
	state: string?,
	etag: string?,
	value: any,
	users: { string }?,
	attributes: any?,
}
export type ordered_entry = { path: string?, value: number?, id: string? }

type page_query = { maxPageSize: number?, pageToken: string?, filter: string? }

-- helpers
local function store_path(subject: store_identity)
	local path = `cloud/v2/universes/{subject.universe_id}/data-stores/{subject.data_store_id}`

	local scope = (subject :: any).scope_id
	return if scope then `{path}/scopes/{scope}` else path
end

-- functions
local function snapshot(session: auth.apikey_session, subject: universe.identity)
	local path = `cloud/v2/universes/{subject.universe_id}/data-stores:snapshot`
	return auth.request_json<<json>>(session, 'POST', path)
end
local function list_stores(session: auth.apikey_session, subject: universe.identity, query: page_query?)
	local path = `cloud/v2/universes/{subject.universe_id}/data-stores`
	return auth.request_json<<json>>(session, 'GET', path, query)
end

local function delete_store(session: auth.apikey_session, subject: store_identity)
	local path = `cloud/v2/universes/{subject.universe_id}/data-stores/{subject.data_store_id}`
	return auth.request_json<<data_store>>(session, 'DELETE', path)
end
local function undelete_store(session: auth.apikey_session, subject: store_identity)
	local path = `cloud/v2/universes/{subject.universe_id}/data-stores/{subject.data_store_id}:undelete`
	return auth.request_json<<data_store>>(session, 'POST', path)
end

local function list_entries(session: auth.apikey_session, subject: store_identity, query: page_query?)
	local path = `{store_path(subject)}/entries`
	return auth.request_json<<json>>(session, 'GET', path, query)
end

local function create_entry(session: auth.apikey_session, subject: store_identity, id: string?, data: entry)
	return auth.request_json<<entry>>(session, 'POST', `{store_path(subject)}/entries`, { id = id }, data)
end
local function get_entry(session: auth.apikey_session, subject: entry_identity)
	return auth.request_json<<entry>>(session, 'GET', `{store_path(subject)}/entries/{subject.entry_id}`)
end
local function delete_entry(session: auth.apikey_session, subject: entry_identity)
	local path = `{store_path(subject)}/entries/{subject.entry_id}`
	return auth.request_json<<nil>>(session, 'DELETE', path)
end

local function update_entry(session: auth.apikey_session, subject: entry_identity, data: entry, allow_missing: boolean?)
	local path = `{store_path(subject)}/entries/{subject.entry_id}`
	return auth.request_json<<entry>>(session, 'PATCH', path, { allowMissing = true }, data)
end
local function increment_entry(
	session: auth.apikey_session,
	subject: entry_identity,
	amount: number,
	users: { string }?,
	attributes: any?
)
	local path = `{store_path(subject)}/entries/{subject.entry_id}:increment`
	local data = { amount = amount, users = users, attributes = attributes }
	return auth.request_json<<entry>>(session, 'POST', path, nil, data)
end

local function list_entry_revisions(session: auth.apikey_session, subject: entry_identity, query: page_query?): json
	local path = `{store_path(subject)}/entries/{subject.entry_id}:listRevisions`
	return auth.request_json<<json>>(session, 'GET', path, query)
end

type ordered_page_query = { maxPageSize: number?, pageToken: string?, orderBy: string?, filter: string? }
local function list_ordered_entries(
	session: auth.apikey_session,
	subject: ordered_store_identity,
	query: ordered_page_query?
)
	local path =
		`cloud/v2/universes/{subject.universe_id}/ordered-data-stores/{subject.ordered_data_store_id}/scopes/{subject.scope_id}/entries`
	return auth.request_json<<json>>(session, 'GET', path, query)
end

local function create_ordered_entry(
	session: auth.apikey_session,
	subject: ordered_store_identity,
	id: string?,
	value: number
)
	local path =
		`cloud/v2/universes/{subject.universe_id}/ordered-data-stores/{subject.ordered_data_store_id}/scopes/{subject.scope_id}/entries`
	return auth.request_json<<ordered_entry>>(session, 'POST', path, { id = id }, { value = value })
end

local function get_ordered_entry(session: auth.apikey_session, subject: ordered_entry_identity)
	local path =
		`cloud/v2/universes/{subject.universe_id}/ordered-data-stores/{subject.ordered_data_store_id}/scopes/{subject.scope_id}/entries/{subject.entry_id}`
	return auth.request_json<<ordered_entry>>(session, 'GET', path)
end

local function update_ordered_entry(
	session: auth.apikey_session,
	subject: ordered_entry_identity,
	value: number,
	allow_missing: boolean?
)
	local query = { allowMissing = allow_missing }
	local path =
		`cloud/v2/universes/{subject.universe_id}/ordered-data-stores/{subject.ordered_data_store_id}/scopes/{subject.scope_id}/entries/{subject.entry_id}`
	return auth.request_json<<ordered_entry>>(session, 'PATCH', path, query, { value = value })
end

local function delete_ordered_entry(session: auth.apikey_session, subject: ordered_entry_identity)
	local path =
		`cloud/v2/universes/{subject.universe_id}/ordered-data-stores/{subject.ordered_data_store_id}/scopes/{subject.scope_id}/entries/{subject.entry_id}`
	return auth.request_json<<nil>>(session, 'DELETE', path)
end

local function increment_ordered_entry(session: auth.apikey_session, subject: ordered_entry_identity, amount: number)
	local path =
		`cloud/v2/universes/{subject.universe_id}/ordered-data-stores/{subject.ordered_data_store_id}/scopes/{subject.scope_id}/entries/{subject.entry_id}:increment`
	return auth.request_json<<ordered_entry>>(session, 'POST', path, nil, { amount = amount })
end

-- module
return table.freeze {
	list_stores = list_stores,
	delete_store = delete_store,
	undelete_store = undelete_store,
	snapshot = snapshot,
	list_entries = list_entries,
	create_entry = create_entry,
	get_entry = get_entry,
	update_entry = update_entry,
	delete_entry = delete_entry,
	increment_entry = increment_entry,
	list_entry_revisions = list_entry_revisions,
	list_ordered_entries = list_ordered_entries,
	create_ordered_entry = create_ordered_entry,
	get_ordered_entry = get_ordered_entry,
	update_ordered_entry = update_ordered_entry,
	delete_ordered_entry = delete_ordered_entry,
	increment_ordered_entry = increment_ordered_entry,
}
