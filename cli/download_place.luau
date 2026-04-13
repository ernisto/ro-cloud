local cli = require '@utils/cli'
local cloud = require '@lib'
local env = require '@utils/env'
local fs = require '@lune/fs'

assert(cli.str(1) == 'place', `no command '{cli.str(1)}' found\navailable commands: 'place'`)
assert(cli.str(2) == 'download', `no sub-command '{cli.str(2)}' found\navailable sub commands: 'download'`)

local place_id = cli.num(3) or error(`place id <number> arg missing`)
local output = cli.str 'output' or error '--output <file_path> arg missing'
local cache = cli.num 'cache'
local api_key = cli.str 'api-key' or env.str 'API_KEY' or error 'couldnt get api key'

if cache and fs.isFile(output) then
	local age = os.time() - fs.metadata(output).modifiedAt.unixTimestamp
	if age < cache then return nil end
end

local session = cloud.auth.apikey.login(api_key)
local content = cloud.place.download(session, { place_id = place_id })

local dir = output:match '(.*)/.+$'
if dir then fs.writeDir(dir) end

fs.writeFile(output, content)
return nil
