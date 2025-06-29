import { Chart } from "cdk8s";
import { Kustomize } from "cdk8s-kustomize";
import type { Construct } from "constructs";
import { cloudflareOperator } from "../../imports/external-kustomize.json"

export const tunnelRef = {
	name: "k3s-cluster-tunnel",
	kind: "ClusterTunnel",
};

export class CloudflareOperatorChart extends Chart {
	constructor(scope: Construct) {
		super(scope, "cloudflare-operator");

		new Kustomize(this, "cloudflare-operator-install", {
			url: cloudflareOperator
		});
	}
}
