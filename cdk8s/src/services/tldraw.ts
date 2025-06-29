import { EnvValue, Protocol } from "cdk8s-plus-32";
import type { Construct } from "constructs";

import { DefaultChart, DefaultDeployment } from "../lib";

export class TldrawDeployment extends DefaultChart {
	constructor(scope: Construct, port = 3000) {
		super(scope, "tldraw", {
			namespace: "tldraw",
		});

		const backendDeployment = new DefaultDeployment(this, "tldraw-backend", {
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

		backendDeployment.exposeViaService({
			ports: [
				{
					port: 80,
					targetPort: port,
					protocol: Protocol.TCP,
				},
			],
		});

		const frontendDeployment = new DefaultDeployment(this, "tldraw-frontend", {
			containers: [{ image: "tldraw/frontend", ports: [{ number: port }] }],
		});

		frontendDeployment.exposeViaService({
			ports: [
				{
					port: 80,
					targetPort: port,
					protocol: Protocol.TCP,
				},
			],
		});
	}
}
