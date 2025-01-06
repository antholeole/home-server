import Router from "@koa/router";
import { room } from "./tldraw.ts";

export const tldrawRouter = new Router().get("/draw/connect", (ctx) => {
	const sessionId = ctx.request.query.sessionId as string | undefined;

	if (sessionId === undefined) {
		ctx.response.status = 401;
		ctx.response.body = "please add a sessionId parameter";
		return;
	}

	const socket = ctx.upgrade();
	room.handleSocketConnect({ socket, sessionId });
	return new Response(null, { status: 101 });
});
