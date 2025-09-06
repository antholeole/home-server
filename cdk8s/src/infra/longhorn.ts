import { ApiObject, Chart } from "cdk8s";
import { KubeIngress } from "cdk8s-plus-32/lib/imports/k8s";
import { Construct } from "constructs";
import { ssot } from "../lib";


// TODO: actually cloud replicate :)
export class CloudReplicatedStorageClass extends Construct {
	static className = "standard-cloud-replicated";

	constructor(scope: Construct, id: string) {
		super(scope, id);

		new ApiObject(this, CloudReplicatedStorageClass.className, {
			kind: "StorageClass",
			apiVersion: "storage.k8s.io/v1",
			metadata: {
				name: CloudReplicatedStorageClass.className,
			},
			provisioner: "driver.longhorn.io",
			allowVolumeExpansion: true,
			parameters: {
				// single local, single remote.
				numberOfReplicas: "1",
				staleReplicaTimeout: "2880",
				fromBackup: "",
				fsType: "ext4",
			},
		});
	}
}


export class  Longhorn extends Chart {
  constructor(scope: Construct) {
    super(scope, "longhorn", {});

    new KubeIngress(this, 'longhorn-ingress', {
      metadata: {
        name: 'longhorn-ingress',
        namespace: 'longhorn-system',
        annotations: {
          'kubernetes.io/ingress.class': 'nginx',
        },
      },
      spec: {
        rules: [
          {
            host: `longhorn.${ssot.cloudflare.domain}`,
            http: {
              paths: [
                {
                  path: '/',
                  pathType: 'Prefix',
                  backend: {
                    service: {
                      name: 'longhorn-frontend',
                      port: {
                        number: 80, // Default Longhorn frontend port
                      },
                    },
                  },
                },
              ],
            },
          },
        ],
      },
    });
  }
}
