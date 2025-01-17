# Bootstrapping the Cluster

When deploying, pulumi uses the secrets encrypted with [agenix](https://github.com/ryantm/agenix). Even when self hosting, [backblaze](backblaze.com) is used for blob storage (to avoid having to deal with redundancy) so age secrets are required.

# dev

always activate devshell

to run dev with tauri, run `dev`
to run dev with browser, run `dev-fe`
