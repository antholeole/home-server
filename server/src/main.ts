import { tldraw } from "./tldraw/router.ts";
import Fastify from 'fastify'
import websocketPlugin from '@fastify/websocket'

const fastify = Fastify({
	logger: true
});

fastify.register(websocketPlugin);
fastify.register(tldraw);

await fastify.listen({ port: 3000 });

