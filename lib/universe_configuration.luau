local auth = require '@lib/auth'
local universe = require '@lib/universe'

-- defs
export type identity = universe.identity

type avatar_scales = {
	height: number?,
	width: number?,
	head: number?,
	depth: number?,
	proportion: number?,
	bodyType: number?,
}
type avatar_asset_override = { assetID: number, assetTypeID: number, isPlayerChoice: boolean }
type universe_permissions = {
	IsThirdPartyTeleportAllowed: boolean?,
	IsThirdPartyAssetAllowed: boolean?,
	IsThirdPartyPurchaseAllowed: boolean?,
	IsClientTeleportAllowed: boolean?,
}

-- fields shared between PATCH request and its response
type universe_settings = {
	allowPrivateServers: boolean?,
	privateServerPrice: number?,
	isMeshTextureApiAccessAllowed: boolean?,
	isRewardedOnDemandAdsAllowed: boolean?,
	name: string?,
	description: string?,
	universeAvatarType: number?,
	universeAnimationType: number?,
	universeCollisionType: number?,
	universeJointPositioningType: number?,
	engineAvatarSettings: string?,
	isArchived: boolean?,
	isFriendsOnly: boolean?,
	genre: number?,
	playableDevices: { number }?,
	isForSale: boolean?,
	price: number?,
	universeAvatarAssetOverrides: { avatar_asset_override }?,
	universeAvatarMinScales: avatar_scales?,
	universeAvatarMaxScales: avatar_scales?,
	studioAccessToApisAllowed: boolean?,
	permissions: universe_permissions?,
	fiatBasePriceId: string?,
	audiences: { number }?,
}

export type settings_patch = universe_settings & {
	optInRegions: { number }?,
	optOutRegions: { number }?,
	fiatProductChangeType: number?,
}
export type settings_data = universe_settings & {
	id: number,
	optInRegions: { { region: number, status: string } }?,
	isForSaleInFiat: boolean?,
	fiatModerationStatus: number?,
	eligibleForTextChatMigration: boolean?,
}
export type configuration_data = {
	id: number,
	name: string,
	allowPrivateServers: boolean?,
	privateServerPrice: number?,
	isMeshTextureApiAccessAllowed: boolean?,
	isRewardedOnDemandAdsAllowed: boolean?,
	universeAvatarType: number?,
	universeScaleType: number?,
	universeAnimationType: number?,
	universeCollisionType: number?,
	universeBodyType: number?,
	universeJointPositioningType: number?,
	isArchived: boolean?,
	isFriendsOnly: boolean?,
	genre: number?,
	playableDevices: { number }?,
	isForSale: boolean?,
	price: number?,
	isStudioAccessToApisAllowed: boolean?,
	privacyType: string?,
	isForSaleInFiat: boolean?,
	fiatBasePriceId: string?,
	fiatModerationStatus: number?,
	audiences: { number }?,
}

-- functions
local function get(session: auth.cookie_session, subject: identity)
	local url = `https://develop.roblox.com/v2/universes/{subject.universe_id}/configuration`
	return auth.request_json(session, 'GET', url) :: auth.http_result<configuration_data>
end
local function update(session: auth.cookie_session, subject: identity, patch: settings_patch)
	local url = `https://develop.roblox.com/v2/universes/{subject.universe_id}/configuration`
	return auth.request_json(session, 'PATCH', url, nil, patch) :: auth.http_result<settings_data>
end

-- module
return table.freeze {
	get = get,
	update = update,
}
