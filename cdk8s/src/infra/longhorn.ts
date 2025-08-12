import { ApiObject } from "cdk8s";
import { Construct } from "constructs";


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
