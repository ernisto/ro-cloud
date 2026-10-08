local auth = require './auth'

-- defs
export type universe_identity = { universe_id: number }

export type upload_response = { targetId: number }
export type media_item = {
	assetTypeId: number,
	assetType: string,
	imageId: number?,
	videoHash: string?,
	videoTitle: string?,
	approved: boolean,
	altText: string?,
}

-- functions
local function upload_icon(session: auth.cookie_session, subject: universe_identity, image: buffer)
	local url = `https://publish.roblox.com/v1/games/{subject.universe_id}/icon`
	local body = auth.form { ['request.files'] = image }
	return auth.request_json(session, 'POST', url, nil, body) :: auth.http_result<upload_response>
end
local function remove_icon(session: auth.cookie_session, start_place_id: number, icon_asset_id: number)
	local url = 'https://www.roblox.com/places/icons/remove-icon'
	local body = `placeId={start_place_id}&placeIconId={icon_asset_id}`
	local content_type = 'application/x-www-form-urlencoded'
	return auth.request_json(session, 'POST', url, nil, body, content_type) :: auth.http_result<nil>
end
local function upload_thumbnail(session: auth.cookie_session, subject: universe_identity, image: buffer)
	local url = `https://publish.roblox.com/v1/games/{subject.universe_id}/thumbnail/image`
	local body = auth.form { ['request.files'] = image }
	return auth.request_json(session, 'POST', url, nil, body) :: auth.http_result<upload_response>
end
local function list_thumbnails(session: auth.cookie_session, subject: universe_identity)
	local url = `https://games.roblox.com/v1/games/{subject.universe_id}/media`
	return auth.request_json(session, 'GET', url) :: auth.http_result<{ data: { media_item } }>
end
local function set_thumbnail_order(session: auth.cookie_session, subject: universe_identity, thumbnail_ids: { number })
	local url = `https://develop.roblox.com/v1/universes/{subject.universe_id}/thumbnails/order`
	return auth.request_json(session, 'POST', url, nil, { thumbnailIds = thumbnail_ids }) :: auth.http_result<nil>
end
local function delete_thumbnail(session: auth.cookie_session, subject: universe_identity, thumbnail_id: number)
	local url = `https://develop.roblox.com/v1/universes/{subject.universe_id}/thumbnails/{thumbnail_id}`
	return auth.request_json(session, 'DELETE', url) :: auth.http_result<nil>
end

-- module
return table.freeze {
	upload_icon = upload_icon,
	remove_icon = remove_icon,
	upload_thumbnail = upload_thumbnail,
	list_thumbnails = list_thumbnails,
	set_thumbnail_order = set_thumbnail_order,
	delete_thumbnail = delete_thumbnail,
}
