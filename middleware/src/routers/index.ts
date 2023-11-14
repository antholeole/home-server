import { StatusError } from 'itty-router-extras'
import { Router } from 'itty-router'
import { authRouter } from './auth/router'
import { chatRouter } from './chat/router'

const localRouter = Router()

localRouter
  .all('/api/auth/*', authRouter.handle)
  .all('/api/chat/*', chatRouter.handle)
  .get('/api/ping', () => new Response('pong'))
  .all('/api/*', () => {
    throw new StatusError(404, 'Api route not found')
  })

export const router = localRouter