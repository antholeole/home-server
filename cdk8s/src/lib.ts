import { Chart, type ChartProps } from "cdk8s";
import { Deployment, type Service, type DeploymentProps } from "cdk8s-plus-32";
import type { Construct } from "constructs";
import {
	type ClusterTunnel,
	TunnelBinding,
	type TunnelBindingTunnelRefKind,
	type TunnelBindingProps,
} from "../imports/networking.cfargotunnel.com";

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

			containers: props?.containers?.map((container) => ({
				...container,
				resources: container.resources === undefined ? {} : container.resources,

				// TODO: setting nonroot could be helpful, but would require changing
				// the images. Let containers run as root for now.
				securityContext: props?.securityContext ?? {
					ensureNonRoot: false,
				},
			})),
		};

		super(scope, id, newProps);
	}
}

export class DefaultTunnelBinding extends TunnelBinding {
	constructor(
		scope: Construct,
		id: string,
		props: {
			service: Service;
			subdomain: string;
		}[],
		tunnel: ClusterTunnel,
	) {
		const tunnelBindingProps: TunnelBindingProps = {
			tunnelRef: {
				kind: tunnel.kind as TunnelBindingTunnelRefKind,
				name: tunnel.name,
			},
			subjects: props.map((subject) => ({
				name: subject.service.name,
				spec: {
					fqdn: `${subject.subdomain}.${ssot.cloudflare.domain}`,
					protocol: "http",
				},
			})),
		};

		super(scope, id, tunnelBindingProps);
	}
}

export class CDKKustomize extends Chart {
	private files: string[];

	constructor(scope: Construct) {
		const allContructructs = scope.node.children;

		super(scope, "kustomization");
		this.files = allContructructs.map((c) => `${c.node.id}.yaml`);
	}

	toJson(): unknown[] {
		return [
			{
				apiVersion: "kustomize.config.k8s.io/v1beta1",
				kind: "Kustomization",
				resources: this.files,
			},
		];
	}
}

export const ssot = {
	cloudflare: {
		domain: "oleina.xyz",
	},
} as const;
