local web = require './web'

-- defs
type role_permissions = {
	viewWallPosts: boolean?,
	postToWall: boolean?,
	inviteMembers: boolean?,
	changeRank: boolean?,
	advertiseGroup: boolean?,
	manageRelationships: boolean?,
	addGroupPlaces: boolean?,
	viewAuditLog: boolean?,
	createItems: boolean?,
	manageItems: boolean?,
	spendGroupFunds: boolean?,
	manageGroupGames: boolean?,
	manageGroupUniverses: boolean?,
	viewGroupPayouts: boolean?,
	viewAnalytics: boolean?,
}

export type group_data = {
	path: string?,
	createTime: string?,
	updateTime: string?,
	id: string?,
	displayName: string?,
	description: string?,
	owner: string?,
	memberCount: number?,
	publicEntryAllowed: boolean?,
	locked: boolean?,
	verified: boolean?,
}

export type membership_data = { path: string?, createTime: string?, updateTime: string?, user: string?, role: string? }
export type membership_patch = { role: string }

export type role_data = {
	path: string?,
	createTime: string?,
	updateTime: string?,
	id: string?,
	displayName: string?,
	description: string?,
	rank: number?,
	memberCount: number?,
	permissions: role_permissions?,
}

export type shout_data = { path: string?, createTime: string?, updateTime: string?, content: string?, poster: string? }

export type join_request_data = { path: string?, createTime: string?, user: string? }

-- TODO: complete from Roblox cloud docs
export type roles_page = { groupRoles: { role_data }, nextPageToken: string? }
-- TODO: complete from Roblox cloud docs
export type memberships_page = { groupMemberships: { membership_data }, nextPageToken: string? }
-- TODO: complete from Roblox cloud docs
export type join_requests_page = { groupJoinRequests: { join_request_data }, nextPageToken: string? }

local GROUP = 'https://apis.roblox.com/cloud/v2/groups/{group_id}'

local JOIN_REQUEST = table.freeze { group_id = 0, join_request_id = '' }
type join_request_path = typeof(JOIN_REQUEST)

local NONE: web.auth_spec = { apikey = { scope = {} } }
local READ: web.auth_spec = { apikey = { scope = { ['group:read'] = true } } }
local WRITE: web.auth_spec = { apikey = { scope = { ['group:write'] = true } } }

local GROUP_PATH = table.freeze { group_id = 0 }
local PAGE = table.freeze { maxPageSize = 0 :: number?, pageToken = '' :: string?, filter = '' :: string? }
type group_path = typeof(GROUP_PATH)
export type page_query = typeof(PAGE)

-- module
return table.freeze {
	get = web.endpoint<<group_path, nil, nil, group_data>> {
		base = GROUP,
		method = 'GET',
		auth = NONE,
		ratelimit = { apikey = 150 },
		path = GROUP_PATH,
	},

	get_shout = web.endpoint<<group_path, nil, nil, shout_data>> {
		base = `{GROUP}/shout`,
		method = 'GET',
		auth = READ,
		path = GROUP_PATH,
	},

	list_roles = web.endpoint<<group_path, page_query, nil, roles_page>> {
		base = `{GROUP}/roles`,
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 300 },
		path = GROUP_PATH,
		query = PAGE,
	},

	get_role = web.endpoint<<{ group_id: number, role_id: string }, nil, nil, role_data>> {
		base = `{GROUP}/roles/\{role_id}`,
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 300 },
		path = { group_id = 0, role_id = '' },
	},

	list_memberships = web.endpoint<<group_path, page_query, nil, memberships_page>> {
		base = `{GROUP}/memberships`,
		method = 'GET',
		auth = NONE,
		ratelimit = { apikey = 300 },
		path = GROUP_PATH,
		query = PAGE,
	},

	update_membership = web.endpoint<<{ group_id: number, membership_id: string }, nil, membership_patch, membership_data>> {
		base = `{GROUP}/memberships/\{membership_id}`,
		method = 'PATCH',
		auth = WRITE,
		ratelimit = { apikey = 300 },
		path = { group_id = 0, membership_id = '' },
		content_type = 'application/json',
	},

	list_join_requests = web.endpoint<<group_path, page_query, nil, join_requests_page>> {
		base = `{GROUP}/join-requests`,
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 300 },
		path = GROUP_PATH,
		query = PAGE,
	},

	accept_join_request = web.endpoint<<join_request_path, nil, nil, nil>> {
		base = `{GROUP}/join-requests/\{join_request_id}:accept`,
		method = 'POST',
		auth = WRITE,
		ratelimit = { apikey = 100 },
		path = JOIN_REQUEST,
		content_type = 'application/json',
	},

	decline_join_request = web.endpoint<<join_request_path, nil, nil, nil>> {
		base = `{GROUP}/join-requests/\{join_request_id}:decline`,
		method = 'POST',
		auth = WRITE,
		ratelimit = { apikey = 100 },
		path = JOIN_REQUEST,
		content_type = 'application/json',
	},
}
