import * as chatGqlQueries from '../../../src/routers/chat/gql_queries'
import { createOrGetSingletonDm } from '../../../src/routers/chat/handlers'

describe('chat routes', () => {
    const fakeId = 'ididid'
    const fakeName = 'fakeName'
    const fakeIdTwo = 'idtwoidtwo'
    const userInputId = 'xhasurauserid'

    describe('get or create singleton dm', () => {
        test('should create dm if no existing dm', async () => {
            const getExistingDmSpy = jest.spyOn(chatGqlQueries, 'getExistingDm')
                .mockReturnValue(Promise.resolve({
                    id: fakeId,
                    name: fakeName,
                }))

            const resp = await createOrGetSingletonDm({
                action: 'fkae',
                session_variables: {
                    'x-hasura-user-id': userInputId
                },
                input: {
                    with_user_id: fakeIdTwo,
                }
            })
            expect(await resp.json()).toMatchObject({
                id: fakeId,
                name: fakeName,
            })

            expect(getExistingDmSpy.mock.calls[0][0]).toEqual([fakeIdTwo, userInputId])
        })

        test('should return existing dm if dm exists', async () => {
            jest.spyOn(chatGqlQueries, 'getExistingDm')
                .mockReturnValue(Promise.resolve())

            const createDmSpy = jest.spyOn(chatGqlQueries, 'createDm')
                .mockReturnValue(Promise.resolve({
                    id: fakeId,
                    name: fakeName,
                }))

            const resp = await createOrGetSingletonDm({
                action: 'fkae',
                session_variables: {
                    'x-hasura-user-id': userInputId
                },
                input: {
                    with_user_id: fakeIdTwo,
                }
            })
            expect(await resp.json()).toMatchObject({
                id: fakeId,
                name: fakeName,
            })

            expect(createDmSpy.mock.calls[0][0]).toEqual([fakeIdTwo, userInputId])
        })
    })
})