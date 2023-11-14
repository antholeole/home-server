import { Router } from 'itty-router'
import { unauthRoute } from '../../helpers/action_input'
import { refreshRoute, registerRoute } from './handlers'


export const authRouter = Router({
  base: '/api/auth'
})

authRouter.post('/', async (req: Request) => await unauthRoute(req, registerRoute))
authRouter.post('/refresh', async (req: Request) => unauthRoute(req, refreshRoute))