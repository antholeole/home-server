import { Chart } from "cdk8s";
import type { Construct } from "constructs";
import { Deployment, Namespace } from "cdk8s-plus-32";
import type { CnpgCluster } from "./cnpg";

const namespace = "authentik";
export class Authentik extends Chart {
	constructor(scope: Construct, cnpgCluster: CnpgCluster) {
		super(scope, "authentik", {
			// required for secret.
			disableResourceNameHashes: true,
		});

		new Namespace(this, namespace, {
			metadata: {
				name: namespace,
			},
		});

		const redisDeployment = new Deployment(this, "authentik-redis", {
			replicas: 1,
			metadata: {
				namespace,
			},
			securityContext: {
				ensureNonRoot: false,
			},
			containers: [
				{
					name: "redis",
					image: "redis:latest",
					securityContext: {
						ensureNonRoot: false,
					},
					ports: [
						{
							number: 6379,
						},
					],
				},
			],
		});

		redisDeployment.exposeViaService({
			// this is the default name that the authenik chart looks for.
			name: "authentik-redis-master",
		});

		cnpgCluster.buildAuthSecret(this, namespace);
		cnpgCluster.buildDb(this, "authentik");
	}
}
