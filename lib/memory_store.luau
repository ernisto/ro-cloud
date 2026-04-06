local auth = require './auth'

-- defs
export type queue_identity = { universe_id: number, queue_id: string }
export type sorted_map_identity = { universe_id: number, sorted_map_id: string }
export type sorted_map_item_identity = { universe_id: number, sorted_map_id: string, item_id: string }

type ordered_page_query = { maxPageSize: number?, pageToken: string?, orderBy: string?, filter: string? }
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
local function enqueue(session: auth.apikey_session, subject: queue_identity, item: queue_item)
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store/queues/{subject.queue_id}/items`
	return auth.request_json<<queue_item>>(session, 'POST', path, item)
end

type params = { count: number?, allOrNothing: boolean?, invisibilityWindow: string? }

local function read_queue(session: auth.apikey_session, subject: queue_identity, params: params)
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store/queues/{subject.queue_id}/items:read`
	return auth.request_json<<auth.json_object>>(session, 'GET', path, params)
end

local function discard_queue(session: auth.apikey_session, subject: queue_identity, read_id: string)
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store/queues/{subject.queue_id}/items:discard`
	return auth.request_json<<nil>>(session, 'POST', path, { readId = read_id })
end

local function list_sorted_map(session: auth.apikey_session, subject: sorted_map_identity, query: ordered_page_query?)
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items`
	return auth.request_json<<auth.json_object>>(session, 'GET', path, query)
end

local function get_sorted_map_item(session: auth.apikey_session, subject: sorted_map_item_identity)
	local path =
		`cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items/{subject.item_id}`
	return auth.request_json<<sorted_map_item>>(session, 'GET', path)
end

local function set_sorted_map_item(
	session: auth.apikey_session,
	subject: sorted_map_identity,
	id: string?,
	item: sorted_map_item
)
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items`
	return auth.request_json<<sorted_map_item>>(session, 'POST', path, { id = id }, item)
end

local function update_sorted_map_item(
	session: auth.apikey_session,
	subject: sorted_map_item_identity,
	item: sorted_map_item,
	allow_missing: boolean?
)
	local path =
		`cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items/{subject.item_id}`
	return auth.request_json<<sorted_map_item>>(session, 'PATCH', path, { allowMissing = allow_missing }, item)
end

local function delete_sorted_map_item(session: auth.apikey_session, subject: sorted_map_item_identity)
	local path =
		`cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items/{subject.item_id}`
	return auth.request_json<<nil>>(session, 'DELETE', path)
end

local function flush(session: auth.apikey_session, subject: { universe_id: number })
	local path = `cloud/v2/universes/{subject.universe_id}/memory-store:flush`
	return auth.request_json<<auth.json_object>>(session, 'POST', path)
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
