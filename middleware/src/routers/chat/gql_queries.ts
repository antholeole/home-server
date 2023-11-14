import { gqlReq } from '../../helpers/gql_connector'
import { IDmResponse } from './types'

export const getExistingDm = async (userIds: [string, string]): Promise<IDmResponse | void> => {
  const { dms } = await gqlReq(`
  query {
    dms(where: {
      _and: {
        user_to_dms: {
          user_id: {
            _in: ["${userIds[0]}", "${userIds[1]}"]
          }
        },
        _not: {
          user_to_dms: {
            user_id: {
              _nin: ["${userIds[0]}", "${userIds[1]}"]
            }
          }
        }
      }
    }) {
      id,
      name,
    }
  }
      `)

  return (dms[0] ?? null)
}

export const createDm = async (userIds: [string, string]): Promise<IDmResponse> => {
  const { insert_dms_one } = await gqlReq(`
  mutation {
    insert_dms_one(object: {
      user_to_dms: {
        data: [{
          user_id: "${userIds[0]}"
        },
        {
          user_id: "${userIds[1]}"
        }
        ]
      }
    }) {
      id,
      name
    }
  }
  `)

  return insert_dms_one
}