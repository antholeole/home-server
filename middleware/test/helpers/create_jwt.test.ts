import { encodeJwt } from '../../src/helpers/create_jwt'
import jwt from 'jsonwebtoken'

jest.mock('jsonwebtoken')
jwt


const verify = jwt.verify as jest.MockedFunction<(token: string, secretOrPublicKey: jwt.Secret, options?: jwt.VerifyOptions,) => Record<string, unknown> | string>
const sign = jwt.sign as jest.MockedFunction<(token: string, secretOrPublicKey: jwt.Secret, options?: jwt.VerifyOptions | undefined) => string | Record<string, unknown>>

describe('jwt', () => {
    afterEach(() => {
        verify.mockReset()
    })

    beforeEach(() => {
        sign.mockReset()
        sign.mockReturnValueOnce('valid')
    })

    describe('enconde', () => {
        test('should allow no options', () => {
            expect(() => encodeJwt({ 'encode': 'me' })).not.toThrow()
        })

        test('should allow other options', () => {
            const fakeAud = 'Fake aud'

            encodeJwt({ 'encode': 'me' }, {
                audience: fakeAud
            })

            expect(sign.mock.calls[0][2]?.audience).toEqual(fakeAud)
        })
    })
})