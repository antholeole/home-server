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
import { DefaultTunnelBinding, ssot } from "../lib";
import type { ClusterTunnel } from "../../imports/networking.cfargotunnel.com";
import { Authentik } from "../infra/authentik";

const namespace = "mealie";
export class Mealie extends Chart {
	constructor(
		scope: Construct,
		cnpgCluster: CnpgCluster,
		tunnel: ClusterTunnel,
	) {
		super(scope, "mealie", {
			// required for secret.
			disableResourceNameHashes: true,
			namespace: "mealie",
		});

		new Namespace(this, namespace, {
			metadata: {
				name: namespace,
			},
		});

		const pgDb = "mealie";
		const secret = cnpgCluster.buildAuthSecret(this, namespace);
		cnpgCluster.buildDb(this, pgDb);

		const host = `mealie.${ssot.cloudflare.domain}`;
		const pvc = new PersistentVolumeClaim(this, "mealie-pvc", {
			metadata: {
				namespace,
				name: "mealie-pvc",
			},
			storageClassName: CloudReplicatedStorageClass.className,
			accessModes: [PersistentVolumeAccessMode.READ_WRITE_ONCE],
			storage: Size.gibibytes(2),
		});

		const mealieOauthSecret = Secret.fromSecretName(
			this,
			"mealie-oauth",
			"mealie-oauth",
		);

		const mealieDeployment = new Deployment(this, "mealie-deployment", {
			replicas: 1,
			metadata: {
				namespace,
			},
			containers: [
				{
					name: "mealie",
					image: "ghcr.io/mealie-recipes/mealie:v3.3.2",
					securityContext: {
						ensureNonRoot: false
					},
					ports: [
						{
							number: 9000,
						},
					],
					envVariables: {
						BASE_URL: EnvValue.fromValue(`https://${host}`),
						PREFERRED_URL_SCHEME: EnvValue.fromValue("https"),
						ALLOW_SIGNUP: EnvValue.fromValue("false"),
						DB_ENGINE: EnvValue.fromValue("postgres"),
						POSTGRES_SERVER: EnvValue.fromValue(cnpgCluster.host),
						POSTGRES_DB: EnvValue.fromValue(pgDb),
						POSTGRES_USER: secret.envValue("username"),
						POSTGRES_PASSWORD: secret.envValue("password"),
						OIDC_AUTH_ENABLED: EnvValue.fromValue("true"),
						OIDC_PROVIDER_NAME: EnvValue.fromValue("authentik"),
						ALLOW_PASSWORD_LOGIN: EnvValue.fromValue("false"),
						OIDC_CONFIGURATION_URL: EnvValue.fromValue(
							Authentik.configurationUrl("mealie"),
						),
						OIDC_CLIENT_ID: mealieOauthSecret.envValue("CLIENT_ID"),
						OIDC_CLIENT_SECRET: mealieOauthSecret.envValue("CLIENT_SECRET"),
						OIDC_SIGNUP_ENABLED: EnvValue.fromValue("true"),
						OIDC_USER_GROUP: EnvValue.fromValue("mealie-users"),
						OIDC_ADMIN_GROUP: EnvValue.fromValue("mealie-admins"),
						OIDC_AUTO_REDIRECT: EnvValue.fromValue("true"),
						OIDC_REMEMBER_ME: EnvValue.fromValue("true"),
					},
					volumeMounts: [
						{
							volume: Volume.fromPersistentVolumeClaim(
								this,
								"mealie-volume",
								pvc,
							),
							path: "/app/data",
						},
					],
				},
			],
		});

		const service = mealieDeployment.exposeViaService();
		new DefaultTunnelBinding(
			this,
			"cluster-tunnel",
			[
				{
					subdomain: "mealie",
					service,
				},
			],
			tunnel,
		);
	}
}
