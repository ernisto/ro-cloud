-- TODO

local crypto = require '@lute/crypto'
local json = require '@std/json'
local net = require '@lute/net'

-- defs
type params = {
	url: string,
	method: string,
	query: { [string]: any }?,
	headers: { [string]: any }?,
	body: string?,
}
export type response = {
	ok: boolean,
	body: string,
	statusCode: number,
	statusMessage: string,
	headers: { [string]: any },
}

-- functions
local function encode_url(input)
	return input
end
local function encode_base64(input: buffer): string
	return ''
end
local function request(params: params): response
	local url = params.url
	local res = net.client.request(url, params)
	return {
		ok = res.ok,
		body = res.body,
		headers = res.headers,
		statusCode = res.statusCode,
		statusMessage = res.statusMessage,
	}
end

-- module
return table.freeze {
	sha256 = crypto.hash.sha256,
	base64 = table.freeze { encode = encode_base64 },
	net = table.freeze { request = request, encode = encode_url },
	json = table.freeze { encode = json.serialize, decode = json.deserialize },
}
