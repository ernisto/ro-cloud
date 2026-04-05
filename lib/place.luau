local auth = require './auth'
local serde = require '@lune/serde'
type json = auth.json_object

-- defs
export type version_identity = { universe_id: number, place_id: number, version: number }
export type identity = { universe_id: number, place_id: number, version: number }

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
local function upload(
	session: auth.apikey_session,
	subject: { universe_id: number, place_id: number },
	file: buffer,
	do_publish: boolean?
): version_identity
	local url = `universes/v1/{subject.universe_id}/places/{subject.place_id}/versions?versionType={if do_publish
		then 'Published'
		else 'Saved'}`

	local res = auth.request(session, url, 'POST', 'application/octet-stream', file)
	local body = serde.decode('json', res.body)

	return { universe_id = subject.universe_id, place_id = subject.place_id, version = body.versionNumber }
end
local function download(
	session: auth.apikey_session | auth.oauth2_session,
	subject: { place_id: number, version: number? }
): buffer
	local url = `https://assetdelivery.roblox.com/v1/asset/?id={subject.place_id}`
	if subject.version then
		url ..= `&version={subject.version}`
	end

	local data: { location: string } = auth.request_json(session, url, 'GET') :: any
	local response = auth.request(session, data.location, 'GET')

	assert(response.ok, `error [{response.statusCode}]: {response.statusMessage}`)
	return buffer.fromstring(response.body)
end

local function get_info(
	session: auth.apikey_session | auth.oauth2_session,
	subject: { universe_id: number, place_id: number }
): info
	return auth.request_json(session, `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}`, 'GET')
end

local function update_info(
	session: auth.apikey_session | auth.oauth2_session,
	subject: { universe_id: number, place_id: number },
	patch: info_patch,
	update_mask: string?
): info
	local path = `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}`
	return auth.request_json(session, path, 'PATCH', patch, { updateMask = update_mask })
end

local function get_instance(session: auth.apikey_session, subject: instance_identity): json
	local path = `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/instances/{subject.instance_id}`
	return auth.request_json(session, path, 'GET')
end

local function update_instance(
	session: auth.apikey_session,
	subject: instance_identity,
	data: instance,
	update_mask: string?
): json
	local path = `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/instances/{subject.instance_id}`
	return auth.request_json(session, path, 'PATCH', data, { updateMask = update_mask })
end

local function list_instance_children(
	session: auth.apikey_session,
	subject: instance_identity,
	query: page_query?
): json
	local path =
		`cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/instances/{subject.instance_id}:listChildren`
	return auth.request_json(session, path, 'GET', nil, query)
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
