import { Chart } from "cdk8s";
import type { Construct } from "constructs";
import {
	Traefik as TraefikChart,
	TraefikLogsGeneralLevel,
} from "../../imports/traefik";
import { Namespace } from "cdk8s-plus-32";
import { Certificate } from "../../imports/cert-manager.io";
import type { CertManager } from "./cert-manager";
import { ssot } from "../lib";
import { Traefikcrds } from "../../imports/traefik-crds";
import {
	Gateway,
	GatewaySpecListenersAllowedRoutesNamespacesFrom,
	GatewaySpecListenersTlsMode,
	HttpRoute,
	HttpRouteSpecRulesMatchesPathType,
} from "../../imports/gateway.networking.k8s.io";
import type { Service } from "cdk8s-plus-32/lib/service";

export class Traefik extends Chart {
	private static readonly ns = "traefik";
	readonly publicGateway: Gateway;

	constructor(scope: Construct, certManager: CertManager) {
		super(scope, "traefik", {
			disableResourceNameHashes: true,
			namespace: Traefik.ns,
		});

		new Namespace(this, "traefik-ns", {
			metadata: {
				name: Traefik.ns,
			},
		});

		const tlsSecretName = "traefik-tls-cert";
		new Certificate(this, "traefik-tls-cert", {
			spec: {
				issuerRef: {
					name: certManager.clusterIssuer.name,
					kind: certManager.clusterIssuer.kind,
					group: "cert-manager.io",
				},
				secretName: tlsSecretName,
				commonName: `*.${ssot.cloudflare.domain}`,
				dnsNames: [`*.${ssot.cloudflare.domain}`],
			},
		});

		new Traefikcrds(this, "traefik-crds", {
			namespace: Traefik.ns,
		});

		new TraefikChart(this, "traefik", {
			namespace: Traefik.ns,
			values: {
				nodeSelector: {
					type: "vps",
				},
				tolerations: [
					{
						key: "type",
						operator: "Equal",
						value: "vps",
						effect: "NoSchedule",
					},
				],
				service: {
					type: "NodePort",
					spec: {
						externalTrafficPolicy: "Local",
					},
				},
				// TODO: https://doc.traefik.io/traefik/setup/kubernetes/
				ports: {
					web: {
						port: 80,
						nodePort: ssot.ports.webPort,
					},
					websecure: {
						port: 443,
						nodePort: ssot.ports.webSecurePort,
						proxyProtocol: {
							trustedIPs: [
								"127.0.0.1",
								// traefik will trust proxy protol from all traffic on the CNI
								// interfaces.
								"10.0.0.0/8",
							],
						},
					},
				},
				api: {
					dashboard: true,
					insecure: true, // only on localhost anyway
				},
				ingressRoute: {
					dashboard: {
						enabled: true,
						matchRule: "PathPrefix(`/dashboard`) || PathPrefix(`/api`)",
						entryPoints: ["web"],
					},
				},
				ingressClass: {
					enabled: true,

					// don't let local only things accidnetally expose themselves
					isDefaultClass: false,
				},
				providers: {
					kubernetesGateway: { enabled: true },
					kubernetesIngress: { enabled: true },
					kubernetesCrd: {
						enabled: true,
						allowCrossNamespace: false,
						allowEmptyServices: true,
					},
				},
				gateway: {
					enabled: true,
					listeners: {
						web: {
							port: 80,
							protocol: "HTTP",
							namespacePolicy: {
								from: "All",
							},
						},
						additionalValues: {
							websecure: {
								port: 443,
								protocol: "HTTPS",
								namespacePolicy: {
									from: "All",
								},
								mode: "Terminate",
								certificateRefs: [
									{
										kind: "Secret",
										name: tlsSecretName,
										group: "",
									},
								],
							},
						},
					},
				},
				// TODO remove me
				logs: {
					general: {
						level: TraefikLogsGeneralLevel.DEBUG,
					},
				},
			},
		});

		this.publicGateway = new Gateway(this, "main-gateway", {
			spec: {
				gatewayClassName: "traefik",
				listeners: [
					{
						name: "https",
						protocol: "HTTPS",
						port: 443,
						tls: {
							mode: GatewaySpecListenersTlsMode.TERMINATE,
							certificateRefs: [
								{
									name: tlsSecretName,
									kind: "Secret",
								},
							],
						},
						allowedRoutes: {
							namespaces: {
								from: GatewaySpecListenersAllowedRoutesNamespacesFrom.ALL,
							},
						},
					},
				],
			},
		});
	}

	public createRoute(
		scope: Construct,
		subdomain: string,
		service: Service,
	): HttpRoute {
		const name = `${subdomain}-route`;

		if (service.ports.length !== 1) {
			throw new Error("createRoute only setup for services with single port")
		}

		return new HttpRoute(scope, name, {
			metadata: {
				name: name,
				namespace: service.metadata.namespace,
			},
			spec: {
				parentRefs: [
					{
						name: this.publicGateway.name,
						namespace: this.namespace,
					},
				],
				hostnames: [`${subdomain}.${ssot.cloudflare.domain}`],
				rules: [
					{
						matches: [
							{
								path: {
									type: HttpRouteSpecRulesMatchesPathType.PATH_PREFIX,
									value: "/",
								},
							},
						],
						backendRefs: [
							{
								name: service.name,
								port: service.port,
							},
						],
					},
				],
			},
		});
	}
}
