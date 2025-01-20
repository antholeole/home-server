import { TldrawFrontend } from "./tldraw/tldraw";
import { useAsync } from 'react-use';


import {setupLogging} from './lib/logging';
import { tristate } from "./lib/tristate";

function App() {
  const loadState = useAsync(
    () => setupLogging()
  , [])


  return (
    <main className="container">
      {tristate(
        loadState,
        {
          loading: () => <p>loading!</p>,
          value: () => <TldrawFrontend />,
          error: (e) => <p>{e.toString()}</p>,
        })}
    </main>
  );
}

export default App;
