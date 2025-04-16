import * as cloudflare from "@pulumi/cloudflare";
import { z } from "zod";

if (!process.env.FLAKE_ROOT) {
	throw Error(
		"required env vars not found; are you inside the devshell? run pulumi commands through the `cdk` package installed through the devshell.",
	);
}

if (!process.env.CLOUDFLARE_API_TOKEN) {
	throw Error("no cloudflare api token found!");
}

// use zod to tell typescript that all these values certainly exist.
const {
	// TODO: remove this. i thought i was going to create a tunnel this way,
	// but the gateway plugin did it for me. this is currently a useful example
	// for how to pipe info from nix to the cdk - once we do it with another var,
	// this should be removed.
	cf__tunnel: cfTunnel,
	ACCOUNT_ID: accountId,
	ZONE_ID: zoneId,
	DOMAIN: domain,
} = z
	.object({
		cf__tunnel: z.string(),
		ACCOUNT_ID: z.string(),
		ZONE_ID: z.string(),
		DOMAIN: z.string(),
	})
	.parse(process.env);
