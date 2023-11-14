import { Router } from 'itty-router'
import { authRoute } from '../../helpers/action_input'
import { createOrGetSingletonDm } from './handlers'


export const chatRouter = Router({
    base: '/api/chat'
})

chatRouter.post('/getOrCreateDm', async (req: Request) => await authRoute(req, createOrGetSingletonDm))