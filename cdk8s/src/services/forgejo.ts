import { Chart } from "cdk8s";
import type { Construct } from "constructs";
import type { CnpgCluster } from "../infra/cnpg";
import type { ClusterTunnel } from "../../imports/networking.cfargotunnel.com";
import { Namespace } from "cdk8s-plus-32";
import { CloudReplicatedStorageClass } from "../infra/longhorn";
import { DefaultTunnelBinding } from "../lib";
import { Forgejo as ForgejoChart } from "../../imports/forgejo";

export class Forgejo extends Chart {
	static namespace = "forgejo";

	constructor(
		scope: Construct,
		cnpgCluster: CnpgCluster,
		tunnel: ClusterTunnel,
	) {
		super(scope, Forgejo.namespace, {
			disableResourceNameHashes: true,
			namespace: Forgejo.namespace,
		});

		new Namespace(this, Forgejo.namespace, {
			metadata: {
				name: Forgejo.namespace,
			},
		});

		const secret = cnpgCluster.buildAuthSecret(this, Forgejo.namespace);
		cnpgCluster.buildDb(this, Forgejo.namespace);

		new ForgejoChart(this, "chart", {
			namespace: Forgejo.namespace,
			values: {
				persistence: {
					enabled: true,
					storageClass: CloudReplicatedStorageClass.className,
					size: "5Gi",
				},
				service: {
					http: {
						port: 3000,
					},
				},
				extraEnvs: [
					{
						name: "FORGEJO__DATABASE__DB_TYPE",
						value: "postgres",
					},
					{
						name: "FORGEJO__DATABASE__HOST",
						value: cnpgCluster.host,
					},
					{
						name: "FORGEJO__DATABASE__NAME",
						value: Forgejo.namespace,
					},
					{
						name: "FORGEJO__DATABASE__USER",
						valueFrom: {
							secretKeyRef: {
								name: secret.name,
								key: "username",
							},
						},
					},
					{
						name: "FORGEJO__DATABASE__PASSWD",
						valueFrom: {
							secretKeyRef: {
								name: secret.name,
								key: "password",
							},
						},
					},
					{
						name: "FORGEJO__DATABASE__SSL_MODE",
						value: "disable",
					},
				],
				gitea: {
					admin: {
						username: "" // no admin
					},
					oauth: [{
						name: 'Authentik',
						existingSecret: 'forgejo-secret'
					}]
				}
			},
		});

		new DefaultTunnelBinding(
			this,
			"cluster-tunnel",
			[
				{
					subdomain: Forgejo.namespace,
					service: {
						name: "forgejo-http",
					},
				},
			],
			tunnel,
		);
	}
}
