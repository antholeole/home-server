import { Router } from "oak";
import { room } from "./tldraw.ts";
import { Status } from "oak";

export const tldrawRouter = new Router().get("/draw/connect", (ctx) => {
	const sessionId = ctx.request.url.searchParams.get("sessionId");

	if (sessionId === null) {
		ctx.response.status = Status.BadRequest;
		ctx.response.body = "please add a sessionId parameter";
		return;
	}

	const socket = ctx.upgrade();
	room.handleSocketConnect({ socket, sessionId });
	return new Response(null, { status: Status.SwitchingProtocols });
});
