import { Chart } from "cdk8s";
import type { Construct } from "constructs";
import { Reflector as ReflectorChart } from "../../imports/reflector";
import { Namespace } from "cdk8s-plus-32";

export class Reflector extends Chart {
	constructor(scope: Construct) {
		super(scope, "reflector", {
			disableResourceNameHashes: true,
		});

		const ns = "kubernetes-reflector";
		new Namespace(this, ns, {
			metadata: {
				name: ns,
			},
		});

		new ReflectorChart(this, "reflector", {
			namespace: ns,
		});
	}
}
