import { ApiObject, Chart } from "cdk8s";
import { Construct } from "constructs";
import { ssot } from "../lib";
import { KubeStorageClass } from "../../imports/k8s";
import type { ClusterIssuer } from "../../imports/cert-manager.io";

// TODO: actually cloud replicate :)
export class CloudReplicatedStorageClass extends Construct {
	static className = "standard-cloud-replicated";

	constructor(scope: Construct) {
		super(scope, CloudReplicatedStorageClass.className);

		new KubeStorageClass(this, CloudReplicatedStorageClass.className, {
			metadata: {
				name: CloudReplicatedStorageClass.className,
			},
			provisioner: "driver.longhorn.io",
			allowVolumeExpansion: true,
			parameters: {
				// single local, single remote backup.
				numberOfReplicas: "1",
				staleReplicaTimeout: "2880",
				fsType: "ext4",
			},
		});
	}
}


// storage class used for charts with replication built in, e.g. cnpg.
export class StrictLocalStorageClass extends Construct {
	static className = "standard-strict-local";

	constructor(scope: Construct) {
		super(scope, "strict-local");

		new KubeStorageClass(this, StrictLocalStorageClass.className, {
			metadata: {
				name: StrictLocalStorageClass.className,
			},
			provisioner: "driver.longhorn.io",
			allowVolumeExpansion: true,
			parameters: {
				numberOfReplicas: "1",
				dataLocality: "strict-local",
				staleReplicaTimeout: "2880",
				fromBackup: "",
				fsType: "ext4",
			},
		});
	}
}

export class Longhorn extends Chart {
	constructor(scope: Construct, clusterIssuer: ClusterIssuer) {
		super(scope, "longhorn");

		new CloudReplicatedStorageClass(this);
		new StrictLocalStorageClass(this);

		const domain = `longhorn.${ssot.cloudflare.domain}`;
		new ApiObject(this, "longhorn-ingress", {
			kind: "Ingress",
			apiVersion: "networking.k8s.io/v1",
			metadata: {
				name: "longhorn-ingress",
				namespace: "longhorn-system",
				annotations: {
					"nginx.ingress.kubernetes.io/ssl-redirect": "true",
					"nginx.ingress.kubernetes.io/proxy-bod-size": "10000m",
					"cert-manager.io/cluster-issuer": clusterIssuer.name,
				},
			},
			spec: {
				ingressClassName: "nginx",
				tls: [
					{
						hosts: [domain],
						secretName: "longhorn-tls-secret",
					},
				],

				rules: [
					{
						host: domain,
						http: {
							paths: [
								{
									pathType: "Prefix",
									path: "/",
									backend: {
										service: {
											name: "longhorn-frontend",
											port: {
												number: 80,
											},
										},
									},
								},
							],
						},
					},
				],
			},
		});
	}
}
