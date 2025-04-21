run the cdk scripts by using the `cdk` command provided in the devshell.

Its a simple wrapper around `pulumi`, which makes sure env vars are in place
before executing any command.

There are multiple layers of protection for security.

- The cloudflare api key used to run this is not in band at all; you must
  manually export a CLOUDFLARE_API_TOKEN variable. (this means that basically
  I re-roll it every time I sit down because I never wrote it down anywhere.)
- other secrets, such as the tunnel secret, are encrypted in an age file.
- the statefile is password encrypted as well.
