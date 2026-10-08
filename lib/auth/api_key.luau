local net = require '@lune/net'
local serde = require '@lune/serde'

-- defs
local INTROSPECT_URL = 'https://apis.roblox.com/api-keys/v1/introspect'

export type state = { key: string, introspection: introspection? }
export type session = { api_key_state: state }

export type scope = {
	name: string,
	operations: { string },
	universeIds: { string }?,
	userIds: { string }?,
	groupIds: { string }?,
}

export type introspection = {
	name: string,
	authorizedUserId: string?,
	scopes: { scope },
	enabled: boolean,
	expired: boolean,
	expirationUtcTime: string?,
}

-- functions
local function refresh_introspection(session: session): (introspection?, string?)
	local state = session.api_key_state
	local headers: any = {
		['Content-Type'] = 'application/json',
		['x-api-key'] = state.key,
	}

	local body = serde.encode('json', { apiKey = state.key })
	local res = net.request { url = INTROSPECT_URL, method = 'POST', headers = headers, body = body }

	if not res.ok then return nil, res.statusMessage end

	local info = serde.decode('json', res.body) :: introspection
	state.introspection = info

	return info, nil
end

local function introspect(session: session): (introspection?, string?)
	local cached = session.api_key_state.introspection
	if cached then return cached, nil end
	return refresh_introspection(session)
end

local function await_introspect(session: session): introspection
	local info, err = introspect(session)
	return info or error(`api key introspection failed: {err}`)
end

local function await_refresh_introspection(session: session): introspection
	local info, err = refresh_introspection(session)
	return info or error(`api key introspection failed: {err}`)
end

local function usable(info: introspection): boolean
	return info.enabled and not info.expired
end

-- `scope` is `name:operation` (e.g. `universe.place:read`); `target` is an
-- optional resource id (e.g. a universe id) the scope must be granted on
local function has_scope(info: introspection, scope: string, target: string?): boolean
	local name, operation = string.match(scope, '^(.*):([^:]+)$')
	if not name then error(`malformed scope "{scope}"`) end

	for _, granted in info.scopes do
		if granted.name ~= name then continue end

		local has_op = false
		for _, op in granted.operations do
			if op == operation or op == '*' then
				has_op = true
				break
			end
		end
		if not has_op then continue end

		if not target then return true end
		for _, ids in { granted.universeIds, granted.userIds, granted.groupIds } do
			if not ids then continue end
			for _, id in ids do
				if id == target or id == '*' then return true end
			end
		end
	end
	return false
end

local function await_has_scope(session: session, scope: string, target: string?): boolean
	return has_scope(await_introspect(session), scope, target)
end

-- module
return table.freeze {
	introspect = introspect,
	await_introspect = await_introspect,
	await_refresh_introspection = await_refresh_introspection,

	usable = usable,
	has_scope = has_scope,
	await_has_scope = await_has_scope,
}
