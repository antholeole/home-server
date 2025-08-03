import { exit } from "node:process";
import { $, minimist } from "zx";

const MAX_PRESS_MSEC = 2000;
const VALID_EVENTS = ["press", "release"] as const;
const PRESSFILE = "/tmp/notify-lock-pressed.txt";

const thisTime = new Date().getTime();

const screenOn = JSON.parse((await $`hyprctl monitors -j`).stdout)[0]
	.dpmsStatus;

const clearPressFile = async () => await $`echo "" > ${PRESSFILE}`;

const { event } = minimist(process.argv.slice(2)) as unknown as {
	event: (typeof VALID_EVENTS)[number];
};

if (!VALID_EVENTS.includes(event)) {
	console.error(
		`must have --event flag with one of the following: ${VALID_EVENTS.join(", ")}`,
	);
	exit(1);
}

// any action here should power the screen back on.
if (!screenOn) {
	console.log("screen is not on; turning it on.");
	await $`hyprctl dispatch dpms on`;
	await clearPressFile();
	exit(0);
}

// if we are a press.
if (event === "press") {
	// this may actually race. whoops. has not happened in practice but it absolutely can.
	console.log("screen on and press started.");
	await $`echo ${thisTime} >> ${PRESSFILE}`;
	exit(0);
}

// get the time of the press.
const pressTimeStr = (await $`tail -1 ${PRESSFILE}`).stdout;
const pressTime: number = Number.parseInt(pressTimeStr);
if (Number.isNaN(pressTime)) {
	console.log("long press after pressfile wiped, exiting.");
	exit(0);
}

const elapsedTime = thisTime - pressTime;
if (elapsedTime > MAX_PRESS_MSEC) {
	console.warn(
		`registered as hold since pressed for ${elapsedTime}; not proceeding`,
	);
} else {
	console.log("quick press detected. turning screen off.");
	await $`hyprctl dispatch dpms off`;
	await clearPressFile();
}
