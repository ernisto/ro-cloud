local json = require './web/json'

local web = require './web'

-- defs
type creation_context = { creator: string?, expectedPrice: number? }
type moderation_result = { moderationState: string? }
type preview = { asset: string?, altText: string? }
type social_link = { title: string?, uri: string? }

export type asset_data = {
	assetType: string, -- TODO: add enums
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
	assetType: string, -- TODO: add enums
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

-- TODO: complete from Roblox cloud docs
export type asset_versions_page = { assetVersions: { asset_version }, nextPageToken: string? }

export type download_location = { location: string }

-- `content` is the asset file, optional on update
export type asset_upload = { content: buffer?, asset: asset_data_patch }

local READ: web.auth_spec = { apikey = { scope = { ['asset:read'] = true } } }
local WRITE: web.auth_spec = { apikey = { scope = { ['asset:read'] = true, ['asset:write'] = true } } }

local LEGACY_MANAGE: web.auth_spec = { apikey = { scope = { ['legacy-asset:manage'] = true } } }

local ASSETS = 'https://apis.roblox.com/assets/v1/assets'

local ASSET = table.freeze { asset_id = 0 }
local VERSION = table.freeze { asset_id = 0, version = 0 }
local OPERATION = table.freeze { operation_id = '' }
local PAGE = table.freeze { maxPageSize = 0 :: number?, pageToken = '' :: string? }
type asset_path = typeof(ASSET)
type version_path = typeof(VERSION)
type operation_path = typeof(OPERATION)
export type page_query = typeof(PAGE)

local function upload_form(upload: asset_upload)
	return { fileContent = upload.content, request = buffer.tostring(json.encode(upload.asset)) }
end

-- module
return table.freeze {
	download = web.endpoint<<asset_path, { version: number? }, nil, download_location>> {
		base = 'https://apis.roblox.com/asset-delivery-api/v1/assetId/{asset_id}',
		method = 'GET',
		auth = LEGACY_MANAGE,
		path = ASSET,
		query = { version = 0 :: number? },
	},

	create = web.endpoint<<nil, nil, asset_upload, asset_operation>> {
		base = ASSETS,
		method = 'POST',
		auth = WRITE,
		ratelimit = { apikey = 120 },
		path = nil,
		content_type = 'multipart/form-data',
		request = function(self, auth, _, upload)
			return web.build(self, auth, { body = upload_form(upload) })
		end,
	},

	update = web.endpoint<<asset_path, nil, asset_upload, asset_operation>> {
		base = `{ASSETS}/\{asset_id}`,
		method = 'PATCH',
		auth = WRITE,
		ratelimit = { apikey = 120 },
		path = ASSET,
		content_type = 'multipart/form-data',
		request = function(self, auth, path, upload)
			local query = { updateMask = web.mask_from(upload.asset) }
			return web.build(self, auth, { path = path, query = query, body = upload_form(upload) })
		end,
	},

	get = web.endpoint<<asset_path, { readMask: string? }, nil, asset_data>> {
		base = `{ASSETS}/\{asset_id}`,
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 120 },
		path = ASSET,
		query = { readMask = '' :: string? },
	},

	archive = web.endpoint<<asset_path, nil, nil, asset_data>> {
		base = `{ASSETS}/\{asset_id}:archive`,
		method = 'POST',
		auth = WRITE,
		ratelimit = { apikey = 100 },
		path = ASSET,
	},

	restore = web.endpoint<<asset_path, nil, nil, asset_data>> {
		base = `{ASSETS}/\{asset_id}:restore`,
		method = 'POST',
		auth = WRITE,
		ratelimit = { apikey = 100 },
		path = ASSET,
	},

	rollback = web.endpoint<<version_path, nil, nil, asset_version>> {
		base = `{ASSETS}/\{asset_id}/versions:rollback`,
		method = 'POST',
		auth = WRITE,
		ratelimit = { apikey = 100 },
		path = VERSION,
		content_type = 'multipart/form-data',
		request = function(self, auth, path)
			local body = { assetVersion = `assets/{path.asset_id}/versions/{path.version}` }
			return web.build(self, auth, { path = path, body = body })
		end,
	},

	get_version = web.endpoint<<version_path, nil, nil, asset_version>> {
		base = `{ASSETS}/\{asset_id}/versions/\{version}`,
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 100 },
		path = VERSION,
	},

	list_versions = web.endpoint<<asset_path, page_query, nil, asset_versions_page>> {
		base = `{ASSETS}/\{asset_id}/versions`,
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 100 },
		path = ASSET,
		query = PAGE,
	},

	get_operation = web.endpoint<<operation_path, nil, nil, asset_operation>> {
		base = 'https://apis.roblox.com/assets/v1/operations/{operation_id}',
		method = 'GET',
		auth = READ,
		ratelimit = { apikey = 300 },
		path = OPERATION,
	},
}
