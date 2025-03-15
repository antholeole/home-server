import * as cloudflare from "@pulumi/cloudflare";

if (!process.env.CLOUDFLARE_API_TOKEN) {
	throw Error("no cloudflare api token found!");
}

new cloudflare.ZeroTrustTunnelCloudflared("home-server-tunnel", {
	accountId: "e0d74c227439ece29e62209d109ae43e",
	name: "home-server-tunnel",
	secret: "skldjfslkdjflksdj", // this isn't deployed yet not a vuln. TODO: use a agenix secret 
	configSrc: "local",
});
