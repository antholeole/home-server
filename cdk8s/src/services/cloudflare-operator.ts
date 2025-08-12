import { Chart } from "cdk8s";
import { Kustomize } from "cdk8s-kustomize";
import type { Construct } from "constructs";
import { cloudflareOperator } from "../../kustomize/external-kustomize.json";
import { ClusterTunnel } from "../../imports/networking.cfargotunnel.com";

export const tunnelRef = {
	name: "k3s-cluster-tunnel",
	kind: "ClusterTunnel",
};

export class CloudflareOperatorChart extends Chart {
	public readonly tunnelRef: ClusterTunnel;

	constructor(scope: Construct) {
		super(scope, "cloudflare-operator");

		new Kustomize(this, "cloudflare-operator-install", {
			url: cloudflareOperator,
		});

		this.tunnelRef = new ClusterTunnel(this, tunnelRef.name, {
			spec: {
				newTunnel: {
					name: "home-server-tunnel",
				},
				cloudflare: {
					email: "",
					domain: "oleina.xyz",
					accountId: "e0d74c227439ece29e62209d109ae43e",
					secret: "cloudflare-tunnel-secrets",
				},
			},
		});
	}
}
