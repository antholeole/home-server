import { EnvValue, Namespace, Protocol } from "cdk8s-plus-32";
import type { Construct } from "constructs";

import { DefaultChart, DefaultDeployment, DefaultTunnelBinding } from "../lib";
import type { ClusterTunnel } from "../../imports/networking.cfargotunnel.com";

export class TldrawDeployment extends DefaultChart {
	constructor(scope: Construct, tunnel: ClusterTunnel, port = 3000) {
		super(scope, "tldraw", {
			namespace: "tldraw",
		});

		new Namespace(this, "tldraw");

		const backendDeployment = new DefaultDeployment(this, "backend", {
			containers: [
				{
					image: "tldraw/backend",
					ports: [{ number: port }],
					envVariables: {
						PORT: EnvValue.fromValue(port.toString()),
						HOSTNAME: EnvValue.fromValue("0.0.0.0"),
					},
				},
			],
		});

		const backendService = backendDeployment.exposeViaService({
			ports: [
				{
					port: 80,
					targetPort: port,
					protocol: Protocol.TCP,
				},
			],
		});

		const frontendDeployment = new DefaultDeployment(this, "frontend", {
			containers: [{ image: "tldraw/frontend", ports: [{ number: port }] }],
		});

		const frontendService = frontendDeployment.exposeViaService({
			ports: [
				{
					port: 80,
					targetPort: port,
					protocol: Protocol.TCP,
				},
			],
		});

		
		new DefaultTunnelBinding(this, "cluster-tunnel", [
			{
				subdomain: "draw",
				service: frontendService,
			},
			{
				subdomain: "draw-api",
				service: backendService,
			},
		], tunnel);
	}
}
