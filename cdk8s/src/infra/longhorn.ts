import { ApiObject, Chart } from "cdk8s";
import { Construct } from "constructs";
import { ssot } from "../lib";
import { KubeStorageClass } from "../../imports/k8s";
import type { ClusterIssuer } from "../../imports/cert-manager.io";
import {
	RecurringJobV1Beta2,
	RecurringJobV1Beta2SpecTask,
} from "../../imports/longhorn.io";
import { ConfigMap, Namespace } from "cdk8s-plus-32";
import { Longhorn as LonghornChart } from "../../imports/longhorn";

const buildRecurringJobSelector = (recurringJob: RecurringJobV1Beta2) =>
	JSON.stringify([
		{
			name: recurringJob.name,
			isGroup: false,
		},
	]);

export class CloudReplicatedStorageClass extends Construct {
	static className = "standard-cloud-replicated";

	constructor(scope: Construct) {
		super(scope, CloudReplicatedStorageClass.className);

		const recurringJob = new RecurringJobV1Beta2(this, "job", {
			spec: {
				cron: "0 0 * * *",
				task: RecurringJobV1Beta2SpecTask.BACKUP, // snapshot then ship to cloud
				retain: 2,
				concurrency: 2,
			},
		});

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
				recurringJobSelector: buildRecurringJobSelector(recurringJob),
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
				fsType: "ext4",
			},
		});
	}
}

export class Longhorn extends Chart {
	private static readonly ns = "longhorn-system";

	constructor(scope: Construct, clusterIssuer: ClusterIssuer) {
		super(scope, "longhorn", {
			namespace: Longhorn.ns,
			disableResourceNameHashes: true,
		});

		new Namespace(this, "longhorn-systm", {
			metadata: {
				name: Longhorn.ns,
			},
		});

		new LonghornChart(this, "longhorn-chart", {
			namespace: Longhorn.ns
		});

		// https://github.com/longhorn/longhorn/issues/11421
		// longhorn supports many backup targets, but scheduled backup only
		// lets you use the default one so we have to name this default.
		new ConfigMap(this, "default", {
			metadata: {
				name: "longhorn-default-resource", // magic name
			},
			data: {
				"default-resource.yaml": `
"backup-target": "s3://${ssot.cloudflare.bucket}@auto/longhorn"
"backup-target-credential-secret": "s3-secret"
"backupstore-poll-interval": "180"
				`.trim(),
			},
		});

		new CloudReplicatedStorageClass(this);
		new StrictLocalStorageClass(this);

		const domain = `longhorn.${ssot.cloudflare.domain}`;
		new ApiObject(this, "longhorn-ingress", {
			kind: "Ingress",
			apiVersion: "networking.k8s.io/v1",
			metadata: {
				name: "longhorn-ingress",
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
