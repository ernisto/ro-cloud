local web = require './web'
type endpoint<P, Q, B, R> = web.endpoint<P, Q, B, R>

-- defs
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

local COOKIE: web.auth_spec = { cookie = {} }

local UNIVERSE = table.freeze { universe_id = 0 }
type universe_path = typeof(UNIVERSE)

-- module
return table.freeze {
	get = web.endpoint {
		base = 'https://develop.roblox.com/v1/universes/{universe_id}/configuration',
		method = 'GET',
		auth = COOKIE,
		path = UNIVERSE,
	} :: endpoint<universe_path, nil, nil, settings_data_v1>,

	update = web.endpoint {
		base = 'https://develop.roblox.com/v2/universes/{universe_id}/configuration',
		method = 'PATCH',
		auth = COOKIE,
		path = UNIVERSE,
		content_type = 'application/json',
	} :: endpoint<universe_path, nil, settings_patch_v2, settings_data_v2>,
}
