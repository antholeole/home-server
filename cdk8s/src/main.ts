import { App } from "cdk8s";
import { Authentik } from "./infra/authentik";
import { CertManager } from "./infra/cert-manager";
import { CloudflareOperatorChart } from "./infra/cloudflare-operator";
import { CnpgCluster } from "./infra/cnpg";
import { Longhorn } from "./infra/longhorn";
import { Reflector } from "./infra/reflector";
import { SealedSecrets } from "./infra/sealed-secrets";
import { Traefik } from "./infra/traefik";
import { CDKKustomize } from "./lib";
import { SealedSecrets as Secrets } from "./sealed";
import { Homebox } from "./services/homebox";
import { Mealie } from "./services/mealie";
import { PaperlessNgx } from "./services/paperless-ngx";
import { TldrawDeployment } from "./services/tldraw";

// override the synth function to also generate a kustomization.
const app = new App({
	outputFileExtension: ".yaml",
});

// infra
const cfOperator = new CloudflareOperatorChart(app);
const certManager = new CertManager(app);
new Longhorn(app);
new SealedSecrets(app);
const cnpgCluster = new CnpgCluster(app);
new Authentik(app, cnpgCluster, cfOperator.tunnelRef);
new Reflector(app);
const traefik = new Traefik(app, certManager);

new Secrets(app);

// services
new TldrawDeployment(app, traefik);
new Mealie(app, cnpgCluster, cfOperator.tunnelRef);
new PaperlessNgx(app, cnpgCluster, cfOperator.tunnelRef);
new Homebox(app, cnpgCluster, cfOperator.tunnelRef);

// write a kustomize for every manifest. must be last.
new CDKKustomize(app);

app.synth();
