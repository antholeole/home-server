import { StatusError, json } from 'itty-router-extras'
import { IAccessTokenRequest, IRefreshRequest } from './types'
import { generateAccessToken, getFakeIdentifier, IIdentifier, verifyIdTokenWithGoogle } from './helpers'
import { addUser, getUserBySub } from './gql_queries'
import { cryptoRandomString } from '../../helpers/crypto'
import { getDecryptedKV, putEncryptedKV } from 'encrypt-workers-kv'
import { IActionInput } from '../../helpers/action_input'

export const registerRoute = async (req: IActionInput<IAccessTokenRequest>): Promise<Response> => {
    let identifier: IIdentifier
    switch (req.input.identityProvider) {
        case 'Google':
            identifier = await verifyIdTokenWithGoogle(req.input.idToken)
            break
        case 'Debug':
            identifier = getFakeIdentifier(req.input.idToken)
            break
    }

    let user = await getUserBySub(identifier.sub)

    if (user == null) {
        user = await addUser(identifier.sub, identifier.name, identifier.email)
    }

    const refreshUnhashed = cryptoRandomString(300)

    await putEncryptedKV(REFRESH_TOKENS, user.id, refreshUnhashed, SECRET)

    const aToken = generateAccessToken(user.id)
    return json({
        accessToken: aToken,
        refreshToken: refreshUnhashed,
        id: user.id,
        email: user.email,
        name: user.name
    })
}

export const refreshRoute = async (input: IActionInput<IRefreshRequest>): Promise<Response> => {
    let decryptedHash: ArrayBuffer
    try {
        decryptedHash = await getDecryptedKV(REFRESH_TOKENS, input.input.userId, SECRET)
    } catch (e: unknown) {
        // eslint-disable-next-line @typescript-eslint/ban-types
        if ((e as object).constructor.name == 'NotFoundError') {
            throw new StatusError(404, `user with id ${input.input.userId} not found`)
        } else {
            throw e
        }
    }

    if (new TextDecoder().decode(decryptedHash) === input.input.refreshToken) {
        return json({ accessToken: generateAccessToken(input.input.userId) })
    } else {
        throw new StatusError(402, `invalid refresh token ${input.input.refreshToken}`) //returns 402 to avoid loop
    }
}