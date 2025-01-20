import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import { fileURLToPath } from "url";

const host = process.env.TAURI_DEV_HOST;

export default defineConfig(async () => {
  return {
    plugins: [react()],

    build: {
      rollupOptions: {
        input: {
          tldraw: fileURLToPath(new URL("./windows/tldraw.html", import.meta.url)),
        }
      }
    },

    // prevent vite from obscuring rust errors
    clearScreen: false,
    // tauri expects a fixed port, fail if that port is not available
    server: {
      port: 1420,
      strictPort: true,
      host: host || false,
      hmr: host
        ? {
          protocol: "ws",
          host,
          port: 1421,
        }
        : undefined,
      watch: {
        // 3. tell vite to ignore watching `src-tauri`
        ignored: ["**/src-tauri/**"],
      },
    },
    optimizeDeps: { exclude: ["@tldraw/assets"] },
  };
});
