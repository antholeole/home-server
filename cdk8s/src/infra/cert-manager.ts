import type { Construct } from "constructs";
import { Chart } from "cdk8s";
import { ClusterIssuer } from "../../imports/cert-manager.io";

export class CertManager extends Chart {
	readonly clusterIssuer: ClusterIssuer
	
	constructor(scope: Construct) {
		super(scope, "cert-manager");

		this.clusterIssuer = new ClusterIssuer(this, "cloudflare-issuer", {
			spec: {
				acme: {
					server: "https://acme-v02.api.letsencrypt.org/directory",
					privateKeySecretRef: {
						name: "cluster-issuer-account-key",
					},
					solvers: [
						{
							dns01: {
								cloudflare: {
									apiTokenSecretRef: {
										name: "cloudflare-api-token-secret",
										key: "api-token",
									},
								},
							},
						},
					],
				},
			},
		});
	}
}
