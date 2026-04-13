local auth = require './auth'
local serde = require '@lune/serde'

-- defs
export type identity = { asset_id: number }
export type version_identity = identity & { version: number }

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
type page_query = { maxPageSize: number?, pageToken: string? }

export type asset_operation =
	| { path: string, done: false, error: operation_error }
	| { path: string, done: true, response: asset_data }

type err_response = { errors: { { code: number, message: string } } }

-- functions
local function download(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity | version_identity
): auth.http_result<buffer, err_response>
	local url = `https://apis.roblox.com/asset-delivery-api/v1/assetId/{subject.asset_id}`
	local location_response = auth.request_json(session, 'GET', url, { version = (subject :: any).version })

	if not location_response.ok then return location_response end
	local response = auth.request(session, 'GET', location_response.body.location)

	return {
		ok = response.ok,
		code = response.statusCode,
		message = response.statusMessage,
		headers = response.headers,
		body = if response.ok then buffer.fromstring(response.body) else serde.decode('json', response.body),
	} :: any
end

local function create(session: auth.apikey_session | auth.oauth2_session, asset: asset_data_patch, content: buffer)
	local data = auth.form { fileContent = content, request = serde.encode('json', asset) }
	return auth.request_json(
			session,
			'POST',
			'https://apis.roblox.com/assets/v1/assets',
			nil,
			data
		) :: auth.http_result<asset_operation>
end

local function update(
	session: auth.apikey_session | auth.oauth2_session,
	subject: identity,
	asset: asset_data_patch,
	content: buffer?
)
	local url = `https://apis.roblox.com/assets/v1/assets/{subject.asset_id}`
	local data = auth.form { request = serde.encode('json', asset), fileContent = content }
	return auth.request_json(
			session,
			'PATCH',
			url,
			{ updateMask = auth.mask_from(asset) },
			data
		) :: auth.http_result<asset_operation>
end

local function get(session: auth.apikey_session | auth.oauth2_session, subject: identity, read_mask: string?)
	local url = `https://apis.roblox.com/assets/v1/assets/{subject.asset_id}`
	return auth.request_json(session, 'GET', url, { readMask = read_mask }) :: auth.http_result<asset_data>
end

local function archive(session: auth.apikey_session | auth.oauth2_session, subject: identity)
	local url = `https://apis.roblox.com/assets/v1/assets/{subject.asset_id}:archive`
	return auth.request_json(session, 'POST', url) :: auth.http_result<asset_data>
end

local function restore(session: auth.apikey_session | auth.oauth2_session, subject: identity)
	local url = `https://apis.roblox.com/ssets/v1/assets/{subject.asset_id}:restore`
	return auth.request_json(session, 'POST', url) :: auth.http_result<asset_data>
end

local function rollback(session: auth.apikey_session | auth.oauth2_session, subject: identity, version: number)
	local url = `https://apis.roblox.com/assets/v1/assets/{subject.asset_id}/versions:rollback`
	local data = auth.form { assetVersion = `assets/{subject.asset_id}/versions/{version}` }
	return auth.request_json(session, 'POST', url, nil, data) :: auth.http_result<asset_version>
end

local function get_version(session: auth.apikey_session | auth.oauth2_session, subject: identity, version: string)
	local url = `https://apis.roblox.com/assets/v1/assets/{subject.asset_id}/versions/{version}`
	return auth.request_json(session, 'GET', url) :: auth.http_result<asset_version>
end

local function list_versions(session: auth.apikey_session | auth.oauth2_session, subject: identity, query: page_query?)
	local url = `https://apis.roblox.com/assets/v1/assets/{subject.asset_id}/versions`
	return auth.request_json(session, 'GET', url, query) :: auth.http_result<{}>
end

local function get_operation(session: auth.apikey_session | auth.oauth2_session, operation_id: string)
	local url = `https://apis.roblox.com/assets/v1/operations/{operation_id}`
	return auth.request_json(session, 'GET', url) :: auth.http_result<asset_operation>
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
