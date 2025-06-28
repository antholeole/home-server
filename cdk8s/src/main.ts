import type { Construct } from "constructs";
import { App, Chart, type ChartProps } from "cdk8s";
import * as kplus from "cdk8s-plus-32";
import * as fs from "node:fs";

export class MyChart extends Chart {
	constructor(scope: Construct, id: string, props: ChartProps = {}) {
		super(scope, id, props);

		new kplus.Deployment(this, "FrontEnds", {
			containers: [
				{ image: "node" },
				{ image: "redis" },
			],
		});
	}
}
export class MyChart2 extends Chart {
	constructor(scope: Construct, id: string, props: ChartProps = {}) {
		super(scope, id, props);

		new kplus.Deployment(this, "FrontEnds2", {
			containers: [
				{ image: "node" },
				{ image: "redis" },
			],
		});
	}
}

// override the synth function to also generate a kustomization.
class KustomizeApp extends App {
	synth() {
		super.synth();

		const allYamls = fs.readdirSync(app.outdir);
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

// put a kustomize file in there so we can update the image tags.

new MyChart(app, "cdk8s");
new MyChart2(app, "cdk8s2");

app.synth();
