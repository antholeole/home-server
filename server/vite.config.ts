import { defineConfig } from "vite";
import { VitePluginNode } from "vite-plugin-node";

export default defineConfig({
	server: {
		port: 3000,
	},
	plugins: [
		...VitePluginNode({
			adapter: "koa",
			appPath: "./src/server/main.ts",
			exportName: "viteNodeApp",
			initAppOnBoot: false,
			tsCompiler: "esbuild",
			swcOptions: {},
		}),
	],
});
