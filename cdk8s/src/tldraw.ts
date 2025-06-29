import { Protocol } from "cdk8s-plus-32";
import type { Construct } from "constructs";

import { DefaultChart, DefaultDeployment, DefaultTunnelBinding } from "./lib";

export class TldrawDeployment extends DefaultChart {
	constructor(scope: Construct, port = 3000) {
		super(scope, "tldraw", {
			namespace: "tldraw",
		});

		const backendDeployment = new DefaultDeployment(this, "backend", {
			containers: [{ image: "tldraw/backend" }],
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
			containers: [{ image: "tldraw/frontend" }],
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
		]);
	}
}
