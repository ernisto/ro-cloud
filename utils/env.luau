local fs = require '@lune/fs'
local process = require '@lune/process'
local serde = require '@lune/serde'

local dotenv = if fs.isFile '.env' then serde.decode('toml', fs.readFile '.env') else {}

-- functions
local function num(key: string): number?
	return tonumber(dotenv[key] or process.env[key])
end
local function str(key: string): string
	local val = dotenv[key] or process.env[key]
	return val and tostring(val)
end

-- module
return table.freeze { uint = num, int = num, num = num, str = str }
