local auth = require './auth'

-- defs
export type identity = { group_id: number }
export type membership_identity = { group_id: number, membership_id: string }
export type role_identity = { group_id: number, role_id: string }
export type join_request_identity = { group_id: number, join_request_id: string }

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

export type group = {
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

export type membership = { path: string?, createTime: string?, updateTime: string?, user: string?, role: string? }

export type role = {
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

export type shout = { path: string?, createTime: string?, updateTime: string?, content: string?, poster: string? }

export type join_request = { path: string?, createTime: string?, user: string? }

type page_query = { maxPageSize: number?, pageToken: string? }

-- functions
local function get(session: auth.apikey_session | auth.oauth2_session, subject: identity)
	return auth.request_json(session, 'GET', `cloud/v2/groups/{subject.group_id}`) :: auth.http_result<group>
end

local function get_shout(session: auth.apikey_session | auth.oauth2_session, subject: identity)
	return auth.request_json(session, 'GET', `cloud/v2/groups/{subject.group_id}/shout`) :: auth.http_result<shout>
end

local function list_roles(session: auth.apikey_session | auth.oauth2_session, subject: identity, query: page_query?)
	return auth.request_json(
			session,
			'GET',
			`cloud/v2/groups/{subject.group_id}/roles`,
			query
		) :: auth.http_result<auth.json_object>
end

local function get_role(session: auth.apikey_session | auth.oauth2_session, subject: role_identity)
	return auth.request_json(
			session,
			'GET',
			`cloud/v2/groups/{subject.group_id}/roles/{subject.role_id}`
		) :: auth.http_result<role>
end

local function list_memberships(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	query: page_query?
)
	local path = `cloud/v2/groups/{subject.group_id}/memberships`
	return auth.request_json(session, 'GET', path, query) :: auth.http_result<auth.json_object>
end

local function update_membership(
	session: auth.apikey_session | auth.oauth2_session,
	subject: membership_identity,
	data: membership
)
	local path = `cloud/v2/groups/{subject.group_id}/memberships/{subject.membership_id}`
	return auth.request_json(session, 'PATCH', path, nil, data) :: auth.http_result<membership>
end

local function list_join_requests(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	query: page_query?
)
	local path = `cloud/v2/groups/{subject.group_id}/join-requests`
	return auth.request_json(session, 'GET', path, query) :: auth.http_result<auth.json_object>
end

local function accept_join_request(session: auth.apikey_session | auth.oauth2_session, subject: join_request_identity)
	local path = `cloud/v2/groups/{subject.group_id}/join-requests/{subject.join_request_id}:accept`
	return auth.request_json(session, 'POST', path) :: auth.http_result<nil>
end

local function decline_join_request(session: auth.apikey_session | auth.oauth2_session, subject: join_request_identity)
	local path = `cloud/v2/groups/{subject.group_id}/join-requests/{subject.join_request_id}:decline`
	return auth.request_json(session, 'POST', path) :: auth.http_result<nil>
end

-- module
return table.freeze {
	get = get,
	get_shout = get_shout,
	list_roles = list_roles,
	get_role = get_role,
	list_memberships = list_memberships,
	update_membership = update_membership,
	list_join_requests = list_join_requests,
	accept_join_request = accept_join_request,
	decline_join_request = decline_join_request,
}
