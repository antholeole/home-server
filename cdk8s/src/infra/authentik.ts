import { Chart } from "cdk8s";
import type { Construct } from "constructs";
import { Deployment, Namespace } from "cdk8s-plus-32";
import type { CnpgCluster } from "./cnpg";
import { DefaultTunnelBinding, ssot } from "../lib";
import type { ClusterTunnel } from "../../imports/networking.cfargotunnel.com";

const namespace = "authentik";
export class Authentik extends Chart {
	constructor(scope: Construct, cnpgCluster: CnpgCluster, tunnel: ClusterTunnel) {
		super(scope, "authentik", {
			// required for secret.
			disableResourceNameHashes: true,
			namespace: "authentik"
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

		new DefaultTunnelBinding(
			this,
			"cluster-tunnel",
			[
				{
					subdomain: "authentik",
					service: {
						name: "authentik-server",
					},
				},
			],
			tunnel,
		);
		
	}

	static configurationUrl(slug: string): string {
		// has to be a public URL, since the browser speaks to it - no cluster networking
		return `https://authentik.${ssot.cloudflare.domain}/application/o/${slug}/.well-known/openid-configuration`;
	}
}
