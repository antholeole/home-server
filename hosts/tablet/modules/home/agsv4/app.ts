import app from "ags/gtk4/app";
import style from "./style.scss";
import Bar from "./widget/Bar";
import Launcher, {
	launcherVisible,
	setLauncherVisible,
} from "./widget/Launcher";
import type GObject from "gi://GObject?version=2.0";
import type { Gdk } from "ags/gtk4";

app.start({
	instanceName: DEV ?? "astal",
	css: style,
	requestHandler(request: string, res: (response: unknown) => void) {
		if (request.startsWith("open-launcher")) {
			setLauncherVisible(true);
			res("ok!");
		} else if (request.startsWith("close-launcher")) {
			setLauncherVisible(false);
			res("ok!");
		} else if (request.startsWith("toggle-launcher")) {
			const newValue = !launcherVisible.get();
			setLauncherVisible(newValue);

			res("ok!");
		} else {
			res(`command ${request} not found`);
		}
	},

	main() {
		const drawWindow = (window: (w: Gdk.Monitor) => GObject.Object) => {
			app.get_monitors().map((monitor) => {
				window(monitor);
			});
		};

		drawWindow(Launcher);
		drawWindow(Bar);
	},
});
