import { authRoute, unauthRoute } from '../../src/helpers/action_input'
import { mockRequest } from '../fixtures/mock_request'

describe('action input', () => {
    const fakeReq = jest.fn()

    const fakeBody = {
        'im fake': 'body'
    }

    beforeEach(() => {
        fakeReq.mockReset()
    })

    describe('unauth route', () => {
        test('should throw on invalid webhook key', async () => {
            await expect(async () => await unauthRoute(mockRequest(fakeBody, {
                WEBHOOK_SECRET_KEY: 'not secret key'
            }), fakeReq)).toThrowStatusError(401)
        })

        test('should call handler with values', async () => {
            await unauthRoute(mockRequest(fakeBody, {
                WEBHOOK_SECRET_KEY: WEBHOOK_SECRET_KEY
            }), fakeReq)

            expect(fakeReq.mock.calls.length).toBe(1)
            expect(fakeReq.mock.calls[0][0]).toEqual(fakeBody)
        })
    })

    describe('auth route', () => {
        const request = (userId?: string) => ({
            ...fakeBody,
            session_variables: {
                'x-hasura-user-id': userId
            }
        })

        test('should throw on invalid webhook key', async () => {
            await expect(async () => await authRoute(mockRequest(request('sdasdaoisdoi'), {
                WEBHOOK_SECRET_KEY: 'not secret key'
            }), fakeReq)).toThrowStatusError(401)
        })

        test('should throw on null authorization', async () => {
            await expect(async () => await authRoute(mockRequest(request(), {
                WEBHOOK_SECRET_KEY: WEBHOOK_SECRET_KEY
            }), fakeReq)).toThrowStatusError(401)
        })

        test('should call handler', async () => {
            const authHeader = 'asdopkasdopkas'

            await authRoute(mockRequest(request(authHeader), {
                WEBHOOK_SECRET_KEY: WEBHOOK_SECRET_KEY
            }), fakeReq)

            expect(fakeReq.mock.calls.length).toBe(1)
            expect(fakeReq.mock.calls[0][0]).toEqual(request(authHeader))
        })
    })
})