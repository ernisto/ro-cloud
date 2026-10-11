local web = require './web'

-- defs
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
export type increment = { amount: number, users: { string }?, attributes: any? }

-- TODO: complete from Roblox cloud docs
export type stores_page = { dataStores: { data_store }, nextPageToken: string? }
-- TODO: complete from Roblox cloud docs
export type entries_page = { dataStoreEntries: { entry }, nextPageToken: string? }
-- TODO: complete from Roblox cloud docs
export type entry_revisions_page = { dataStoreEntries: { entry }, nextPageToken: string? }
-- TODO: complete from Roblox cloud docs
export type ordered_entries_page = { orderedDataStoreEntries: { ordered_entry }, nextPageToken: string? }
-- TODO: complete from Roblox cloud docs
export type snapshot_result = { newSnapshotTaken: boolean?, latestSnapshotTime: string? }

local STORE = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/data-stores/{data_store_id}'
local SCOPED = `{STORE}/scopes/\{scope_id}`
local ORDERED =
	'https://apis.roblox.com/cloud/v2/universes/{universe_id}/ordered-data-stores/{ordered_data_store_id}/scopes/{scope_id}'

local RATELIMIT: web.ratelimit = { apikey = 1_000_000 }
local function scoped(scope: string): web.auth_spec
	return { apikey = { scope = { [scope] = true } } }
end

local CONTROL_SNAPSHOT = scoped 'universe-datastores.control:snapshot'
local CONTROL_LIST = scoped 'universe-datastores.control:list'
local CONTROL_DELETE = scoped 'universe-datastores.control:delete'
local OBJECTS_LIST = scoped 'universe-datastores.objects:list'
local OBJECTS_CREATE = scoped 'universe-datastores.objects:create'
local OBJECTS_READ = scoped 'universe-datastores.objects:read'
local OBJECTS_UPDATE = scoped 'universe-datastores.objects:update'
local OBJECTS_DELETE = scoped 'universe-datastores.objects:delete'
local VERSIONS_LIST = scoped 'universe-datastores.versions:list'
local OBJECTS_INCREMENT: web.auth_spec = {
	apikey = {
		scope = { ['universe-datastores.objects:create'] = true, ['universe-datastores.objects:update'] = true },
	},
}
local ORDERED_READ = scoped 'universe.ordered-data-store.scope.entry:read'
local ORDERED_WRITE = scoped 'universe.ordered-data-store.scope.entry:write'

local UNIVERSE = table.freeze { universe_id = 0 }
local STORE_PATH = table.freeze { universe_id = 0, data_store_id = '' }
local SCOPE_PATH = table.freeze { universe_id = 0, data_store_id = '', scope_id = '' :: string? }
local ENTRY_PATH = table.freeze { universe_id = 0, data_store_id = '', scope_id = '' :: string?, entry_id = '' }
local ORDERED_PATH = table.freeze { universe_id = 0, ordered_data_store_id = '', scope_id = '' }
local ORDERED_ENTRY_PATH = table.freeze { universe_id = 0, ordered_data_store_id = '', scope_id = '', entry_id = '' }
local PAGE = table.freeze {
	maxPageSize = 0 :: number?,
	pageToken = '' :: string?,
	filter = '' :: string?,
	showDeleted = false :: boolean?,
}
local ORDERED_PAGE = table.freeze {
	maxPageSize = 0 :: number?,
	pageToken = '' :: string?,
	orderBy = '' :: string?,
	filter = '' :: string?,
}
local ALLOW_MISSING = table.freeze { allowMissing = false :: boolean? }
type universe_path = typeof(UNIVERSE)
type store_path = typeof(STORE_PATH)
type scope_path = typeof(SCOPE_PATH)
type entry_path = typeof(ENTRY_PATH)
type ordered_path = typeof(ORDERED_PATH)
type ordered_entry_path = typeof(ORDERED_ENTRY_PATH)
export type page_query = typeof(PAGE)
export type ordered_page_query = typeof(ORDERED_PAGE)
export type allow_missing_query = typeof(ALLOW_MISSING)

-- helpers
-- `scope_id` is an optional path segment, so the base is picked per request
local function store_request(suffix: string)
	return function(self: any, auth: web.auth, path: scope_path, body: any, query: any): web.request
		local base = (if path.scope_id then SCOPED else STORE) .. suffix
		return web.build(self, auth, { base = base, path = path, body = body, query = query })
	end
end
local entries_request = store_request '/entries'
local entry_request = store_request '/entries/{entry_id}'

-- module
return table.freeze {
	snapshot = web.endpoint<<universe_path, nil, nil, snapshot_result>> {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/data-stores:snapshot',
		method = 'POST',
		auth = CONTROL_SNAPSHOT,
		ratelimit = { apikey = 60 },
		path = UNIVERSE,
		content_type = 'application/json',
	},

	list_stores = web.endpoint<<universe_path, page_query, nil, stores_page>> {
		base = 'https://apis.roblox.com/cloud/v2/universes/{universe_id}/data-stores',
		method = 'GET',
		auth = CONTROL_LIST,
		ratelimit = RATELIMIT,
		path = UNIVERSE,
		query = PAGE,
	},

	delete_store = web.endpoint<<store_path, nil, nil, data_store>> {
		base = STORE,
		method = 'DELETE',
		auth = CONTROL_DELETE,
		ratelimit = RATELIMIT,
		path = STORE_PATH,
	},

	undelete_store = web.endpoint<<store_path, nil, nil, data_store>> {
		base = `{STORE}:undelete`,
		method = 'POST',
		auth = CONTROL_DELETE,
		ratelimit = RATELIMIT,
		path = STORE_PATH,
		content_type = 'application/json',
	},

	list_entries = web.endpoint<<scope_path, page_query, nil, entries_page>> {
		base = `{STORE}/entries`,
		method = 'GET',
		auth = OBJECTS_LIST,
		ratelimit = RATELIMIT,
		path = SCOPE_PATH,
		query = PAGE,
		request = entries_request,
	},

	create_entry = web.endpoint<<scope_path, { id: string? }, entry, entry>> {
		base = `{STORE}/entries`,
		method = 'POST',
		auth = OBJECTS_CREATE,
		ratelimit = RATELIMIT,
		path = SCOPE_PATH,
		query = { id = '' :: string? },
		content_type = 'application/json',
		request = entries_request,
	},

	get_entry = web.endpoint<<entry_path, nil, nil, entry>> {
		base = `{STORE}/entries/\{entry_id}`,
		method = 'GET',
		auth = OBJECTS_READ,
		ratelimit = RATELIMIT,
		path = ENTRY_PATH,
		request = entry_request,
	},

	update_entry = web.endpoint<<entry_path, allow_missing_query, entry, entry>> {
		base = `{STORE}/entries/\{entry_id}`,
		method = 'PATCH',
		auth = OBJECTS_UPDATE,
		ratelimit = RATELIMIT,
		path = ENTRY_PATH,
		query = ALLOW_MISSING,
		content_type = 'application/json',
		request = entry_request,
	},

	delete_entry = web.endpoint<<entry_path, nil, nil, nil>> {
		base = `{STORE}/entries/\{entry_id}`,
		method = 'DELETE',
		auth = OBJECTS_DELETE,
		ratelimit = RATELIMIT,
		path = ENTRY_PATH,
		request = entry_request,
	},

	increment_entry = web.endpoint<<entry_path, nil, increment, entry>> {
		base = `{STORE}/entries/\{entry_id}:increment`,
		method = 'POST',
		auth = OBJECTS_INCREMENT,
		ratelimit = RATELIMIT,
		path = ENTRY_PATH,
		content_type = 'application/json',
		request = store_request '/entries/{entry_id}:increment',
	},

	list_entry_revisions = web.endpoint<<entry_path, page_query, nil, entry_revisions_page>> {
		base = `{STORE}/entries/\{entry_id}:listRevisions`,
		method = 'GET',
		auth = VERSIONS_LIST,
		ratelimit = RATELIMIT,
		path = ENTRY_PATH,
		query = PAGE,
		request = store_request '/entries/{entry_id}:listRevisions',
	},

	list_ordered_entries = web.endpoint<<ordered_path, ordered_page_query, nil, ordered_entries_page>> {
		base = `{ORDERED}/entries`,
		method = 'GET',
		auth = ORDERED_READ,
		ratelimit = RATELIMIT,
		path = ORDERED_PATH,
		query = ORDERED_PAGE,
	},

	create_ordered_entry = web.endpoint<<ordered_path, { id: string }, { value: number }, ordered_entry>> {
		base = `{ORDERED}/entries`,
		method = 'POST',
		auth = ORDERED_WRITE,
		ratelimit = RATELIMIT,
		path = ORDERED_PATH,
		query = { id = '' },
		content_type = 'application/json',
	},

	get_ordered_entry = web.endpoint<<ordered_entry_path, nil, nil, ordered_entry>> {
		base = `{ORDERED}/entries/\{entry_id}`,
		method = 'GET',
		auth = ORDERED_READ,
		ratelimit = RATELIMIT,
		path = ORDERED_ENTRY_PATH,
	},

	update_ordered_entry = web.endpoint<<ordered_entry_path, allow_missing_query, { value: number }, ordered_entry>> {
		base = `{ORDERED}/entries/\{entry_id}`,
		method = 'PATCH',
		auth = ORDERED_WRITE,
		ratelimit = RATELIMIT,
		path = ORDERED_ENTRY_PATH,
		query = ALLOW_MISSING,
		content_type = 'application/json',
	},

	delete_ordered_entry = web.endpoint<<ordered_entry_path, nil, nil, nil>> {
		base = `{ORDERED}/entries/\{entry_id}`,
		method = 'DELETE',
		auth = ORDERED_WRITE,
		ratelimit = RATELIMIT,
		path = ORDERED_ENTRY_PATH,
	},

	increment_ordered_entry = web.endpoint<<ordered_entry_path, nil, { amount: number }, ordered_entry>> {
		base = `{ORDERED}/entries/\{entry_id}:increment`,
		method = 'POST',
		auth = ORDERED_WRITE,
		ratelimit = RATELIMIT,
		path = ORDERED_ENTRY_PATH,
		content_type = 'application/json',
	},
}
