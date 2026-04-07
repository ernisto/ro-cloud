local asset = require './asset'
local auth = require './auth'
local serde = require '@lune/serde'
type json = auth.json_object

-- defs
export type version_identity = { universe_id: number, place_id: number, version: number }
export type identity = { universe_id: number, place_id: number }

export type info = {
	path: string?,
	createTime: string?,
	updateTime: string?,
	displayName: string?,
	description: string?,
	serverSize: number?,
	root: boolean?,
	universeRuntimeCreation: boolean?,
	templatePlace: string?,
}
export type info_patch = { displayName: string?, description: string?, serverSize: number? }

export type instance = { path: string?, hasChildren: boolean?, engineInstance: any? }
export type instance_identity = { universe_id: number, place_id: number, instance_id: string }

type page_query = { maxPageSize: number?, pageToken: string? }

-- functions
local function upload(session: auth.apikey_session, subject: identity, file: buffer, do_publish: boolean?)
	local version_type = if do_publish then 'Published' else 'Saved'
	local path = `universes/v1/{subject.universe_id}/places/{subject.place_id}/versions?versionType={version_type}`

	local response = auth.request(session, 'POST', path, nil, file, 'application/octet-stream')
	local result: auth.http_result<{ versionNumber: number }> = {
		body = serde.decode('json', response.body),
		message = response.statusMessage,
		headers = response.headers,
		code = response.statusCode,
		ok = response.ok,
	} :: any
	return result
end
local function download(
	session: auth.apikey_session | auth.oauth2_session,
	subject: { place_id: number, version: number? }
)
	return asset.download(session, { asset_id = subject.place_id, version = subject.version })
end

local function get_info(session: auth.apikey_session | auth.oauth2_session, subject: identity)
	local path = `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}`
	return auth.request_json(session, 'GET', path) :: auth.http_result<info>
end

local function update_info(session: auth.apikey_session | auth.oauth2_session, subject: identity, patch: info_patch)
	local path = `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}`
	return auth.request_json(
			session,
			'PATCH',
			path,
			{ updateMask = auth.mask_from(patch) },
			patch
		) :: auth.http_result<info>
end

local function get_instance(session: auth.apikey_session, subject: instance_identity)
	local path = `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/instances/{subject.instance_id}`
	return auth.request_json(session, 'GET', path) :: auth.http_result<json>
end

local function update_instance(session: auth.apikey_session, subject: instance_identity, data: instance)
	local path = `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/instances/{subject.instance_id}`
	return auth.request_json(
			session,
			'PATCH',
			path,
			{ updateMask = auth.mask_from(data) },
			data
		) :: auth.http_result<json>
end

local function list_instance_children(session: auth.apikey_session, subject: instance_identity, query: page_query?)
	local path =
		`cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/instances/{subject.instance_id}:listChildren`
	return auth.request_json(session, 'GET', path, query) :: auth.http_result<json>
end

-- module
return table.freeze {
	upload = upload,
	download = download,
	get_info = get_info,
	update_info = update_info,
	get_instance = get_instance,
	update_instance = update_instance,
	list_instance_children = list_instance_children,
}
