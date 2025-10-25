import type { Construct } from "constructs";
import { Chart } from "cdk8s";
import { ClusterIssuer } from "../../imports/cert-manager.io";
import { Namespace } from "cdk8s-plus-32";
import { Certmanager } from "../../imports/cert-manager";

export class CertManager extends Chart {
	readonly clusterIssuer: ClusterIssuer;
	private static readonly ns = "cert-manager";

	constructor(scope: Construct) {
		super(scope, "cert-manager", {
			namespace: CertManager.ns,
			disableResourceNameHashes: true,
		});

		new Namespace(this, "cert-manager-ns", {
			metadata: {
				name: CertManager.ns,
			},
		});

		new Certmanager(this, "cert-manager", {
			namespace: CertManager.ns,
			releaseName: "cert-manager",
			values: {
				crds: {
					enabled: true,
				},
			},
		});

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
										key: "api-secret",
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
