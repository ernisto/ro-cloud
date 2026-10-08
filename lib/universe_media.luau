local web = require './web'
type endpoint<P, Q, B, R> = web.endpoint<P, Q, B, R>

-- defs
export type upload_response = { targetId: number }
export type remove_icon_body = { placeId: number, placeIconId: number }
export type media_item = {
	assetTypeId: number,
	assetType: string,
	imageId: number?,
	videoHash: string?,
	videoTitle: string?,
	approved: boolean,
	altText: string?,
}

local COOKIE: web.auth_spec = { cookie = {} }

local UNIVERSE = table.freeze { universe_id = 0 }
local THUMBNAIL = table.freeze { universe_id = 0, thumbnail_id = 0 }
type universe_path = typeof(UNIVERSE)
type thumbnail_path = typeof(THUMBNAIL)

local function image_request(self: any, auth: web.auth, path: universe_path, image: buffer)
	return web.build(self, auth, { path = path, body = { ['request.files'] = image } })
end

-- module
return table.freeze {
	upload_icon = web.endpoint {
		base = 'https://publish.roblox.com/v1/games/{universe_id}/icon',
		method = 'POST',
		auth = COOKIE,
		path = UNIVERSE,
		content_type = 'multipart/form-data',
		request = image_request,
	} :: endpoint<universe_path, nil, buffer, upload_response>,

	remove_icon = web.endpoint {
		base = 'https://www.roblox.com/places/icons/remove-icon',
		method = 'POST',
		auth = COOKIE,
		path = nil,
		content_type = 'application/x-www-form-urlencoded',
		request = function(self, auth, _, body)
			return web.build(
				self,
				auth,
				{ body = buffer.fromstring(`placeId={body.placeId}&placeIconId={body.placeIconId}`) }
			)
		end,
	} :: endpoint<nil, nil, remove_icon_body, nil>,

	upload_thumbnail = web.endpoint {
		base = 'https://publish.roblox.com/v1/games/{universe_id}/thumbnail/image',
		method = 'POST',
		auth = COOKIE,
		path = UNIVERSE,
		content_type = 'multipart/form-data',
		request = image_request,
	} :: endpoint<universe_path, nil, buffer, upload_response>,

	list_thumbnails = web.endpoint {
		base = 'https://games.roblox.com/v1/games/{universe_id}/media',
		method = 'GET',
		auth = COOKIE,
		path = UNIVERSE,
	} :: endpoint<universe_path, nil, nil, { data: { media_item } }>,

	set_thumbnail_order = web.endpoint {
		base = 'https://develop.roblox.com/v1/universes/{universe_id}/thumbnails/order',
		method = 'POST',
		auth = COOKIE,
		path = UNIVERSE,
		content_type = 'application/json',
	} :: endpoint<universe_path, nil, { thumbnailIds: { number } }, nil>,

	delete_thumbnail = web.endpoint {
		base = 'https://develop.roblox.com/v1/universes/{universe_id}/thumbnails/{thumbnail_id}',
		method = 'DELETE',
		auth = COOKIE,
		path = THUMBNAIL,
	} :: endpoint<thumbnail_path, nil, nil, nil>,
}
