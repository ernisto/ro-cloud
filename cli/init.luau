local cli = require '@utils/cli'

local cmd = cli.str(1)
local sub = cli.str(2)

if cmd == 'place' and sub == 'download' then
	return require '@self/download_place'
elseif cmd == 'luau' and sub == 'exec' then
	return require '@self/luau_exec'
end

error(`no command '{cmd} {sub}' found\navailable commands: 'place download', 'luau exec'`)
