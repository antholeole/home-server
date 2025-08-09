import { exit } from "node:process";
import { $, ProcessOutput } from "zx";
import fs from "node:fs";

const STATUS_FILE = "/tmp/screen-off-tracker.txt";

let isScreenOn: boolean;

try {
	console.log("starting...");
	const instances = await $`hyprctl instances -j`;
	const instancesJson = JSON.parse(instances.stdout);
	const hyprctlInstance = instancesJson[0].instance;

	const monitors = $({
		env: {
			HYPRLAND_INSTANCE_SIGNATURE: hyprctlInstance,
		},
	})`hyprctl monitors -j`;

	isScreenOn = monitors[0].dpmsStatus;
} catch (e) {
	if (e instanceof ProcessOutput) {
		console.error(e.stdall);
	} else {
		console.error(`error: ${JSON.stringify(e)}`);
	}

	exit(0);
}

console.log(`isScreenOn: ${isScreenOn}`);

let wasScreenOn = true;
if (fs.existsSync(STATUS_FILE)) {
	wasScreenOn = fs.readFileSync(STATUS_FILE, "utf-8") === "true";
}
console.log(`wasScreenOn: ${wasScreenOn}`);

if (!isScreenOn && !wasScreenOn) {
	console.log("Screen was already off. Hibernating.");
	await $`systemctl suspend`;
} else {
	// otherwise just write the status.
	const toWrite = isScreenOn.toString();
	fs.writeFileSync(STATUS_FILE,toWrite);
	console.log(`wrote ${toWrite} to ${STATUS_FILE}`);
}
