import { App } from "cdk8s";
import { CDKKustomize } from "./lib";
import { CloudflareOperatorChart } from "./services/cloudflare-operator";

import { TldrawDeployment } from "./services/tldraw";

// override the synth function to also generate a kustomization.
const app = new App({
	outputFileExtension: ".yaml"
});

// infra
new CloudflareOperatorChart(app);

// services
new TldrawDeployment(app);

// write a kustomize for every manifest.
new CDKKustomize(app);

app.synth();
