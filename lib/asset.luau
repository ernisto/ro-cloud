local auth = require './auth'
local serde = require '@lune/serde'

-- defs
export type identity = { asset_id: number }

type creation_context = { creator: string?, expectedPrice: number? }
type moderation_result = { moderationState: string? }
type preview = { asset: string?, altText: string? }
type social_link = { title: string?, uri: string? }

export type asset_data = {
	assetType: string,
	assetId: number,
	displayName: string,
	description: string,
	creationContext: creation_context,
	path: string,
	revisionId: string,
	revisionCreateTime: string,
	moderationResult: moderation_result,
	icon: string,
	previews: { preview },
	state: string,
	socialLink: social_link,
}
export type asset_data_patch = {
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
export type asset_operation =
	| { path: string, done: false, error: operation_error }
	| { path: string, done: true, response: asset_data }

type download_res = { location: string, errors: nil } | { location: nil, errors: any }

-- functions
local function download(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity & { version: number? }
): buffer
	local url = `asset-delivery-api/v1/assetId/{subject.asset_id}`
	local data: download_res = auth.request_json(session, url, 'GET', nil, { version = subject.version })

	if data.location == nil then error(`Http error [{data.errors[1].code}]: {data.errors[1].message}`) end
	local response = auth.request(session, data.location, 'GET')

	assert(response.ok, `error [{response.statusCode}]: {response.statusMessage}`)
	return buffer.fromstring(response.body)
end

local function create(
	session: auth.apikey_session | auth.oauth2_session,
	asset: asset_data_patch,
	content: buffer
): asset_operation
	return auth.request_form(session, 'assets/v1/assets', 'POST', {
		request = serde.encode('json', asset),
		fileContent = content,
	})
end
local function update(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	asset: asset_data_patch,
	content: buffer?
): asset_operation
	local path = `assets/v1/assets/{subject.asset_id}`
	local query = { updateMask = auth.mask_from(asset) }

	local fields = { request = serde.encode('json', asset) }
	if content then fields.fileContent = content end

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

local function rollback(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	version: number
): asset_version
	local path = `assets/v1/assets/{subject.asset_id}/versions:rollback`
	return auth.request_form(session, path, 'POST', { assetVersion = `assets/{subject.asset_id}/versions/{version}` })
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

local function get_operation(session: auth.apikey_session | auth.oauth2_session, operation_id: string): asset_operation
	return auth.request_json(session, `assets/v1/operations/{operation_id}`, 'GET')
end

-- module
return table.freeze {
	create = create,
	update = update,
	get = get,
	archive = archive,
	restore = restore,
	download = download,
	get_version = get_version,
	list_versions = list_versions,
	rollback = rollback,
	get_operation = get_operation,
}
