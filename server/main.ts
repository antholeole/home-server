import { Application } from "jsr:@oak/oak/application";
import logger from "https://deno.land/x/oak_logger@1.0.0/mod.ts";
import { tldrawRouter } from "./tldraw/router.ts";

const app = new Application();

app.use(logger.logger);

app.use(tldrawRouter.routes());

await app.listen({ port: 8000 });
