import type { FastifyInstance } from "fastify";
import { room } from "./tldraw.ts";

export const tldraw = async (app: FastifyInstance) => {
	// This is the main entrypoint for the multiplayer sync
	app.get('/draw/connect', { websocket: true }, async (socket, req) => {
		const sessionId = (req.query as any)?.['sessionId'] as string
		room.handleSocketConnect({ sessionId, socket })
	})
}
