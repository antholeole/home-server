import { Accessor, createState } from "ags";
import { Astal, type Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import { subprocess } from "ags/process";

export const [launcherVisible, setLauncherVisible] = createState(
	DEV !== undefined,
);

// TODO: don't configure here. but whatever.
const apps = {
	firefox: "firefox",
	terminal: "alacritty",
};

const launchApp = (exe: string) => {
	subprocess(`hyprctl dispatch exec ${exe}`);

	setLauncherVisible(false);
};

function AppIcon({
	appIdentifier,
	exe,
}: { appIdentifier: string; exe: string }) {
	return (
		<button class="app-icon transparent" onClicked={() => launchApp(exe)}>
			<box orientation={Gtk.Orientation.VERTICAL} class="container">
				<image pixelSize={90} file={`${SRC}/icons/${appIdentifier}.png`} />
				<label class="text" label={appIdentifier} />
			</box>
		</button>
	);
}

export default function Launcher(gdkmonitor: Gdk.Monitor) {
	const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor;

	return (
		<window
			visible={launcherVisible}
			name="launcher"
			namespace="launcher"
			class="transparent"
			anchor={TOP | LEFT | RIGHT | BOTTOM}
			gdkmonitor={gdkmonitor}
			exclusivity={Astal.Exclusivity.IGNORE}
			application={app}
		>
			<overlay>
				<Gtk.GestureClick
					onPressed={() => {
						setLauncherVisible(false);
						launcherVisible.get()
					}}
				/>
				<box
					$type="overlay"
					orientation={Gtk.Orientation.VERTICAL}
					valign={Gtk.Align.CENTER}
					vexpand={false}
				>
					<box
						orientation={Gtk.Orientation.HORIZONTAL}
						hexpand={true}
						halign={Gtk.Align.CENTER}
					>
						<box class="launcher">
							{Object.entries(apps).map(([appIdentifier, exe]) => (
								<AppIcon appIdentifier={appIdentifier} exe={exe} />
							))}
						</box>
					</box>
				</box>
			</overlay>
		</window>
	);
}
