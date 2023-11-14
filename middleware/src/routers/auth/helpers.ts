import { DEBUG, DEFAULT_USERNAME, GOOGLE_CERTS, GOOGLE_PEM_SRC, GOOGLE_VALID_AUDS, GOOGLE_VALID_ISSUER } from '../../constants'
import { StatusError } from 'itty-router-extras'
import { encodeJwt } from '../../helpers/create_jwt'
import jwt from 'jsonwebtoken'


export interface IIdentifier {
    sub: string,
    email?: string,
    name: string
}

interface IGoogleAccessToken {
    family_name: string
    given_name: string
    sub: string
    email?: string
}

export const verifyIdTokenWithGoogle = async (idToken: string): Promise<IIdentifier> => {
    const parts = idToken.split('.')

    let kid
    if (parts.length < 3) {
        throw new StatusError(400, 'invalid idToken JWT')
    } else {
        const noKid = new StatusError(400, 'malformed JWT input; no KID in header')
        try {
            kid = JSON.parse(atob(parts[0]))['kid']
        } catch {
            throw noKid
        }

        if (!kid) {
            throw noKid
        }
    }

    let googleCertsJson = await PUBLIC_KEYS.get(GOOGLE_CERTS)

    if (googleCertsJson == null) {
        const resp = await fetch(GOOGLE_PEM_SRC)

        googleCertsJson = await resp.text()

        const maxAge = resp.headers.get('Cache-Control')?.split(', ')
            .find((v) => v.startsWith('max-age='))
            ?.split('=')[1] as string

        await PUBLIC_KEYS.put(GOOGLE_CERTS, googleCertsJson, {
            expirationTtl: parseInt(maxAge) - 60
        })
    }

    let jwtBody: IGoogleAccessToken
    try {
        jwtBody = (jwt.verify(idToken, JSON.parse(googleCertsJson)[kid], {
            audience: GOOGLE_VALID_AUDS,
            issuer: GOOGLE_VALID_ISSUER
        }) as IGoogleAccessToken)
    } catch {
        throw new StatusError(402, 'Invalid id token.')
    }


    const returnedIdentfier: Partial<IIdentifier> = {}
    returnedIdentfier.sub = 'google:' + jwtBody['sub']

    if (jwtBody['given_name']) {
        returnedIdentfier.name =
            `${jwtBody['given_name']} ${jwtBody['family_name'] ?? ''}`.trim()
    }

    if (jwtBody['email']) {
        returnedIdentfier.email = jwtBody['email']

        if (!returnedIdentfier.name) {
            returnedIdentfier.name = jwtBody['email'].split('@')[0]
        }
    }

    if (!returnedIdentfier.name) {
        returnedIdentfier.name = DEFAULT_USERNAME
    }

    return returnedIdentfier as IIdentifier
}


export const getFakeIdentifier = (accessToken: string): IIdentifier => {
    if (!DEBUG) {
        throw new StatusError(400, 'Debug Access Tokens only allowed in dev.')
    }
    const identifier: IIdentifier = JSON.parse(accessToken)

    if (!identifier?.name || !identifier?.sub) {
        throw new StatusError(300, 'invalid input')
    }

    return identifier
}

export const generateAccessToken = (id: string): string => {
    return encodeJwt({
        sub: id,
        'https://hasura.io/jwt/claims': {
            'x-hasura-allowed-roles': ['user', 'guest'],
            'x-hasura-user-id': id,
            'x-hasura-default-role': 'user'
        }
    })
}