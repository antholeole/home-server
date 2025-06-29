import { Chart, type ChartProps } from "cdk8s";
import {
	Deployment,
	Service,
	type DeploymentProps,
} from "cdk8s-plus-32";
import type { Construct } from "constructs";
import { TunnelBinding, TunnelBindingProps } from "../imports/networking.cfargotunnel.com";

type WithRequired<T, K extends keyof T> = T & { [P in K]-?: T[P] };

export class DefaultChart extends Chart {
	constructor(
		scope: Construct,
		id: string,
		props: Omit<
			WithRequired<ChartProps, "namespace">,
			"disableResourceNameHashes"
		>,
	) {
		super(scope, id, { ...props, disableResourceNameHashes: true });
	}
}

export class DefaultDeployment extends Deployment {	
	constructor(scope: Construct, id: string, props?: DeploymentProps) {
		// set some sensible defaults.
		const newProps = {
			...props,
			replicas: props?.replicas ?? 1,
			containers: props?.containers?.map(
				(container) => ({
					...container,
					resources: container.resources === undefined ? {} : container.resources
				}),
			),
		};

		super(scope, id, newProps);
	}
}

export class DefaultTunnelBinding extends TunnelBinding {
	constructor(scope: Construct, id: string, props: {
		service: Service,
		subdomain: string
	}[]) {
		const tunnelBindingProps: TunnelBindingProps = {
			tunnelRef: {
    name = "k3s-cluster-tunnel";
    kind = "ClusterTunnel";
				
			}
			subjects: props.map(subject => ({
				name: subject.service.name,
				fqdn: `${subject.subdomain}.${ssot.cloudflare}`
			}))
		}

		super(scope, id, tunnelBindingProps);
	}
}


export const ssot = {
	cloudflare: {
    domain: "oleina.xyz"
	}
} as const;
