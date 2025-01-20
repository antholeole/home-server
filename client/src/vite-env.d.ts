/// <reference types="vite/client" />

interface ImportMetaEnv {
	readonly VITE_VIEWPORT_MODE: "web" | "tauri";
}

interface ImportMeta {
	readonly env: ImportMetaEnv;
}
