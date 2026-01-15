import { App } from "cdk8s";
import { CDKKustomize } from "./lib";

import { TldrawDeployment } from "./services/tldraw";
import { SealedSecrets as Secrets } from "./sealed";
import { CertManager } from "./infra/cert-manager";
import { Longhorn } from "./infra/longhorn";
import { CnpgCluster } from "./infra/cnpg";
import { Authentik } from "./infra/authentik";
import { Mealie } from "./services/mealie";
import { PaperlessNgx } from "./services/paperless-ngx";
import { Homebox } from "./services/homebox";
import { Forgejo } from "./services/forgejo";
import { Reflector } from "./infra/reflector";
import { CloudflareOperatorChart } from "./infra/cloudflare-operator";
import { IngressNginx } from "./infra/ingress-nginx";
import { SealedSecrets } from "./infra/sealed-secrets";

// override the synth function to also generate a kustomization.
const app = new App({
	outputFileExtension: ".yaml",
});

// infra
const cfOperator = new CloudflareOperatorChart(app);
const certManager = new CertManager(app);
new Longhorn(app, certManager.clusterIssuer);
new SealedSecrets(app);
const cnpgCluster = new CnpgCluster(app);
new Authentik(app, cnpgCluster, cfOperator.tunnelRef);
new Reflector(app);
new IngressNginx(app);

new Secrets(app);

// services
new TldrawDeployment(app, cfOperator.tunnelRef);
new Mealie(app, cnpgCluster, cfOperator.tunnelRef);
new PaperlessNgx(app, cnpgCluster, cfOperator.tunnelRef);
new Homebox(app, cnpgCluster, cfOperator.tunnelRef);
new Forgejo(app, cnpgCluster, cfOperator.tunnelRef);

// write a kustomize for every manifest. must be last.
new CDKKustomize(app);

app.synth();
