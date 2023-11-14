import { gqlReq } from '../../src/helpers/gql_connector'

describe('gql connector', () => {
    let validResponse: Response

    beforeEach(() => {
        //refresh validResposne or will get "body already used for ..."
        validResponse = new Response(JSON.stringify({
            data: {
                fake: 'Data'
            }
        }), {
            status: 200
        })
    })

    const fakeQuery = `query {
        users_by_pk(id: "id") {
            id
      }
    }`

    test('should post to HASURA_ENDPOINT w/ admin header and stringified body', async () => {
        fetchMock.mockResolvedValueOnce(validResponse)

        await gqlReq(fakeQuery)


        expect(fetchMock.mock.calls[0][0]).toEqual(HASURA_ENDPOINT)
        expect(fetchMock.mock.calls[0][1]?.headers).toMatchObject({
            'Content-Type': 'application/json',
            'x-hasura-admin-secret': HASURA_PASSWORD
        })
        expect(fetchMock.mock.calls[0][1]?.body).toEqual(JSON.stringify({
            query: fakeQuery
        }))
    })

    describe('on ok', () => {
        beforeEach(() => {
            fetchMock.mockResolvedValueOnce(validResponse)
        })

        test('should return body.data as json', async () => {
            const resp = await gqlReq(fakeQuery)

            expect((resp as { fake: string }).fake).toEqual('Data')
        })
    })

    describe('on not ok', () => {
        test('should throw 502 if couldn\'t connect to endpoint', async () => {
            fetchMock.mockRejectOnce(new Error('error'))

            await expect(async () => await gqlReq(fakeQuery)).toThrowStatusError(502)
        })

        test('should throw error if not 200', async () => {
            fetchMock.mockResolvedValueOnce(new Response(JSON.stringify({
                data: 'Im a json'
            }), {
                status: 400
            }))

            await expect(async () => await gqlReq(fakeQuery)).toThrowStatusError(502)
        })
    })
})