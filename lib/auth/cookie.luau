local user = require '../user'

-- module
return table.freeze {
	-- the user the session's cookie belongs to
	get_info = user.get_authenticated,
}
