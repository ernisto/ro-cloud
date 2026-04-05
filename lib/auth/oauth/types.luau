export type permission = 'openid' | 'profile'

export type session = {
	access_token: string,
	refresh_token: string,
	token_type: 'Bearer' | string,
	expires_in: number,
	id_token: string?,
	scope: { permission },
	-- additional fields for session management
	created_at: number,
	expires_at: number,
}

export type oauth_error = {
	error: string,
	error_description: string?,
	error_uri: string?,
}

return nil
