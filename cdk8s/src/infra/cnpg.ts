import { Chart } from "cdk8s";
import {
	Cluster,
	ClusterSpecBackupBarmanObjectStoreDataCompression,
	ScheduledBackup,
	ScheduledBackupSpecBackupOwnerReference,
} from "../../imports/postgresql.cnpg.io";
import type { Construct } from "constructs";
import { Namespace } from "cdk8s-plus-32";
import { StrictLocalStorageClass } from "./longhorn";
import { ssot } from "../lib";

const namespace = "cnpgdb";

export class CnpgCluster extends Chart {
	constructor(scope: Construct) {
		super(scope, "cnpg-cluster");

		new Namespace(this, namespace, {
			metadata: {
				name: namespace,
			},
		});

		const cnpgR2Secret = "cloudnative-pg-s3-credentials";
		const cluster = new Cluster(this, "primary", {
			metadata: {
				namespace,
			},
			spec: {
				instances: 1,
				bootstrap: {
					initdb: {
						database: "app",
						owner: "acHTM95cRQqF0kV0", // must match secret
						secret: {
							name: "app-secret",
						},
					},
				},
				// we shan't have used barman and instead used volume snapshots - alas
				backup: {
					retentionPolicy: "7d", // idk 7 days is good enough. prevents catastrophic failure
					barmanObjectStore: {
						data: {
							compression:
								ClusterSpecBackupBarmanObjectStoreDataCompression.GZIP,
							jobs: 2,
						},
						endpointUrl: `https://${ssot.cloudflare.accountId}.r2.cloudflarestorage.com`,
						destinationPath: `s3://${ssot.cloudflare.bucket}`,
						s3Credentials: {
							accessKeyId: {
								name: cnpgR2Secret,
								key: "AWS_ACCESS_KEY_ID",
							},
							secretAccessKey: {
								name: cnpgR2Secret,
								key: "AWS_SECRET_ACCESS_KEY",
							},
						},
					},
				},
				affinity: {
					nodeAffinity: {
						requiredDuringSchedulingIgnoredDuringExecution: {
							nodeSelectorTerms: [
								{
									matchExpressions: [
										{
											key: "type",
											operator: "In",
											values: ["nas"],
										},
									],
								},
							],
						},
					},
				},
				storage: {
					storageClass: StrictLocalStorageClass.className,
					size: "2Gi", // resizeable, this is just start
				},
			},
		});

		new ScheduledBackup(this, "nightly", {
			metadata: {
				name: "nightly-backup",
				namespace,
			},
			spec: {
				schedule: "0 0 0 * * *",
				backupOwnerReference: ScheduledBackupSpecBackupOwnerReference.CLUSTER,
				cluster: {
					name: cluster.name,
				},
			},
		});
	}
}
