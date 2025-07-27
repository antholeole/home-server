import app from "ags/gtk4/app";
import { Astal, Gtk, type Gdk } from "ags/gtk4";
import { createPoll } from "ags/time";
import AstalBattery from "gi://AstalBattery?version=0.1";
import { With } from "ags";

function Battery() {
	const unpackBattery = (battery: AstalBattery.Device) => {
		let icon = "󰂄";

		if (!battery.charging) {
			if (battery.percentage > 90) {
				icon = "󰁹";
			} else if (battery.percentage > 80) {
				icon = "󰂂";
			} else if (battery.percentage > 60) {
				icon = "󰁿";
			} else if (battery.percentage > 30) {
				icon = "󰁼";
			} else {
				icon = "󰁻";
			}
		}

		return {
			percentage: battery.percentage,
			icon,
		};
	};

	const battery = createPoll(
		unpackBattery(AstalBattery.get_default()),
		5000,
		() => unpackBattery(AstalBattery.get_default()),
	);

	return (
		<box>
			<With value={battery}>
				{(battery) => (
					<box>
						{battery.percentage <= 1.8 && (
							<label label={`${Math.round(battery.percentage * 100)}%`} />
						)}
						<label class="icon" label={battery.icon} />
					</box>
				)}
			</With>
		</box>
	);
}

export default function Bar(gdkmonitor: Gdk.Monitor) {
	const time = createPoll("", 60 * 1000, "date '+%I:%M %p'");
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
				<box hexpand={true} />
				<Battery />
			</box>
		</window>
	);
}
