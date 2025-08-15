import { App } from "cdk8s";
import { CDKKustomize } from "./lib";
import { CloudflareOperatorChart } from "./services/cloudflare-operator";

import { TldrawDeployment } from "./services/tldraw";
import { SealedSecrets } from "./sealed";

// override the synth function to also generate a kustomization.
const app = new App({
	outputFileExtension: ".yaml"
});

// infra
new CloudflareOperatorChart(app);

// services
new TldrawDeployment(app);


new SealedSecrets(app);

// write a kustomize for every manifest. must be last.
new CDKKustomize(app);

app.synth();
