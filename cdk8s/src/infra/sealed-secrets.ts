import { Chart } from "cdk8s";
import type { Construct } from "constructs";
import { Namespace } from "cdk8s-plus-32";
import { Sealedsecrets } from "../../imports/sealed-secrets";

export class SealedSecrets extends Chart {
	private static readonly ns = "sealed-secrets";
	constructor(scope: Construct) {
		super(scope, "sealed-secrets", {
			disableResourceNameHashes: true,
			namespace: SealedSecrets.ns,
		});

		new Namespace(this, "sealed-secrets-namespace", {
			metadata: {
				name: SealedSecrets.ns,
			},
		});

		new Sealedsecrets(this, "sealed-secrets-chart", {
			releaseName: "sealed-secrets",
			namespace: SealedSecrets.ns,
		});
	}
}
