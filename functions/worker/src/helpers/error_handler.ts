import { StatusError } from 'itty-router-extras'
import { DEBUG } from '../constants'

export const errorHandler = (e: Error): Response => {
    console.debug(`got ${e.name}: ${e.message}`)
    if (e instanceof StatusError) {
        return new Response(JSON.stringify({
            'message': e.message,
            'code': e.status
        }))
    } else if (DEBUG) {
        console.error(e)
        console.error(e.message)
        console.error(e.name)
        throw e
    } else {
        return new Response(JSON.stringify({
            'message': e.message || 'unknown error',
            'code': 400
        }))
    }

}