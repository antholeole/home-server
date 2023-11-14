import { DEFAULT_USERNAME, GOOGLE_CERTS, GOOGLE_PEM_SRC, GOOGLE_VALID_AUDS, GOOGLE_VALID_ISSUER } from '../../../src/constants'
import { getFakeIdentifier, verifyIdTokenWithGoogle } from '../../../src/routers/auth/helpers'
import { verify } from 'jsonwebtoken'
import { beforeEach } from '@jest/globals'

jest.mock('jsonwebtoken')

const mockVerify = verify as jest.Mock

const mockDebugGetter = jest.fn()   
jest.mock('../../../src/constants', () => ({
  ...jest.requireActual('../../../src/constants'),
  get DEBUG() {
    return mockDebugGetter()
  },
}))

describe('auth helpers', () => {
    beforeEach(() => {
        mockDebugGetter.mockReturnValue(true)
    })

    afterEach(() => {
        mockDebugGetter.mockReset()
    })

    describe('verify id token with google', () => {
        describe('invalid', () => {
            test('should throw on invalid id token', async () => {
                await expect(
                    async () => await verifyIdTokenWithGoogle('not.threeparts')
                ).toThrowStatusError(400, 'invalid idToken JWT')
            })

            test('no KID in header should throw', async () => {
                const header = btoa(JSON.stringify({
                    nokid: 'nokid'
                }))

                await expect(
                    async () => await verifyIdTokenWithGoogle(`${header}.ada.ada`)
                ).toThrowStatusError(400, 'malformed JWT input; no KID in header')
            })

            test('invalid header format should throw', async () => {
                const header = 'im not correct'

                await expect(
                    async () => await verifyIdTokenWithGoogle(`${header}.ada.ada`)
                ).toThrowStatusError(400, 'malformed JWT input; no KID in header')
            })
        })

        describe('valid header', () => {
            const kid = 'fakekid'

            const validHeader = btoa(JSON.stringify({
                kid
            }))

            test('no google cert should fetch one with exp', async () => {
                const fakeCert = 'asdasdko'
                const fakeTime = 1000

                fetchMock.mockIf(GOOGLE_PEM_SRC, () => Promise.resolve({
                    body: fakeCert,
                    headers: {
                        'Cache-Control': `max-age=${fakeTime.toString()}`,
                        'other-header': 'other value'
                    }
                }))

                try {
                    await verifyIdTokenWithGoogle(`${validHeader}.dadsa.asdas`)
                } catch {
                    //will fail later down the line
                }

                expect(await PUBLIC_KEYS.get(GOOGLE_CERTS)).toEqual(fakeCert)
            })

            test('unverifiable jwt body should throw invalid id token', async () => {
                const fakeCert = 'asdasdko'
                const fakeTime = 1000

                fetchMock.mockIf(GOOGLE_PEM_SRC, () => Promise.resolve({
                    body: fakeCert,
                    headers: {
                        'max-age': fakeTime.toString(),
                        'other-header': 'other value'
                    }
                }))

                await expect(async () => await verifyIdTokenWithGoogle(`${validHeader}.dadsa.asdas`)).toThrowStatusError(402)
            })

            describe('verifiable json body', () => {
                const key = 'key'
                const sub = 'sub'
                const idToken = `${validHeader}.asdas.adas`
                const mockVerifiableJsonBody = (values: Record<string, unknown>) => {
                    mockVerify.mockReturnValue({
                        ...values,
                        sub: sub
                    })
                }

                afterEach(() => {
                    mockVerify.mockReset()
                })

                beforeEach(async () => {
                    await PUBLIC_KEYS.put(GOOGLE_CERTS, JSON.stringify({
                        [kid]: key
                    }))
                })

                test('should verify with and check iss and aud', async () => {
                    mockVerifiableJsonBody({})

                    await verifyIdTokenWithGoogle(idToken)

                    expect(mockVerify.mock.calls[0][1]).toMatch(key)
                    expect(mockVerify.mock.calls[0][2].audience.sort()).toEqual(GOOGLE_VALID_AUDS.sort())
                    expect(mockVerify.mock.calls[0][2].issuer.sort()).toEqual(GOOGLE_VALID_ISSUER.sort())
                })


                test('should return sub', async () => {
                    mockVerifiableJsonBody({})

                    const identifier = await verifyIdTokenWithGoogle(idToken)

                    expect(identifier.sub.startsWith('google:')).toBe(true)
                    expect(identifier.sub.endsWith(sub)).toBe(true)
                })

                test('should return sub', async () => {
                    mockVerifiableJsonBody({})

                    const identifier = await verifyIdTokenWithGoogle(idToken)

                    expect(identifier.sub.startsWith('google:')).toBe(true)
                    expect(identifier.sub.endsWith(sub)).toBe(true)
                })

                describe('name resolution', () => {
                    test('should give priority to explicit name', async () => {
                        const givenName = 'anthony'
                        const familyName = 'oleinik'

                        mockVerifiableJsonBody({
                            given_name: givenName,
                            family_name: familyName,
                        })

                        const indentifier = await verifyIdTokenWithGoogle(idToken)

                        expect(indentifier.name).toMatch(`${givenName} ${familyName}`)
                    })

                    test('should allow only given name', async () => {
                        const givenName = 'anthony'

                        mockVerifiableJsonBody({
                            given_name: givenName,
                        })

                        const indentifier = await verifyIdTokenWithGoogle(idToken)

                        expect(indentifier.name).toMatch(givenName)
                    })

                    test('should take email instead of name name', async () => {
                        const email = 'asdasd@asdas.com'

                        mockVerifiableJsonBody({
                            email
                        })

                        const indentifier = await verifyIdTokenWithGoogle(idToken)

                        expect(indentifier.name).toMatch(email.split('@')[0])
                    })

                    test('should default to default username if none other given', async () => {
                        mockVerifiableJsonBody({})

                        const indentifier = await verifyIdTokenWithGoogle(idToken)

                        expect(indentifier.name).toMatch(DEFAULT_USERNAME)
                    })
                })
            })
        })

    })

    describe('fake identifier', () => {
        test('should throw in non-debug', async () => {
            mockDebugGetter.mockReturnValue(false)

            await expect(async () => getFakeIdentifier(JSON.stringify({
                name: 'hi',
                sub: 'hi'
            }))).toThrowStatusError(400)
        })

        test('fails without name or sub', () => {
            for (const json of [JSON.stringify({
                name: 'name'
            }), JSON.stringify({
                sub: 'sub',
            }), JSON.stringify({})]) {
                expect(() => getFakeIdentifier(json)).toThrowStatusError(300) 
            }
        })

        test('passes on name and sub', () => {
            expect(getFakeIdentifier(JSON.stringify({
                name: 'anthony',
                sub: 'asdasd'
            }))).toEqual({
                name: 'anthony',
                sub: 'asdasd'
            })
        })
    })
})