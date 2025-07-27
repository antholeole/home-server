import app from "ags/gtk4/app";
import { Astal, Gtk, type Gdk } from "ags/gtk4";
import { createPoll } from "ags/time";
import AstalBattery from "gi://AstalBattery?version=0.1";

export default function Bar(gdkmonitor: Gdk.Monitor) {
	const time = createPoll("", 1000, "date '+%I:%M %p'");
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;


	return (
		<window
			visible
			name="bar"
			class="bar"
			namespace="bar"
			gdkmonitor={gdkmonitor}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
			anchor={TOP | LEFT | RIGHT}
			application={app}
		>
			<box orientation={Gtk.Orientation.HORIZONTAL}>
				<label label={time} />
				<box hexpand={true}/>
				<label label={AstalBattery.get_default().charging.toString()} />
			</box>
		</window>
	);
}
