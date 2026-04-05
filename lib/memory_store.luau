local auth = require './auth'

-- defs
export type queue_identity = { universe_id: number, queue_id: string }
export type sorted_map_identity = { universe_id: number, sorted_map_id: string }
export type sorted_map_item_identity = { universe_id: number, sorted_map_id: string, item_id: string }

export type queue_item = {
	path: string?,
	data: any,
	priority: number?,
	ttl: string?,
	expireTime: string?,
	id: string?,
}
export type sorted_map_item = {
	path: string?,
	value: any,
	etag: string?,
	ttl: string?,
	expireTime: string?,
	id: string?,
	stringSortKey: string?,
	numericSortKey: number?,
}

-- functions
local function enqueue(session: auth.apikey_session, subject: queue_identity, item: queue_item): queue_item
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store/queues/{subject.queue_id}/items`
	return auth.request_json(session, path, 'POST', item) :: any
end

local function read_queue(
	session: auth.apikey_session,
	subject: queue_identity,
	count: number?,
	all_or_nothing: boolean?,
	invisibility_window: string?
): auth.json_object
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store/queues/{subject.queue_id}/items:read`
	local params = {}

	if count then table.insert(params, `count={count}`) end
	if all_or_nothing ~= nil then table.insert(params, `allOrNothing={if all_or_nothing then 'true' else 'false'}`) end
	if invisibility_window then table.insert(params, `invisibilityWindow={invisibility_window}`) end

	if #params > 0 then
		path ..= '?' .. table.concat(params, '&')
	end
	return auth.request_json(session, path, 'GET') :: any
end

local function discard_queue(session: auth.apikey_session, subject: queue_identity, read_id: string)
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store/queues/{subject.queue_id}/items:discard`
	auth.request_json(session, path, 'POST', { readId = read_id })
end

local function list_sorted_map(
	session: auth.apikey_session,
	subject: sorted_map_identity,
	query: { max_page_size: number?, page_token: string?, order_by: string?, filter: string? }?
): auth.json_object
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items`
	local params = {}

	if query then
		if query.max_page_size then table.insert(params, `maxPageSize={query.max_page_size}`) end
		if query.page_token then table.insert(params, `pageToken={query.page_token}`) end
		if query.order_by then table.insert(params, `orderBy={query.order_by}`) end
		if query.filter then table.insert(params, `filter={query.filter}`) end
	end
	if #params > 0 then
		path ..= '?' .. table.concat(params, '&')
	end
	return auth.request_json(session, path, 'GET') :: any
end

local function get_sorted_map_item(session: auth.apikey_session, subject: sorted_map_item_identity): sorted_map_item
	local path =
		`cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items/{subject.item_id}`
	return auth.request_json(session, path, 'GET') :: any
end

local function set_sorted_map_item(
	session: auth.apikey_session,
	subject: sorted_map_identity,
	id: string?,
	item: sorted_map_item
): sorted_map_item
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items`
	if id then path = `{path}?id={id}` end

	return auth.request_json(session, path, 'POST', item) :: any
end

local function update_sorted_map_item(
	session: auth.apikey_session,
	subject: sorted_map_item_identity,
	item: sorted_map_item,
	allow_missing: boolean?
): sorted_map_item
	local path =
		`cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items/{subject.item_id}`
	if allow_missing then
		path ..= '?allowMissing=true'
	end
	return auth.request_json(session, path, 'PATCH', item) :: any
end

local function delete_sorted_map_item(session: auth.apikey_session, subject: sorted_map_item_identity)
	local path =
		`cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items/{subject.item_id}`
	auth.request_json(session, path, 'DELETE')
end

local function flush(session: auth.apikey_session, subject: { universe_id: number }): auth.json_object
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store:flush`
	return auth.request_json(session, path, 'POST') :: any
end

-- module
return table.freeze {
	enqueue = enqueue,
	read_queue = read_queue,
	discard_queue = discard_queue,
	list_sorted_map = list_sorted_map,
	get_sorted_map_item = get_sorted_map_item,
	set_sorted_map_item = set_sorted_map_item,
	update_sorted_map_item = update_sorted_map_item,
	delete_sorted_map_item = delete_sorted_map_item,
	flush = flush,
}
