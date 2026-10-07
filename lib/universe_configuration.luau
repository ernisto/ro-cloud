local auth = require '@lib/auth'
local universe = require '@lib/universe'

-- defs
export type identity = universe.identity

type avatar_scale_patch = {
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

export type settings_patch_v2 = {
	name: string?,
	genre: number?,
	description: string?,
	promotionalText: string?,
	privateServerPrice: number?,
	allowPrivateServers: boolean?,
	permissions: universe_permissions?,

	optInRegions: { number }?,
	optOutRegions: { number }?,
	fiatBasePriceId: string?,

	-- playability
	price: number?,
	isForSale: boolean?,
	isArchived: boolean?,
	isFriendsOnly: boolean?,
	audiences: { number }?,
	playableDevices: { number }?,

	-- avatar
	engineAvatarSettings: string?,
	universeAvatarType: number?,
	universeAnimationType: number?,
	universeCollisionType: number?,
	universeJointPositioningType: number?,
	universeAvatarAssetOverrides: { avatar_asset_override }?,
	universeAvatarMinScales: avatar_scale_patch?,
	universeAvatarMaxScales: avatar_scale_patch?,

	-- permissions
	isMeshTextureApiAccessAllowed: boolean?,
	isRewardedOnDemandAdsAllowed: boolean?,
	studioAccessToApisAllowed: boolean?,

	fiatProductChangeType: number?,
	demoModeEnabled: boolean?,
}

export type settings_data_v1 = {
	id: number,
	name: string,
	genre: number,
	promotionalText: string?,
	allowPrivateServers: boolean,
	privateServerPrice: number,

	isForSaleInFiat: boolean,
	fiatBasePriceId: string,
	fiatModerationStatus: number,

	-- playability
	price: number,
	isForSale: boolean,
	isArchived: boolean,
	isFriendsOnly: boolean,
	audiences: { number },
	playableDevices: { number },
	privacyType: 'Public' | 'Private',

	-- avatar
	universeAvatarType: number,
	universeScaleType: number,
	universeAnimationType: number,
	universeCollisionType: number,
	universeBodyType: number,
	universeJointPositioningType: number,

	-- permissions
	isMeshTextureApiAccessAllowed: boolean,
	isRewardedOnDemandAdsAllowed: boolean,
	isStudioAccessToApisAllowed: boolean,

	demoModeEnabled: boolean,
	demoModeChangeableAfter: string?,
}

export type settings_data_v2 = settings_data_v1 & {
	optInRegions: { { region: number, status: string } }?,
}

-- functions
local function get(session: auth.cookie_session, subject: identity)
	local url = `https://develop.roblox.com/v1/universes/{subject.universe_id}/configuration`
	return auth.request_json(session, 'GET', url) :: auth.http_result<settings_data_v1>
end
local function update(session: auth.cookie_session, subject: identity, patch: settings_patch_v2)
	local url = `https://develop.roblox.com/v2/universes/{subject.universe_id}/configuration`
	return auth.request_json(session, 'PATCH', url, nil, patch) :: auth.http_result<settings_data_v2>
end

-- module
return table.freeze {
	get = get,
	update = update,
}
