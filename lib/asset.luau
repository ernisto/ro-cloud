local auth = require './auth'
local operation = require './operation'
local serde = require '@lune/serde'

-- defs
export type identity = { asset_id: number }

type creation_context = { creator: string?, expectedPrice: number? }
type moderation_result = { moderationState: string? }
type preview = { asset: string?, altText: string? }
type social_link = { title: string?, uri: string? }

export type asset_data = {
	assetType: string,
	assetId: number?,
	displayName: string,
	description: string?,
	creationContext: creation_context?,
	path: string?,
	revisionId: string?,
	revisionCreateTime: string?,
	moderationResult: moderation_result?,
	icon: string?,
	previews: { preview }?,
	state: string?,
	socialLink: social_link?,
}

export type asset_version = {
	path: string?,
	creationContext: creation_context?,
	moderationResult: moderation_result?,
	published: boolean?,
}

type operation_error = { code: number, message: string, details: { any }? }
export type asset_operation = {
	path: string,
	done: boolean?,
	error: operation_error?,
	response: asset_data?,
}

-- functions
local function create(
	session: auth.apikey_session | auth.oauth2_session,
	asset: asset_data,
	file: buffer
): asset_operation
	return auth.request_form(session, 'assets/v1/assets', 'POST', {
		request = serde.encode('json', asset),
		fileContent = file,
	})
end

local function update(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	asset: asset_data,
	file: buffer?,
	update_mask: string?
): asset_operation
	local path = `assets/v1/assets/{subject.asset_id}`
	local query = if update_mask then { updateMask = update_mask } else nil

	local fields = { request = serde.encode('json', asset) }
	if file then fields.fileContent = file end

	return auth.request_form(session, path, 'PATCH', fields, query)
end

local function get(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	read_mask: string?
): asset_data
	local path = `assets/v1/assets/{subject.asset_id}`
	return auth.request_json(session, path, 'GET', nil, { readMask = read_mask })
end

local function archive(session: auth.apikey_session | auth.oauth2_session, subject: identity): asset_data
	return auth.request_json(session, `assets/v1/assets/{subject.asset_id}:archive`, 'POST')
end

local function restore(session: auth.apikey_session | auth.oauth2_session, subject: identity): asset_data
	return auth.request_json(session, `assets/v1/assets/{subject.asset_id}:restore`, 'POST')
end

local function get_version(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	version: string
): asset_version
	return auth.request_json(session, `assets/v1/assets/{subject.asset_id}/versions/{version}`, 'GET')
end

local function list_versions(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	query: { maxPageSize: number?, pageToken: string? }?
): auth.json_object
	local path = `assets/v1/assets/{subject.asset_id}/versions`
	return auth.request_json(session, path, 'GET', nil, query)
end

local function rollback(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	asset_version_path: string
): asset_version
	local path = `assets/v1/assets/{subject.asset_id}/versions:rollback`
	return auth.request_form(session, path, 'POST', { assetVersion = asset_version_path })
end

local function get_operation(session: auth.apikey_session | auth.oauth2_session, operation_id: string): asset_operation
	return auth.request_json(session, `assets/v1/operations/{operation_id}`, 'GET')
end

local function wait_for_operation(
	session: auth.apikey_session | auth.oauth2_session,
	operation_id: string
): asset_operation?
	return operation.poll_for_result(session, `assets/v1/operations/{operation_id}`) :: any
end

-- module
return table.freeze {
	create = create,
	update = update,
	get = get,
	archive = archive,
	restore = restore,
	get_version = get_version,
	list_versions = list_versions,
	rollback = rollback,
	get_operation = get_operation,
	wait_for_operation = wait_for_operation,
}
