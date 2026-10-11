local web = require '@self/web'
export type endpoint<P, Q, B, R, E> = web.endpoint<P, Q, B, R, E>
export type auth = web.auth
export type request = web.request
export type error = web.error

local auth = require '@self/auth'
export type session = auth.session
export type api_key_introspection = auth.api_key_introspection

local luau_task_exec = require '@self/luau_task_exec'
export type luau_task_data = luau_task_exec.task_data
export type luau_task_creation = luau_task_exec.task_creation
export type luau_task_pending = luau_task_exec.pending_task
export type luau_task_failed = luau_task_exec.failed_task
export type luau_task_complete = luau_task_exec.complete_task
export type luau_task_cancelled = luau_task_exec.cancelled_task
export type luau_task_done = luau_task_exec.done_task
export type luau_task_error_code = luau_task_exec.error_code
export type luau_task_binary_input = luau_task_exec.binary_input
export type luau_task_binary_input_response = luau_task_exec.binary_input_response
export type luau_task_log_message = luau_task_exec.structured_message
export type luau_task_log_message_type = luau_task_exec.message_type
export type luau_task_struct_log = luau_task_exec.structured_task_log
export type luau_task_flat_log = luau_task_exec.flat_task_log
export type luau_task_log = luau_task_exec.task_log
export type luau_task_logs_page = luau_task_exec.logs_page

local pass = require '@self/game_pass'
export type pass_data = pass.pass_data
export type pass_creation = pass.pass_creation
export type pass_patch = pass.pass_patch
export type pass_page = pass.pass_page

local universe = require '@self/universe'
export type universe_data = universe.universe_data
export type universe_creation = universe.universe_creation
export type universe_patch = universe.universe_patch
export type universe_create_response = universe.create_response
export type universe_message = universe.message

local universe_secret = require '@self/universe_secret'
export type universe_secret_data = universe_secret.secret_data
export type universe_secret_creation = universe_secret.secret_creation
export type universe_secret_patch = universe_secret.secret_patch
export type universe_secrets_page = universe_secret.secrets_page
export type universe_public_key = universe_secret.public_key

local universe_media = require '@self/universe_media'
export type universe_media_item_data = universe_media.media_item_data
export type universe_media_upload_response = universe_media.upload_response
export type universe_media_remove_icon_body = universe_media.remove_icon_body

local universe_configuration = require '@self/universe_configuration'
export type universe_settings_data = universe_configuration.settings_data
export type universe_settings_data_v1 = universe_configuration.settings_data_v1
export type universe_settings_patch = universe_configuration.settings_patch

local place = require '@self/place'
export type place_data = place.place_data
export type place_creation = place.place_creation
export type place_patch = place.place_patch
export type place_create_response = place.create_response
export type place_instance_data = place.instance_data
export type place_instance_patch = place.instance_patch

local place_configuration = require '@self/place_configuration'
export type place_configuration_data = place_configuration.place_data
export type place_configuration_patch = place_configuration.place_patch

local developer_product = require '@self/developer_product'
export type product_data = developer_product.product_data
export type product_creation = developer_product.product_creation
export type product_patch = developer_product.product_patch
export type product_page = developer_product.product_page

local asset = require '@self/asset'
export type asset_data = asset.asset_data
export type asset_patch = asset.asset_patch
export type asset_upload = asset.asset_upload
export type asset_version = asset.asset_version
export type asset_versions_page = asset.asset_versions_page
export type asset_operation = asset.asset_operation
export type asset_download_location = asset.download_location

local data_store = require '@self/data_store'
export type data_store_data = data_store.store_data
export type data_stores_page = data_store.stores_page
export type data_store_entry_data = data_store.entry_data
export type data_store_entry_creation = data_store.entry_creation
export type data_store_entry_patch = data_store.entry_patch
export type data_store_entry_increment = data_store.increment
export type data_store_entries_page = data_store.entries_page
export type data_store_entry_revisions_page = data_store.entry_revisions_page
export type data_store_ordered_entry_data = data_store.ordered_entry_data
export type data_store_ordered_entry_creation = data_store.ordered_entry_creation
export type data_store_ordered_entry_patch = data_store.ordered_entry_patch
export type data_store_ordered_entries_page = data_store.ordered_entries_page
export type data_store_snapshot_result = data_store.snapshot_result

local memory_store = require '@self/memory_store'
export type memory_store_queue_item_data = memory_store.queue_item_data
export type memory_store_queue_item_creation = memory_store.queue_item_creation
export type memory_store_queue_read = memory_store.queue_read
export type memory_store_sorted_map_item_data = memory_store.sorted_map_item_data
export type memory_store_sorted_map_item_creation = memory_store.sorted_map_item_creation
export type memory_store_sorted_map_item_patch = memory_store.sorted_map_item_patch
export type memory_store_sorted_map_page = memory_store.sorted_map_page

local user_restriction = require '@self/user_restriction'
export type user_restriction_data = user_restriction.restriction_data
export type user_restriction_patch = user_restriction.restriction_patch
export type user_restrictions_page = user_restriction.restrictions_page
export type user_restriction_log_data = user_restriction.restriction_log_data
export type user_restriction_logs_page = user_restriction.restriction_logs_page

local group = require '@self/group'
export type group_data = group.group_data
export type group_role_data = group.role_data
export type group_roles_page = group.roles_page
export type group_membership_data = group.membership_data
export type group_membership_patch = group.membership_patch
export type group_memberships_page = group.memberships_page
export type group_shout_data = group.shout_data
export type group_join_request_data = group.join_request_data
export type group_join_requests_page = group.join_requests_page

local user_mod = require '@self/user'
export type user_data = user_mod.user_data
export type user_authenticated = user_mod.authenticated_user
export type user_inventory_item_data = user_mod.inventory_item_data
export type user_inventory_page = user_mod.inventory_page
export type user_notification_data = user_mod.notification_data
export type user_notification_creation = user_mod.notification_creation
export type user_subscription_data = user_mod.subscription_data

local develop = require '@self/develop'
export type dev_universe_data = develop.universe_data
export type dev_group_data = develop.group_data

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
