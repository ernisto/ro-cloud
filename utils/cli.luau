local process = require '@lune/process'

local options: { [string]: string } = {}
local flags: { [string]: boolean } = {}
local positional: { string } = {}
local forwarded: { string } = {}

local ESCAPES: { [string]: string } = { ['\\'] = '\\', ['"'] = '"', ["'"] = "'", n = '\n', t = '\t' }

local function unquote(s: string): string
	local first = string.sub(s, 1, 1)
	if (first ~= '"' and first ~= "'") or string.sub(s, -1) ~= first then return s end
	return (string.gsub(string.sub(s, 2, -2), '\\(.)', ESCAPES))
end

local i = 1
while i <= #process.args do
	local arg = process.args[i]

	-- `--` forwards everything remaining
	if arg == '--' then
		table.move(process.args, i + 1, #process.args, 1, forwarded)
		break
	end

	-- long: --name, --name value, --name=value
	if string.sub(arg, 1, 2) == '--' then
		local rest = string.sub(arg, 3)
		local eq = string.find(rest, '=', 1, true)
		if eq then
			options[string.sub(rest, 1, eq - 1)] = unquote(string.sub(rest, eq + 1))
		else
			local next = process.args[i + 1]
			if next and string.sub(next, 1, 1) ~= '-' then
				options[rest] = unquote(next)
				i += 1
			else
				flags[rest] = true
			end
		end
	-- short: -f or -abc (each char is a flag)
	elseif string.sub(arg, 1, 1) == '-' then
		for j = 2, #arg do
			flags[string.sub(arg, j, j)] = true
		end
	else
		table.insert(positional, unquote(arg))
	end

	i += 1
end

-- functions
local function str(key: string): string?
	return options[key]
end
local function num(key: string | number): number?
	if type(key) == 'number' then return tonumber(positional[key]) end
	return tonumber(options[key :: string])
end
local function uint(key: string | number): number?
	local val = num(key)
	return val and val // 1
end
local function bool(key: string): boolean
	return flags[key] == true
end

-- module
return table.freeze {
	str = str,
	num = num,
	uint = uint,
	bool = bool,
	forwarded = forwarded,
}
