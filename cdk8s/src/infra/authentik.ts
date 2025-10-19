import { Chart } from "cdk8s";
import type { Construct } from "constructs";
import { Namespace } from "cdk8s-plus-32";
import type { CnpgCluster } from "./cnpg";
import { DefaultTunnelBinding, redis, ssot } from "../lib";
import type { ClusterTunnel } from "../../imports/networking.cfargotunnel.com";

const namespace = "authentik";
export class Authentik extends Chart {
	constructor(
		scope: Construct,
		cnpgCluster: CnpgCluster,
		tunnel: ClusterTunnel,
	) {
		super(scope, "authentik", {
			// required for secret.
			disableResourceNameHashes: true,
			namespace: "authentik",
		});

		new Namespace(this, namespace, {
			metadata: {
				name: namespace,
			},
		});

		redis(this, {
			name: namespace,
			namespace,
			// defualt redis name authentik looks for.			
			serviceName: "authentik-redis-master",
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

	private static endpointUrl = (slug: string, path: string) =>
		// has to be a public URL, since the browser speaks to it - no cluster networking
		`https://authentik.${ssot.cloudflare.domain}/application/o/${slug}/${path}`;

	static configurationUrl = (slug: string) =>
		Authentik.endpointUrl(slug, ".well-known/openid-configuration");
	static logoutUrl = (slug: string) =>
		Authentik.endpointUrl(slug, "end-session");
}
