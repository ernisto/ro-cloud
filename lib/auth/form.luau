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

-- module
local function form()
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

export type form_builder = typeof(form())
return form
