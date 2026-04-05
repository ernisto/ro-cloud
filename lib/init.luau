local auth = require '@self/auth'
export type apikey_session = auth.apikey_session
export type cookie_session = auth.cookie_session
export type oauth_session = auth.oauth2_session

local luau_task_exec = require '@self/luau_task_exec'
export type luau_task_identity = luau_task_exec.identity
export type luau_task = luau_task_exec.task
export type luau_task_binary_input = luau_task_exec.binary_input
export type luau_task_binary_input_response = luau_task_exec.binary_input_response

local luau_task_exec_log = require '@self/luau_task_exec_log'
type luau_task_log_message = luau_task_exec_log.structured_message
type luau_task_struct_log = luau_task_exec_log.structured_task_log
type luau_task_flat_log = luau_task_exec_log.flat_task_log
type luau_task_log = luau_task_exec_log.task_log

local pass = require '@self/game_pass'
export type pass_identity = pass.identity
export type pass = pass.pass_data

local universe = require '@self/universe'
export type universe_identity = universe.identity
export type universe = universe.universe_data
export type universe_secret = universe.secret
export type universe_public_key = universe.public_key

local place = require '@self/place'
export type place_version_identity = place.version_identity
export type place_identity = place.identity
export type place_info = place.info
export type place_instance_identity = place.instance_identity

local developer_product = require '@self/developer_product'
export type product_identity = developer_product.identity
export type product = developer_product.product_data

local asset = require '@self/asset'
export type asset_identity = asset.identity
export type asset_data = asset.asset_data
export type asset_version = asset.asset_version
export type asset_operation = asset.asset_operation

local data_store = require '@self/data_store'
export type data_store_identity = data_store.store_identity
export type data_store_entry = data_store.entry
export type data_store_info = data_store.data_store

local memory_store = require '@self/memory_store'
export type memory_store_queue_item = memory_store.queue_item
export type memory_store_sorted_map_item = memory_store.sorted_map_item

local user_restriction = require '@self/user_restriction'
export type user_restriction_identity = user_restriction.restriction_identity
export type user_restriction_data = user_restriction.restriction
export type user_restriction_log = user_restriction.restriction_log

local group = require '@self/group'
export type group_identity = group.identity
export type group_data = group.group
export type group_role = group.role
export type group_membership = group.membership

local user_mod = require '@self/user'
export type user_identity = user_mod.identity
export type user_data = user_mod.user_data
export type user_inventory_item = user_mod.inventory_item
export type user_notification = user_mod.notification
export type user_subscription = user_mod.subscription

return table.freeze {
	auth = auth,
	universe = universe,
	place = place,
	asset = asset,
	data_store = data_store,
	memory_store = memory_store,
	user_restriction = user_restriction,
	group = group,
	user = user_mod,

	luau_task_exec = luau_task_exec,
	luau_task_exec_log = luau_task_exec_log,

	product = developer_product,
	pass = pass,
}
