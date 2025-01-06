import Koa from "koa";
import { tldrawRouter } from "./tldraw/router";

const app = new Koa();

app.use(tldrawRouter.routes());

if (import.meta.env.PROD) {
	app.listen(3000);
	console.log("running on http://localhost:3000");
}

export const viteNodeApp = app;
