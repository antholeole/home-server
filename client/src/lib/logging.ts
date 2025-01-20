import { trace, info, debug, warn, error } from "@tauri-apps/plugin-log";

export const setupLogging = async () => {
	if (import.meta.env.VITE_VIEWPORT_MODE !== "web") {
		window.console = {
			...window.console,
			trace,
			info,
			debug,
			warn,
			error,
			log: info,
		};

		console.info("logging initalized");
	}
};
