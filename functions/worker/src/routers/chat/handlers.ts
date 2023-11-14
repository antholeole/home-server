import { json } from 'itty-router-extras'
import { IAuthActionInput } from '../../helpers/action_input'
import { createDm, getExistingDm } from './gql_queries'
import { ICreateOrGetSingletonDmRequest, IDmResponse } from './types'

export const createOrGetSingletonDm = async (req: IAuthActionInput<ICreateOrGetSingletonDmRequest>): Promise<Response> => {
    let respJson: IDmResponse

    const userIds: [string, string] = [req.input.with_user_id, req.session_variables['x-hasura-user-id']]

    const existing = await getExistingDm(userIds)

    if (existing) {
        respJson = existing
    } else {
        respJson = await createDm(userIds)
    }

    return json(respJson as unknown as Record<string, unknown>)
}