local web = require '@self/web'
export type endpoint<P, Q, B, R, E> = web.endpoint<P, Q, B, R, E>
export type auth = web.auth
export type request = web.request
export type error = web.error

local auth = require '@self/auth'
export type session = auth.session
export type api_key_introspection = auth.api_key_introspection

local luau_task_exec = require '@self/luau_task_exec'
export type luau_task = luau_task_exec.task
export type luau_task_binary_input = luau_task_exec.binary_input
export type luau_task_binary_input_response = luau_task_exec.binary_input_response
export type luau_task_log_message = luau_task_exec.structured_message
export type luau_task_struct_log = luau_task_exec.structured_task_log
export type luau_task_flat_log = luau_task_exec.flat_task_log
export type luau_task_log = luau_task_exec.task_log

local pass = require '@self/game_pass'
export type pass = pass.pass_info

local universe = require '@self/universe'
export type universe = universe.universe_data

local universe_secret = require '@self/universe_secret'
export type universe_secret = universe_secret.secret
export type universe_public_key = universe_secret.public_key

local universe_media = require '@self/universe_media'
export type universe_media_item = universe_media.media_item
export type universe_media_upload_response = universe_media.upload_response

local universe_configuration = require '@self/universe_configuration'
export type universe_settings_patch = universe_configuration.settings_patch_v2
export type universe_settings_data = universe_configuration.settings_data_v2
export type universe_settings_data_v1 = universe_configuration.settings_data_v1

local place = require '@self/place'
export type place_info = place.info

local place_configuration = require '@self/place_configuration'
export type place_data = place_configuration.place_data
export type place_patch = place_configuration.place_patch

local developer_product = require '@self/developer_product'
export type product = developer_product.product_data

local asset = require '@self/asset'
export type asset_data = asset.asset_data
export type asset_version = asset.asset_version
export type asset_operation = asset.asset_operation

local data_store = require '@self/data_store'
export type data_store_entry = data_store.entry
export type data_store_info = data_store.data_store

local memory_store = require '@self/memory_store'
export type memory_store_queue_item = memory_store.queue_item
export type memory_store_sorted_map_item = memory_store.sorted_map_item

local user_restriction = require '@self/user_restriction'
export type user_restriction_data = user_restriction.restriction
export type user_restriction_log = user_restriction.restriction_log

local group = require '@self/group'
export type group_data = group.group
export type group_role = group.role
export type group_membership = group.membership

local user_mod = require '@self/user'
export type user_data = user_mod.user_data
export type user_inventory_item = user_mod.inventory_item
export type user_notification = user_mod.notification
export type user_subscription = user_mod.subscription

local develop = require '@self/develop'
export type dev_universe = develop.dev_universe
export type dev_group = develop.dev_group

local form = require '@self/web/form'
local json = require '@self/web/json'

return table.freeze {
	web = web,
	auth = auth,
	json = json,
	form = form,

	universe = universe,
	universe_secret = universe_secret,
	universe_media = universe_media,
	universe_configuration = universe_configuration,
	place_configuration = place_configuration,
	place = place,
	asset = asset,
	data_store = data_store,
	memory_store = memory_store,
	user_restriction = user_restriction,
	group = group,
	user = user_mod,
	luau_task_exec = luau_task_exec,
	product = developer_product,
	develop = develop,
	pass = pass,
}
