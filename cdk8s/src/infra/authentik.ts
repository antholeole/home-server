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
	private readonly pgVolumeName = "postgres-creds";
	private readonly secretKeyVolumeName = "secret-key-volume";

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
					name: this.pgVolumeName,
					mountPath: `/${this.pgVolumeName}`,
					readOnly: true,
				},
				{
					name: this.secretKeyVolumeName,
					mountPath: `/${this.secretKeyVolumeName}`,
					readOnly: true,
				},
			],
			volumes: [
				{
					name: this.pgVolumeName,
					secret: {
						secretName: "pg-pass",
					},
				},
				{
					name: this.secretKeyVolumeName,
					secret: {
						secretName: "authentik-secret-key",
					},
				},
			],
		};

		// Define Ingress configuration
		const domain = `authentik.${ssot.cloudflare.domain}`;
		const ingressConfig = {
			ingress: {
				https: false, // TLS is handled by the Ingress/Cert-Manager
				enabled: true,
				ingressClassName: "nginx",
				annotations: {
					"nginx.ingress.kubernetes.io/ssl-redirect": "true",
					"cert-manager.io/cluster-issuer": "cert-manager-cloudflare-issuer",
				},
				hosts: [domain],
				tls: [
					{
						hosts: [domain],
						secretName: "authentik-tls-secret",
					},
				],
			},
		};

		const helmValues = {
			server: { ...volumesConfig, ...ingressConfig },
			worker: volumesConfig,

			authentik: {
				secret_key: `file:///${this.secretKeyVolumeName}/SECRET`,
				postgresql: {
					host: "cnpg-cluster-primary-rw.cnpgdb",
					user: `file:///${this.pgVolumeName}/username`,
					password: `file:///${this.pgVolumeName}/password`,
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
			serviceName: "authentik-authentik-redis-master",
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
						name: "authentik-authentik-server",
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
