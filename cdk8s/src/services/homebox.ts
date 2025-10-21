import { Chart, Size } from "cdk8s";
import type { Construct } from "constructs";
import type { CnpgCluster } from "../infra/cnpg";
import type { ClusterTunnel } from "../../imports/networking.cfargotunnel.com";
import {
	Deployment,
	EnvValue,
	Namespace,
	PersistentVolumeAccessMode,
	PersistentVolumeClaim,
	Volume,
} from "cdk8s-plus-32";
import { CloudReplicatedStorageClass } from "../infra/longhorn";
import { DefaultTunnelBinding } from "../lib";

export class Homebox extends Chart {
	static namespace = "homebox";

	constructor(
		scope: Construct,
		cnpgCluster: CnpgCluster,
		tunnel: ClusterTunnel,
	) {
		super(scope, Homebox.namespace, {
			disableResourceNameHashes: true,
			namespace: Homebox.namespace,
		});

		new Namespace(this, Homebox.namespace, {
			metadata: {
				name: Homebox.namespace,
			},
		});

		const secret = cnpgCluster.buildAuthSecret(this, Homebox.namespace);
		cnpgCluster.buildDb(this, Homebox.namespace);

		const pvcPath = "/data";
		const pvc = new PersistentVolumeClaim(this, "homebox-pvc", {
			metadata: {
				namespace: Homebox.namespace,
				name: "homebox-pvc",
			},
			storageClassName: CloudReplicatedStorageClass.className,
			accessModes: [PersistentVolumeAccessMode.READ_WRITE_ONCE],
			storage: Size.gibibytes(2),
		});

		const webPort = 7745;
		const homeboxDeployment = new Deployment(this, "deployment", {
			replicas: 1,
			metadata: {
				namespace: Homebox.namespace,
			},
			containers: [
				{
					name: "homebox",
					image: "ghcr.io/sysadminsmedia/homebox:0.21",
					securityContext: {
						ensureNonRoot: false,
					},
					ports: [
						{
							number: webPort,
						},
					],
					envVariables: {
						//general
						HBOX_WEB_PORT: EnvValue.fromValue(webPort.toString()),
						HBOX_OPTIONS_ALLOW_REGISTRATION: EnvValue.fromValue("false"),
						HBOX_STORAGE_CONN_STRING: EnvValue.fromValue(`${pvcPath}/conn`),

						// postgres
						HBOX_DATABASE_DRIVER: EnvValue.fromValue("postgres"),
						HBOX_DATABASE_SSL_MODE: EnvValue.fromValue("disable"),
						HBOX_DATABASE_HOST: EnvValue.fromValue(cnpgCluster.host),
						HBOX_DATABASE_PORT: EnvValue.fromValue("5432"),
						HBOX_DATABASE_USERNAME: secret.envValue("username"),
						HBOX_DATABASE_PASSWORD: secret.envValue("password"),
						HBOX_DATABASE_DATABASE: EnvValue.fromValue(Homebox.namespace),
					},
					volumeMounts: [
						{
							volume: Volume.fromPersistentVolumeClaim(
								this,
								"homebox-volume",
								pvc,
							),
							path: pvcPath,
						},
					],
				},
			],
		});

		const service = homeboxDeployment.exposeViaService();
		new DefaultTunnelBinding(
			this,
			"cluster-tunnel",
			[
				{
					subdomain: Homebox.namespace,
					service,
				},
			],
			tunnel,
		);
	}
}
