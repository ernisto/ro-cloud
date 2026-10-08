local web = require './web'
type endpoint<P, Q, B, R> = web.endpoint<P, Q, B, R>

-- defs
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

-- TODO: complete from Roblox cloud docs
export type queue_read = { items: { queue_item }?, readId: string? }
-- TODO: complete from Roblox cloud docs
export type sorted_map_page = { items: { sorted_map_item }, nextPageToken: string? }

local QUEUE = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/memory-store/queues/{queue_id}/items'
local MAP = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/memory-store/sorted-maps/{sorted_map_id}/items'

local RATELIMIT: web.ratelimit = { apikey = 1_000_000 }
local function scoped(scope: string): web.auth_spec
	return { apikey = { scope = { [scope] = true } } }
end

local QUEUE_ADD = scoped 'memory-store.queue:add'
local QUEUE_DEQUEUE = scoped 'memory-store.queue:dequeue'
local QUEUE_DISCARD = scoped 'memory-store.queue:discard'
local MAP_READ = scoped 'memory-store.sorted-map:read'
local MAP_WRITE = scoped 'memory-store.sorted-map:write'
local FLUSH = scoped 'memory-store:flush'

local QUEUE_PATH = table.freeze { universe_id = 0, queue_id = '' }
local MAP_PATH = table.freeze { universe_id = 0, sorted_map_id = '' }
local ITEM_PATH = table.freeze { universe_id = 0, sorted_map_id = '', item_id = '' }
local READ = table.freeze { count = 0 :: number?, allOrNothing = false :: boolean?, invisibilityWindow = '' :: string? }
local ORDERED_PAGE = table.freeze {
	maxPageSize = 0 :: number?,
	pageToken = '' :: string?,
	orderBy = '' :: string?,
	filter = '' :: string?,
}
type queue_path = typeof(QUEUE_PATH)
type map_path = typeof(MAP_PATH)
type item_path = typeof(ITEM_PATH)
export type read_query = typeof(READ)
export type ordered_page_query = typeof(ORDERED_PAGE)

-- module
return table.freeze {
	enqueue = web.endpoint {
		base = QUEUE,
		method = 'POST',
		auth = QUEUE_ADD,
		ratelimit = RATELIMIT,
		path = QUEUE_PATH,
		content_type = 'application/json',
	} :: endpoint<queue_path, nil, queue_item, queue_item>,

	read_queue = web.endpoint {
		base = `{QUEUE}:read`,
		method = 'GET',
		auth = QUEUE_DEQUEUE,
		ratelimit = RATELIMIT,
		path = QUEUE_PATH,
		query = READ,
	} :: endpoint<queue_path, read_query, nil, queue_read>,

	discard_queue = web.endpoint {
		base = `{QUEUE}:discard`,
		method = 'POST',
		auth = QUEUE_DISCARD,
		ratelimit = RATELIMIT,
		path = QUEUE_PATH,
		content_type = 'application/json',
	} :: endpoint<queue_path, nil, { readId: string }, nil>,

	list_sorted_map = web.endpoint {
		base = MAP,
		method = 'GET',
		auth = MAP_READ,
		ratelimit = RATELIMIT,
		path = MAP_PATH,
		query = ORDERED_PAGE,
	} :: endpoint<map_path, ordered_page_query, nil, sorted_map_page>,

	get_sorted_map_item = web.endpoint {
		base = `{MAP}/\{item_id}`,
		method = 'GET',
		auth = MAP_READ,
		ratelimit = RATELIMIT,
		path = ITEM_PATH,
	} :: endpoint<item_path, nil, nil, sorted_map_item>,

	set_sorted_map_item = web.endpoint {
		base = MAP,
		method = 'POST',
		auth = MAP_WRITE,
		ratelimit = RATELIMIT,
		path = MAP_PATH,
		query = { id = '' :: string? },
		content_type = 'application/json',
	} :: endpoint<map_path, { id: string? }, sorted_map_item, sorted_map_item>,

	update_sorted_map_item = web.endpoint {
		base = `{MAP}/\{item_id}`,
		method = 'PATCH',
		auth = MAP_WRITE,
		ratelimit = RATELIMIT,
		path = ITEM_PATH,
		query = { allowMissing = false :: boolean? },
		content_type = 'application/json',
	} :: endpoint<item_path, { allowMissing: boolean? }, sorted_map_item, sorted_map_item>,

	delete_sorted_map_item = web.endpoint {
		base = `{MAP}/\{item_id}`,
		method = 'DELETE',
		auth = MAP_WRITE,
		ratelimit = RATELIMIT,
		path = ITEM_PATH,
	} :: endpoint<item_path, nil, nil, nil>,

	flush = web.endpoint {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/memory-store:flush',
		method = 'POST',
		auth = FLUSH,
		ratelimit = RATELIMIT,
		path = { universe_id = 0 },
	} :: endpoint<{ universe_id: number }, nil, nil, { [string]: any }>,
}
