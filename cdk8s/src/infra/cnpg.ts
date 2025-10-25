import { Chart } from "cdk8s";
import {
	Cluster,
	Database,
	DatabaseSpecSchemasEnsure,
} from "../../imports/postgresql.cnpg.io";
import type { Construct } from "constructs";
import { Namespace, Secret } from "cdk8s-plus-32";
import { StrictLocalStorageClass } from "./longhorn";
import { Cloudnativepg } from "../../imports/cloudnative-pg";

export class CloudNativePg extends Chart {
	private static readonly ns = "cnpg-system";

	constructor(scope: Construct, id: string) {
		super(scope, id, {
			disableResourceNameHashes: true,
			namespace: CloudNativePg.ns,
		});

		new Namespace(this, "cnpg-namespace", {
			metadata: {
				name: CloudNativePg.ns,
			},
		});

		new Cloudnativepg(this, "cloudnative-pg", {
			releaseName: "cnpg",
			namespace: CloudNativePg.ns,
		});
	}
}

export class CnpgCluster extends Chart {
	private static namespace = "cnpgdb";
	private static cnpgDbUserSecret = "cnpdb-user"; // i typod whoops
	private static owner = "acHTM95cRQqF0kV0"; // must match secret

	private readonly cluster: Cluster;

	constructor(scope: Construct) {
		super(scope, "cnpg-cluster", {
			disableResourceNameHashes: true,
		});

		new Namespace(this, CnpgCluster.namespace, {
			metadata: {
				name: CnpgCluster.namespace,
			},
		});

		this.cluster = new Cluster(this, "primary", {
			metadata: {
				namespace: CnpgCluster.namespace,
			},
			spec: {
				instances: 1,
				bootstrap: {
					initdb: {
						database: "app",
						owner: CnpgCluster.owner,
						secret: {
							name: CnpgCluster.cnpgDbUserSecret,
						},
					},
				},
				// we shan't have used barman and instead used volume snapshots - alas
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
				// TODO: snapshot backups!!!!!!!!!
				walStorage: {
					storageClass: StrictLocalStorageClass.className,
					size: "2Gi",
				},
				storage: {
					storageClass: StrictLocalStorageClass.className,
					size: "2Gi", // resizeable, this is just start
				},
			},
		});
	}

	buildAuthSecret(scope: Chart, namespace: string): Secret {
		return new Secret(scope, "pg-pass", {
			metadata: {
				namespace,
				name: "pg-pass",
				annotations: {
					"reflector.v1.k8s.emberstack.com/reflects": `${CnpgCluster.namespace}/${CnpgCluster.cnpgDbUserSecret}`,
				},
			},
		});
	}

	buildDb(scope: Chart, name: string): Database {
		return new Database(scope, `${name}-db`, {
			metadata: {
				name: `${name}-db`,
				namespace: CnpgCluster.namespace, // same namespace
			},
			spec: {
				name: `${name}`,
				owner: CnpgCluster.owner,
				cluster: {
					name: this.cluster.name,
				},
				// TODO: figure out if we have to move this out of here or not.
				// workaround for this, https://github.com/goauthentik/authentik/issues/7481
				schemas: [
					{
						name: "public",
						owner: CnpgCluster.owner,
						ensure: DatabaseSpecSchemasEnsure.PRESENT,
					},
				],
			},
		});
	}

	get host(): string {
		return `${this.cluster.name}-rw.${CnpgCluster.namespace}`;
	}
}
