import app from "ags/gtk4/app";
import style from "./style.scss";
import Bar from "./widget/Bar";
import Launcher from "./widget/Launcher";
import type GObject from "gi://GObject?version=2.0";
import type { Gdk } from "ags/gtk4";

app.start({
	css: style,
	main(args) {
		if (!args) {
			throw Error("need some args");
		}
		
		const drawWindow = (window: (w: Gdk.Monitor) => GObject.Object) => {
			app.get_monitors().map((monitor) => {
				window(monitor);
			});
		};

		if (args.includes("--launcher")) {
			drawWindow(Launcher);
		}

		if (args.includes("--shell")) {
			drawWindow(Bar);
		}
	},
});
