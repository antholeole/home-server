import { getDecryptedKV, putEncryptedKV } from 'encrypt-workers-kv'
import * as authHelpers from '../../../src/routers/auth/helpers'
import * as authGqlQueries from '../../../src/routers/auth/gql_queries'
import { refreshRoute, registerRoute } from '../../../src/routers/auth/handlers'

describe('auth routes', () => {
    describe('register route', () => {
        describe('new user', () => {
            const userName = 'anthony'
            const userSub = 'subject'
            const userId = 'userId'
            const userEmail = 'im an email'

            beforeEach(() => {
                jest.spyOn(authGqlQueries, 'getUserBySub')
                    .mockReturnValue(Promise.resolve(null))
            })

            test('should add user with no email', async () => {
                const addUserStub = jest.spyOn(authGqlQueries, 'addUser').mockReturnValue(Promise.resolve({
                    id: userId,
                    name: userName,
                    sub: userSub
                }))


                jest.spyOn(authHelpers, 'verifyIdTokenWithGoogle').mockReturnValue(Promise.resolve({
                    name: userName,
                    sub: userSub,
                }))

                await registerRoute({
                    action: 'adasd',
                    input: {
                        identityProvider: 'Google',
                        idToken: 'fake.id.token'
                    },
                    session_variables: {}
                })

                expect(addUserStub.mock.calls[0]).toEqual([userSub, userName, undefined])
            })

            test('should add user with email', async () => {
                const addUserStub = jest.spyOn(authGqlQueries, 'addUser').mockReturnValue(Promise.resolve({
                    id: userId,
                    name: userName,
                    sub: userSub
                }))

                jest.spyOn(authHelpers, 'verifyIdTokenWithGoogle').mockReturnValue(Promise.resolve({
                    name: userName,
                    sub: userSub,
                    email: userEmail
                }))

                await registerRoute({
                    action: 'adasd',
                    input: {
                        identityProvider: 'Google',
                        idToken: 'fake.id.token'
                    },
                    session_variables: {}
                })


                expect(addUserStub.mock.calls[0]).toEqual([userSub, userName, userEmail])
            })

            test('should create refresh token', async () => {
                jest.spyOn(authGqlQueries, 'addUser').mockReturnValue(Promise.resolve({
                    id: userId,
                    name: userName,
                    sub: userSub
                }))

                const verifyStub = jest.spyOn(authHelpers, 'verifyIdTokenWithGoogle')

                verifyStub.mockReturnValue(Promise.resolve({
                    name: userName,
                    sub: userSub,
                }))

                await registerRoute({
                    action: 'adasd',
                    input: {
                        identityProvider: 'Google',
                        idToken: 'fake.id.token'
                    },
                    session_variables: {}
                })

                expect(new TextDecoder().decode(await getDecryptedKV(REFRESH_TOKENS, userId, SECRET))).not.toBeNull

                REFRESH_TOKENS.delete(userId)
                verifyStub.mockClear()

                verifyStub.mockReturnValue(Promise.resolve({
                    name: userName,
                    sub: userSub,
                    email: userEmail
                }))

                await registerRoute({
                    action: 'adasd',
                    input: {
                        identityProvider: 'Google',
                        idToken: 'fake.id.token'
                    },
                    session_variables: {}
                })

                expect(new TextDecoder().decode(await getDecryptedKV(REFRESH_TOKENS, userId, SECRET))).not.toBeNull
            })

            describe('provider', () => {
                test('google should verify with google', async () => {
                    jest.spyOn(authGqlQueries, 'addUser').mockReturnValue(Promise.resolve({
                        id: userId,
                        name: userName,
                        sub: userSub
                    }))

                    const verifyStub = jest.spyOn(authHelpers, 'verifyIdTokenWithGoogle')

                    verifyStub.mockReturnValue(Promise.resolve({
                        name: userName,
                        sub: userSub,
                    }))

                    await registerRoute({
                        action: 'adasd',
                        input: {
                            identityProvider: 'Google',
                            idToken: 'fake.id.token'
                        },
                        session_variables: {}
                    })

                    expect(verifyStub.mock.calls.length).toBe(1)
                })

                test('debug should call get debug key', async () => {
                    jest.spyOn(authGqlQueries, 'addUser').mockReturnValue(Promise.resolve({
                        id: userId,
                        name: userName,
                        sub: userSub
                    }))

                    const verifyStub = jest.spyOn(authHelpers, 'getFakeIdentifier')

                    verifyStub.mockReturnValue({
                        name: userName,
                        sub: userSub,
                    })

                    await registerRoute({
                        action: 'adasd',
                        input: {
                            identityProvider: 'Debug',
                            idToken: JSON.stringify({
                                'name': 'hi',
                                'sub': 'blah'
                            })
                        },
                        session_variables: {}
                    })

                    expect(verifyStub.mock.calls.length).toBe(1)
                })
            })
        })

        test('should get old user if one exists', async () => {
            const userName = 'anthony'
            const userSub = 'subject'
            const userId = 'userId'
            const userEmail = 'im an email'

            const startingRefreshToken = 'STARTING REFRESH TOKEN'

            REFRESH_TOKENS.put(userId, startingRefreshToken)

            jest.spyOn(authHelpers, 'verifyIdTokenWithGoogle').mockReturnValue(Promise.resolve({
                name: userName,
                sub: userSub,
            }))

            jest.spyOn(authGqlQueries, 'getUserBySub').mockReturnValue(Promise.resolve({
                id: userId,
                name: userName,
                sub: userSub,
                email: userEmail
            }))

            const resp = await registerRoute({
                action: 'adasd',
                input: {
                    identityProvider: 'Google',
                    idToken: 'fake.id.token'
                },
                session_variables: {}
            })

            expect(await resp.json()).toHaveProperty('id', userId)

            //'should have changed refresh token'
            expect(new TextDecoder().decode(await getDecryptedKV(REFRESH_TOKENS, userId, SECRET))).not.toEqual(startingRefreshToken)
        })
    })

    describe('refresh', () => {
        test('should refresh the token if it exists in the KV storage', async () => {
            const testUserId = 'test_id'
            const fakeRefreshToken = 'fake_refresh_token'

            await putEncryptedKV(REFRESH_TOKENS, testUserId, fakeRefreshToken, SECRET)

            const resp = await refreshRoute({
                action: 'asdasd',
                input: {
                    userId: testUserId,
                    refreshToken: fakeRefreshToken
                },
                session_variables: {}
            })

            expect(resp.status).toEqual(200)
        })

        test('should 404 if user does not exist in the KV storage', async () => {
            const testUserId = 'test_id'
            const fakeRefreshToken = 'fake_refresh_token'

            await expect(async () => await refreshRoute({
                action: 'asdasd',
                input: {
                    userId: testUserId,
                    refreshToken: fakeRefreshToken
                },
                session_variables: {}
            })).toThrowStatusError(404)
        })

        test('should 402 if refresh token is different', async () => {
            const testUserId = 'test_id'
            const fakeRefreshToken = 'fake_refresh_token'
            const notFakeRefreshToken = 'not_fake_refresh_token'

            await putEncryptedKV(REFRESH_TOKENS, testUserId, fakeRefreshToken, SECRET)

            await expect(async () => await refreshRoute({
                action: 'asdasd',
                input: {
                    refreshToken: notFakeRefreshToken,
                    userId: testUserId
                },
                session_variables: {}
            })).toThrowStatusError(402)
        })
    })
})
