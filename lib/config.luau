local web = require './web'

-- defs
-- `InExperienceConfig` holds ConfigService values; `DataStoresConfig` holds `user_data_templates`
-- (https://create.roblox.com/docs/cloud-services/data-stores/right-to-be-forgotten#configure-automated-rtbf-via-configs-api)
export type repository = 'InExperienceConfig' | 'DataStoresConfig'

export type entry_data = { value: any, description: string? }
export type full_data = { entries: { [string]: entry_data }? }
export type draft_data = { draftHash: string, entries: { [string]: any }? }
export type draft_patch = { entries: { [string]: any } }
export type publish_body = { draftHash: string?, message: string?, deploymentStrategy: 'Immediate' | 'GradualRollout' }
export type publish_response = { configVersion: number }

local REPOSITORY = table.freeze { universe_id = 0, repository = 'InExperienceConfig' :: repository }
type repository_path = typeof(REPOSITORY)

local READ: web.auth_spec = { apikey = { scope = { ['universe:read'] = true } } }
local WRITE: web.auth_spec = { apikey = { scope = { ['universe:write'] = true } } }

local CONFIGS =
	'https://apis.roblox.com/creator-configs-public-api/v1/configs/universes/{universe_id}/repositories/{repository}'

-- module
return table.freeze {
	-- published entries; 404 when the repository never published
	get_full = web.endpoint<<repository_path, nil, nil, full_data>> {
		base = `{CONFIGS}/full`,
		method = 'GET',
		auth = READ,
		path = REPOSITORY,
	},

	-- pending changes; 404 when there is no draft
	get_draft = web.endpoint<<repository_path, nil, nil, draft_data>> {
		base = `{CONFIGS}/draft`,
		method = 'GET',
		auth = READ,
		path = REPOSITORY,
	},

	-- merges `entries` into the draft
	update_draft = web.endpoint<<repository_path, nil, draft_patch, draft_data>> {
		base = `{CONFIGS}/draft`,
		method = 'PATCH',
		auth = WRITE,
		path = REPOSITORY,
		content_type = 'application/json',
	},

	-- replaces the whole draft with `entries`
	overwrite_draft = web.endpoint<<repository_path, nil, draft_patch, draft_data>> {
		base = `{CONFIGS}/draft:overwrite`,
		method = 'PUT',
		auth = WRITE,
		path = REPOSITORY,
		content_type = 'application/json',
	},

	publish = web.endpoint<<repository_path, nil, publish_body, publish_response>> {
		base = `{CONFIGS}/publish`,
		method = 'POST',
		auth = WRITE,
		path = REPOSITORY,
		content_type = 'application/json',
	},
}
