export interface IAccessTokenRequest {
    idToken: string,
    identityProvider: 'Google' | 'Debug'
}

export interface IRefreshRequest {
    refreshToken: string
    userId: string
}
