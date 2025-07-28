import { Astal, type Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import { subprocess } from "ags/process";

// TODO: don't configure here. but whatever.
const apps = {
	firefox: "firefox",
	terminal: "alacritty",
};

const launchApp = (exe: string) => {
	subprocess(
		`hyprctl dispatch exec ${exe} ; hyprctl dispatch closewindow class:launcher`,
	);
};

function AppIcon({
	appIdentifier,
	exe,
}: { appIdentifier: string; exe: string }) {
	return (
		<button class="app-icon" onClicked={() => launchApp(exe)}>
			<box orientation={Gtk.Orientation.VERTICAL}>
				<image pixelSize={90} file={`${SRC}/icons/${appIdentifier}.png`} />
				<label class="text" label={appIdentifier} />
			</box>
		</button>
	);
}

export default function Launcher(gdkmonitor: Gdk.Monitor) {
	return (
		<window
			visible
			name="launcher"
			class="launcher"
			namespace="launcher"
			gdkmonitor={gdkmonitor}
			exclusivity={Astal.Exclusivity.IGNORE}
			application={app}
		>
			<box orientation={Gtk.Orientation.HORIZONTAL}>
				{Object.entries(apps).map(([appIdentifier, exe]) => (
					<AppIcon appIdentifier={appIdentifier} exe={exe} />
				))}
			</box>
		</window>
	);
}
