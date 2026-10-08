-- minimal runtime agnostic json encoder; decoding is left to the runtime

-- helpers
local ESCAPES: { [string]: string } =
	{ ['"'] = '\\"', ['\\'] = '\\\\', ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t' }

type writer = { buf: buffer, len: number }

local function escape(c: string): string
	return ESCAPES[c] or string.format('\\u%04x', string.byte(c))
end

local function is_array(t: { [any]: any }): boolean
	local n = 0
	for _ in t do
		n += 1
	end
	return n > 0 and n == #t
end

local function write(w: writer, s: string)
	local n = #s
	local size = buffer.len(w.buf)
	if w.len + n > size then
		local grown = buffer.create(math.max(size * 2, w.len + n))
		buffer.copy(grown, 0, w.buf, 0, w.len)
		w.buf = grown
	end
	buffer.writestring(w.buf, w.len, s)
	w.len += n
end

-- functions
local function write_value(w: writer, value: any)
	local kind = type(value)

	if value == nil then return write(w, 'null') end
	if kind == 'boolean' then return write(w, tostring(value)) end
	if kind == 'string' then
		write(w, '"')
		write(w, (string.gsub(value, '[%c"\\]', escape)))
		return write(w, '"')
	end
	if kind == 'number' then
		if value ~= value or value == math.huge or value == -math.huge then error 'cannot encode nan/inf as json' end
		if value == math.floor(value) and math.abs(value) < 2 ^ 53 then return write(w, string.format('%d', value)) end
		return write(w, string.format('%.17g', value))
	end
	if kind ~= 'table' then error(`cannot encode {kind} as json`) end

	if is_array(value) then
		write(w, '[')
		for i, v in value do
			if i > 1 then write(w, ',') end
			write_value(w, v)
		end
		return write(w, ']')
	end

	write(w, '{')
	local first = true
	for k, v in value do
		if type(k) ~= 'string' then error(`cannot encode {type(k)} key as json`) end
		if not first then write(w, ',') end
		first = false
		write_value(w, k)
		write(w, ':')
		write_value(w, v)
	end
	write(w, '}')
end

local function encode(value: any): buffer
	local w: writer = { buf = buffer.create(256), len = 0 }
	write_value(w, value)

	local out = buffer.create(w.len)
	buffer.copy(out, 0, w.buf, 0, w.len)
	return out
end

-- module
return table.freeze { encode = encode }
