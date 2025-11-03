import { Chart, Size } from "cdk8s";
import type { Construct } from "constructs";
import {
	Deployment,
	EnvValue,
	Namespace,
	PersistentVolumeAccessMode,
	PersistentVolumeClaim,
	Secret,
	Volume,
} from "cdk8s-plus-32";
import type { CnpgCluster } from "../infra/cnpg";
import { CloudReplicatedStorageClass } from "../infra/longhorn";
import { DefaultTunnelBinding, redis, ssot } from "../lib";
import type { ClusterTunnel } from "../../imports/networking.cfargotunnel.com";
import { Authentik } from "../infra/authentik";

const namespace = "paperless";
export class PaperlessNgx extends Chart {
	constructor(
		scope: Construct,
		cnpgCluster: CnpgCluster,
		tunnel: ClusterTunnel,
	) {
		super(scope, "paperless", {
			disableResourceNameHashes: true,
			namespace: "paperless",
		});

		new Namespace(this, namespace, {
			metadata: {
				name: namespace,
			},
		});

		const pgDb = "paperless";
		const pgSecret = cnpgCluster.buildAuthSecret(this, namespace);
		cnpgCluster.buildDb(this, pgDb);

		const slug = namespace;
		const pvc = new PersistentVolumeClaim(this, "paperless-pvc", {
			metadata: {
				namespace,
				name: "paperless-pvc",
			},
			storageClassName: CloudReplicatedStorageClass.className,
			accessModes: [PersistentVolumeAccessMode.READ_WRITE_ONCE],
			storage: Size.gibibytes(2),
		});

		const paperlessSecrets = Secret.fromSecretName(
			this,
			"paperless-secrets",
			"paperless-secrets",
		);

		const paperlessDataPath = "/paperless";

		const redisService = redis(this, {
			namespace,
			name: namespace,
			serviceName: "paperless-redis",
		});

		const paperless = new Deployment(this, "paperless-deployment", {
			replicas: 1,
			metadata: {
				namespace,
			},
			containers: [
				{
					name: "paperless",
					image: "ghcr.io/paperless-ngx/paperless-ngx:2.18.3",
					securityContext: {
						ensureNonRoot: false,
						readOnlyRootFilesystem: false,
					},
					ports: [
						{
							number: 8000,
						},
					],
					envVariables: {
						// general
						PAPERLESS_TIME_ZONE: EnvValue.fromValue(ssot.tz),
						PAPERLESS_SECRET_KEY: paperlessSecrets.envValue("SECRET_KEY"),
						PAPERLESS_URL: EnvValue.fromValue(
							`https://paperless.${ssot.cloudflare.domain}`,
						),
						PAPERLESS_REDIS: EnvValue.fromValue(
							`redis://${redisService.name}:6379`,
						),

						// postgres
						PAPERLESS_DBENGINE: EnvValue.fromValue("postgres"),
						PAPERLESS_DBNAME: EnvValue.fromValue(pgDb),
						PAPERLESS_DBUSER: pgSecret.envValue("username"),
						PAPERLESS_DBPASS: pgSecret.envValue("password"),

						// paths
						PAPERLESS_CONSUMPTION_DIR: EnvValue.fromValue(
							`${paperlessDataPath}/consumption`,
						),
						PAPERLESS_DATA_DIR: EnvValue.fromValue(`${paperlessDataPath}/data`),
						PAPERLESS_MEDIA_ROOT: EnvValue.fromValue(
							`${paperlessDataPath}/data`,
						),

						// oidc
						PAPERLESS_DISABLE_REGULAR_LOGIN: EnvValue.fromValue("true"),
						PAPERLESS_REDIRECT_LOGIN_TO_SSO: EnvValue.fromValue("true"),
						PAPERLESS_ENABLE_ALLAUTH: EnvValue.fromValue("true"),
						PAPERLESS_APPS: EnvValue.fromValue(
							"allauth.socialaccount.providers.openid_connect",
						),
						PAPERLESS_AUTO_LOGIN: EnvValue.fromValue("true"),
						PAPERLESS_AUTO_CREATE: EnvValue.fromValue("true"),
						PAPERLESS_LOGOUT_REDIRECT_URL: EnvValue.fromValue(
							Authentik.logoutUrl(slug),
						),
						PAPERLESS_SOCIALACCOUNT_PROVIDERS: paperlessSecrets.envValue(
							"PAPERLESS_SOCIALACCOUNT_PROVIDERS",
						),
					},
					volumeMounts: [
						{
							volume: Volume.fromPersistentVolumeClaim(
								this,
								"paperless-volume",
								pvc,
							),
							path: paperlessDataPath,
						},
					],
				},
			],
		});

		const service = paperless.exposeViaService();
		new DefaultTunnelBinding(
			this,
			"cluster-tunnel",
			[
				{
					subdomain: "paperless",
					service,
				},
			],
			tunnel,
		);
	}
}
