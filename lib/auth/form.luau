-- vendor from https://github.com/0jewell/bnnuy/blob/master/src/api/form.luau

-- types
export type parts = { string }
export type boundary = string

-- functions
local function insert_boundary(parts: parts, boundary: boundary)
	table.insert(parts, '--' .. boundary .. '\r\n')
end
local function insert_value(parts: parts, value: string)
	table.insert(parts, value .. '\r\n')
end

local function form_builder()
	local boundary = `----boundary{os.time()}`
	local parts = {}
	local self = { boundary = boundary }

	function self.text(name: string, value: string | number | boolean)
		insert_boundary(parts, boundary)
		insert_value(parts, `Content-Disposition: form-data; name="{name}"\r\n`)
		insert_value(parts, tostring(value))

		return self
	end

	function self.file(name: string, file_name: string, content_type: string, content: buffer)
		insert_boundary(parts, boundary)
		insert_value(parts, `Content-Disposition: form-data; name="{name}"; filename="{file_name}"`)
		insert_value(parts, `Content-Type: {content_type}\r\n`)
		insert_value(parts, buffer.tostring(content))

		return self
	end

	function self.build(): string
		insert_value(parts, `--{boundary}--`)
		return table.concat(parts)
	end

	return self
end

local function form_by_table(fields: {}): string
	local f = form_builder()
	for name, value in fields :: any do
		if type(value) == 'buffer' then
			f.file(name, 'icon.png', 'image/png', value)
		else
			f.text(name, value :: any)
		end
	end
	return f.build(), `multipart/form-data; boundary={f.boundary}`
end

-- module
export type form_builder = typeof(form_builder())
return table.freeze { builder = form_builder, by_table = form_by_table }
