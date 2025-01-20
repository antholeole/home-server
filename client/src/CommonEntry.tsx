import { MantineProvider } from "@mantine/core";
import { useAsync } from "react-use";
import { setupLogging } from "./lib/logging";
import { tristate } from "./lib/tristate";
import React from "react";
import ReactDOM from "react-dom/client";

import "@mantine/core/styles.css";
import { theme } from "./lib/theme";

const CommonEntry: React.FC<React.PropsWithChildren> = ({ children }) => {
	const loadState = useAsync(() => setupLogging(), []);

	return (
		<main className="container">
			<MantineProvider theme={theme}>
				{tristate(loadState, {
					loading: () => <p>loading at the top level...</p>,
					value: () => <>{children}</>,
					error: (e) => <p>inital load failed: {e.toString()}</p>,
				})}
			</MantineProvider>
		</main>
	);
}


export const init = (Element: React.FC<unknown>) => ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
	<React.StrictMode>
		<CommonEntry>
			<Element />
		</CommonEntry>
	</React.StrictMode>,
);
