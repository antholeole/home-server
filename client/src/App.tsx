import { MantineProvider } from "@mantine/core";
import { TldrawFrontend } from "./tldraw/tldraw";
import { useAsync } from "react-use";
import { setupLogging } from "./lib/logging";
import { tristate } from "./lib/tristate";

import "@mantine/core/styles.css";
import { theme } from "./lib/theme";

function App() {
	const loadState = useAsync(() => setupLogging(), []);

	return (
		<main className="container">
			<MantineProvider theme={theme}>
				{tristate(loadState, {
					loading: () => <p>loading!</p>,
					value: () => <TldrawFrontend />,
					error: (e) => <p>{e.toString()}</p>,
				})}
			</MantineProvider>
		</main>
	);
}

export default App;
