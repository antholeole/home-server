import jwt from 'jsonwebtoken'

const ISSUER = 'Club App'

export const encodeJwt = (payload: Record<string, unknown>, opts?: jwt.SignOptions): string => {
    return jwt.sign(payload, SECRET, {
        ...(opts ?? {}), //cannot override defaults
        issuer: ISSUER,
        expiresIn: '1h',
    })
}