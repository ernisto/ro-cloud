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
local function store_path(subject: store_identity | entry_identity)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/data-stores/{subject.data_store_id}`

	local scope = (subject :: any).scope_id
	if scope then
		url ..= `/scopes/{scope}`
	end

	local entry = (subject :: any).entry_id
	if entry then
		url ..= `entries/{entry}`
	end

	return url
end
local function ordered_store_path(subject: ordered_store_identity | ordered_entry_identity)
	local url =
		`https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/ordered-data-stores/{subject.ordered_data_store_id}`

	local scope = (subject :: any).scope_id
	if scope then
		url ..= `/scopes/{scope}`
	end

	local entry = (subject :: any).entry_id
	if entry then
		url ..= `entries/{entry}`
	end

	return url
end

-- functions
local function snapshot(session: auth.apikey_session, subject: universe.identity)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/data-stores:snapshot`
	return auth.request_json(session, 'POST', url) :: auth.http_result<json>
end
local function list_stores(session: auth.apikey_session, subject: universe.identity, query: page_query?)
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/data-stores`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<json>
end

local function delete_store(session: auth.apikey_session, subject: store_identity)
	local url = `{store_path(subject)}`
	return auth.request_json(session, 'DELETE', url) :: auth.http_result<data_store>
end
local function undelete_store(session: auth.apikey_session, subject: store_identity)
	local url = `{store_path(subject)}:undelete`
	return auth.request_json(session, 'POST', url) :: auth.http_result<data_store>
end

local function list_entries(session: auth.apikey_session, subject: store_identity, query: page_query?)
	local url = `{store_path(subject)}/entries`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<json>
end

local function create_entry(session: auth.apikey_session, subject: store_identity, id: string?, data: entry)
	local url = `{store_path(subject)}/entries`
	return auth.request_json(session, 'POST', url, { id = id }, data) :: auth.http_result<entry>
end
local function get_entry(session: auth.apikey_session, subject: entry_identity)
	local url = store_path(subject)
	return auth.request_json(session, 'GET', url) :: auth.http_result<entry>
end
local function delete_entry(session: auth.apikey_session, subject: entry_identity)
	local url = store_path(subject)
	return auth.request_json(session, 'DELETE', url) :: auth.http_result<nil>
end

local function update_entry(session: auth.apikey_session, subject: entry_identity, data: entry, allow_missing: boolean?)
	local url = store_path(subject)
	return auth.request_json(session, 'PATCH', url, { allowMissing = true }, data) :: auth.http_result<entry>
end
local function increment_entry(
	session: auth.apikey_session,
	subject: entry_identity,
	amount: number,
	users: { string }?,
	attributes: any?
)
	local url = `{store_path(subject)}:increment`
	local data = { amount = amount, users = users, attributes = attributes }
	return auth.request_json(session, 'POST', url, nil, data) :: auth.http_result<entry>
end

local function list_entry_revisions(session: auth.apikey_session, subject: entry_identity, query: page_query?): json
	local url = `{store_path(subject)}:listRevisions`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<json>
end

type ordered_page_query = { maxPageSize: number?, pageToken: string?, orderBy: string?, filter: string? }
local function list_ordered_entries(
	session: auth.apikey_session,
	subject: ordered_store_identity,
	query: ordered_page_query?
)
	local url = `{ordered_store_path(subject)}/entries`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<json>
end

local function create_ordered_entry(
	session: auth.apikey_session,
	subject: ordered_store_identity,
	id: string?,
	value: number
)
	local url = `{ordered_store_path(subject)}/entries`
	return auth.request_json(session, 'POST', url, { id = id }, { value = value }) :: auth.http_result<ordered_entry>
end

local function get_ordered_entry(session: auth.apikey_session, subject: ordered_entry_identity)
	local url = ordered_store_path(subject)
	return auth.request_json(session, 'GET', url) :: auth.http_result<ordered_entry>
end

local function update_ordered_entry(
	session: auth.apikey_session,
	subject: ordered_entry_identity,
	value: number,
	allow_missing: boolean?
)
	local query = { allowMissing = allow_missing }
	local url = ordered_store_path(subject)
	return auth.request_json(session, 'PATCH', url, query, { value = value }) :: auth.http_result<ordered_entry>
end

local function delete_ordered_entry(session: auth.apikey_session, subject: ordered_entry_identity)
	local url = ordered_store_path(subject)
	return auth.request_json(session, 'DELETE', url) :: auth.http_result<nil>
end

local function increment_ordered_entry(session: auth.apikey_session, subject: ordered_entry_identity, amount: number)
	local url = `{ordered_store_path(subject)}:increment`
	return auth.request_json(session, 'POST', url, nil, { amount = amount }) :: auth.http_result<ordered_entry>
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
