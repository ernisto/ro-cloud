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
	local url =
		`https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/memory-store/queues/{subject.queue_id}/items`
	return auth.request_json(session, 'POST', url, item) :: auth.http_result<queue_item>
end

type params = { count: number?, allOrNothing: boolean?, invisibilityWindow: string? }

local function read_queue(session: auth.apikey_session, subject: queue_identity, params: params)
	local url =
		`https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/memory-store/queues/{subject.queue_id}/items:read`
	return auth.request_json(session, 'GET', url, params) :: auth.http_result<auth.json_object>
end

local function discard_queue(session: auth.apikey_session, subject: queue_identity, read_id: string)
	local url =
		`https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/memory-store/queues/{subject.queue_id}/items:discard`
	return auth.request_json(session, 'POST', url, { readId = read_id }) :: auth.http_result<nil>
end

local function list_sorted_map(session: auth.apikey_session, subject: sorted_map_identity, query: ordered_page_query?)
	local url =
		`https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<auth.json_object>
end

local function get_sorted_map_item(session: auth.apikey_session, subject: sorted_map_item_identity)
	local url =
		`https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items/{subject.item_id}`
	return auth.request_json(session, 'GET', url) :: auth.http_result<sorted_map_item>
end

local function set_sorted_map_item(
	session: auth.apikey_session,
	subject: sorted_map_identity,
	id: string?,
	item: sorted_map_item
)
	local url =
		`https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items`
	return auth.request_json(session, 'POST', url, { id = id }, item) :: auth.http_result<sorted_map_item>
end

local function update_sorted_map_item(
	session: auth.apikey_session,
	subject: sorted_map_item_identity,
	item: sorted_map_item,
	allow_missing: boolean?
)
	local url =
		`https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items/{subject.item_id}`
	return auth.request_json(
			session,
			'PATCH',
			url,
			{ allowMissing = allow_missing },
			item
		) :: auth.http_result<sorted_map_item>
end

local function delete_sorted_map_item(session: auth.apikey_session, subject: sorted_map_item_identity)
	local url =
		`https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/memory-store/sorted-maps/{subject.sorted_map_id}/items/{subject.item_id}`
	return auth.request_json(session, 'DELETE', url) :: auth.http_result<nil>
end

local function flush(session: auth.apikey_session, subject: { universe_id: number })
	local url = `https://apis.roblox.com/cloud/v2/universes/{subject.universe_id}/memory-store:flush`
	return auth.request_json(session, 'POST', url) :: auth.http_result<auth.json_object>
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
