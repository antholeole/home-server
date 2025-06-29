import { App } from "cdk8s";
import * as fs from "node:fs";
import { CloudflareOperatorChart } from "./services/cloudflare-operator";

import { TldrawDeployment } from "./services/tldraw";

// override the synth function to also generate a kustomization.
class KustomizeApp extends App {
	synth() {
		super.synth();

		const allYamls = fs.readdirSync(app.outdir);
		// put a kustomize file in there so we can update the image tags.
		fs.writeFileSync(
			`${app.outdir}/kustomization.yaml`,
			`
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
${allYamls
	.filter((v) => v !== "kustomization.yaml")
	.map((v) => `- ${v}`)
	.join("\n")}
`,
		);
	}
}

const app = new KustomizeApp();

// infra
new CloudflareOperatorChart(app);

// services
new TldrawDeployment(app);

app.synth();
