import { Chart } from "cdk8s";
import { Kustomize } from "cdk8s-kustomize";
import type { Construct } from "constructs";
import { cloudflareOperator } from "../../kustomize/external-kustomize.json";
import { ClusterTunnelV1Alpha2 } from "../../imports/networking.cfargotunnel.com";

export const tunnelRef = {
	name: "k3s-cluster-tunnel",
	kind: "ClusterTunnel",
};

export class CloudflareOperatorChart extends Chart {
	public readonly tunnelRef: ClusterTunnelV1Alpha2;

	constructor(scope: Construct) {
		super(scope, "cloudflare-operator");

		new Kustomize(this, "cloudflare-operator-install", {
			url: cloudflareOperator,
		});

		this.tunnelRef = new ClusterTunnelV1Alpha2(this, tunnelRef.name, {
			spec: {
				newTunnel: {
					name: "home-server-tunnel",
				},
				cloudflare: {
					email: "antholeinik@gmail.com",
					domain: "oleina.xyz",
					accountId: "e0d74c227439ece29e62209d109ae43e",
					secret: "cloudflare-tunnel-secrets",
				},
			},
		});
	}
}
