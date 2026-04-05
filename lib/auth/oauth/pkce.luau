local base64 = require '@pkg/base64'
local bytes = require '@utils/bytes'
local serde = require '@lune/serde'

-- functions
type base64_url = string

local function encode_base64_url(content: buffer): base64_url
	return buffer.tostring(base64.encode(content)):gsub('%+', '-'):gsub('/', '_'):gsub('=', '')
end
local function generate_code_verifier(): base64_url
	return encode_base64_url(bytes.random(32))
end

local code_challenge = {}

function code_challenge.S256(verifier: base64_url): base64_url
	local hash = serde.hash('sha256', verifier)
	return encode_base64_url(bytes.from_hex_str(hash))
end
function code_challenge.plain(verifier: base64_url): base64_url
	return verifier
end

-- module
return table.freeze {
	generate_code_verifier = generate_code_verifier,
	generate_code_challenge = code_challenge,
}
