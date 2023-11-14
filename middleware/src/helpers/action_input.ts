import { StatusError } from 'itty-router-extras'

export interface IActionInput<T> {
    action: string,
    input: T,
    session_variables: {
        [k: string]: unknown
    }
}

export interface IAuthActionInput<T> extends IActionInput<T> {
    session_variables: {
        'x-hasura-user-id': string
    },
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const verifyReqFromServer = (req: Request, jsonBody: any): jsonBody is IActionInput<any> => {
    if (req.headers.get('WEBHOOK_SECRET_KEY') != WEBHOOK_SECRET_KEY) {
        //TODO security report
        throw new StatusError(401, 'unauthorized endpoint access')
    }

    return true
}

export const unauthRoute = async <T>(req: Request, handler: (p0: IActionInput<T>) => Promise<Response>): Promise<Response> => {
    const body = await req.json()
    verifyReqFromServer(req, body)
    return handler(body)
}

export const authRoute = async <T>(req: Request, handler: (p0: IAuthActionInput<T>) => Promise<Response>): Promise<Response> => {
    const body = await req.json()

    verifyReqFromServer(req, body)

    if (body.session_variables['x-hasura-user-id'] == null) {
        throw new StatusError(401, 'please authorize')
    }

    return handler(body)
}