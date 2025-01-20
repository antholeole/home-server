# Running a Specific Window

To run a specific window in tauri, use the following command: `npm run tauri dev -- -- -- --windows=tldraw`. The first block is for node, the second is for tauri, and the third is finally for our app.

If developing in the browser, use `npm run dev:web` and then navigate to `localhost:1420/windows/<window>.html`.