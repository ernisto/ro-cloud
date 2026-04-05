-- functions
local function from_hex_str(hex_str: string): buffer
	local buf = buffer.create(#hex_str / 2)
	for offset = 0, #hex_str / 2 - 1 do
		local hex_byte = hex_str:sub(1 + offset * 2, 2 + offset * 2)
		buffer.writeu8(buf, offset, tonumber(hex_byte, 16) or error 'invalid hex string')
	end
	return buf
end
local function random(length: number): buffer
	local buf = buffer.create(length)
	for offset = 0, length - 1 do
		buffer.writeu8(buf, offset, math.random(0, 255))
	end
	return buf
end

-- module
return table.freeze {
	from_hex_str = from_hex_str,
	random = random,
}
