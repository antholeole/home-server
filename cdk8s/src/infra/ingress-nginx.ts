import { Chart } from "cdk8s";
import type { Construct } from "constructs";
import { Ingressnginx } from "../../imports/ingress-nginx";
import { Namespace } from "cdk8s-plus-32";

export class IngressNginx extends Chart {
	private static readonly ns = "ingress-nginx";
	constructor(scope: Construct) {
		super(scope, "ingress-nginx", {
			disableResourceNameHashes: true,
			namespace: IngressNginx.ns,
		});

		new Namespace(this, "ingress-nginx-ns", {
			metadata: {
				name: IngressNginx.ns,
			},
		});

		new Ingressnginx(this, "ingress-nginx", {
			namespace: IngressNginx.ns,
			values: {
				releaseName: "ingress-nginx",
				// allow the ingress pods to read the cluster dns. this means that
				// we can use ingress nginx as a proxy between the world and the
				// internal services.
				controller: {
					dnsPolicy: "ClusterFirstWithHostNet",
					hostNetwork: true,
					kind: "DaemonSet",
				},
			},
		});
	}
}
