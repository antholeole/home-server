import { Chart } from "cdk8s";
import type { Construct } from "constructs";
import { Namespace } from "cdk8s-plus-32";
import type { CnpgCluster } from "./cnpg";
import { DefaultTunnelBinding, redis, ssot } from "../lib";
import type { ClusterTunnel } from "../../imports/networking.cfargotunnel.com";
import { Authentik as AuthentikChart } from "../../imports/authentik";

const namespace = "authentik";
export class Authentik extends Chart {
	private static readonly ns = "authentik";
	private static readonly pgVolumeName = "postgres-creds";
	private static readonly secretKeyVolumeName = "secret-key-volume";

	constructor(
		scope: Construct,
		cnpgCluster: CnpgCluster,
		tunnel: ClusterTunnel,
	) {
		super(scope, "authentik", {
			// required for secret.
			disableResourceNameHashes: true,
			namespace: Authentik.ns,
		});

		new Namespace(this, namespace, {
			metadata: {
				name: namespace,
			},
		});

		const volumesConfig = {
			volumeMounts: [
				{
					name: Authentik.pgVolumeName,
					mountPath: `/${Authentik.pgVolumeName}`,
					readOnly: true,
				},
				{
					name: Authentik.secretKeyVolumeName,
					mountPath: `/${Authentik.secretKeyVolumeName}`,
					readOnly: true,
				},
			],
			volumes: [
				{
					name: Authentik.pgVolumeName,
					secret: {
						secretName: "pg-pass",
					},
				},
				{
					name: Authentik.secretKeyVolumeName,
					secret: {
						secretName: "authentik-secret-key",
					},
				},
			],
		};

		const helmValues = {
			server: volumesConfig,
			worker: volumesConfig,

			authentik: {
				secret_key: `file:///${Authentik.secretKeyVolumeName}/SECRET`,
				postgresql: {
					host: "cnpg-cluster-primary-rw.cnpgdb",
					user: `file:///${Authentik.pgVolumeName}/username`,
					password: `file:///${Authentik.pgVolumeName}/password`,
				},
			},
		};

		new AuthentikChart(this, "authentik-release", {
			namespace: Authentik.ns,
			releaseName: "authentik",
			values: helmValues,
		});

		redis(this, {
			name: namespace,
			namespace,
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
		Authentik.endpointUrl(slug, "end-session/");
}
