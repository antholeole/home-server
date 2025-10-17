import { App } from "cdk8s";
import { CDKKustomize } from "./lib";
import { CloudflareOperatorChart } from "./services/cloudflare-operator";

import { TldrawDeployment } from "./services/tldraw";
import { SealedSecrets } from "./sealed";
import { CertManager } from "./infra/cert-manager";
import { Longhorn } from "./infra/longhorn";
import { CnpgCluster } from "./infra/cnpg";
import { Authentik } from "./infra/authentik";

// override the synth function to also generate a kustomization.
const app = new App({
	outputFileExtension: ".yaml"
});

// infra
const cfOperator = new CloudflareOperatorChart(app);
const certManager = new CertManager(app);
new Longhorn(app,certManager.clusterIssuer);

// services
new TldrawDeployment(app, cfOperator.tunnelRef);
new SealedSecrets(app);
const cnpgCluster = new CnpgCluster(app);
new Authentik(app, cnpgCluster);

// write a kustomize for every manifest. must be last.
new CDKKustomize(app);



app.synth();
