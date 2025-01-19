# Parts

This repo is split up into many parts. Each part is in a folder.

-  **🗿 Root**: The root directory; holds shared configs between each part.
-  **📱 Client**: A client application to use on a tablet to talk to the home server.
-  **🖥️ VM**: Contains three VM configurations: 
   - .#bootstrap-iso: a shared iso that can be loaded onto a device and booted from; from there, you can rebuild switch the system over ssh into one of the two below.
   - .#client: the client device, that communicates with the server.
   - .#master-full: A master node for  kubernetes cluster. This also contains the slave node configs, so it can function as a single node kubernetes cluster.

# A Note on Secrets

When deploying, pulumi uses the secrets encrypted with [agenix](https://github.com/ryantm/agenix). Even when self hosting, [backblaze](backblaze.com) is used for blob storage (to avoid having to deal with redundancy) so age secrets are required.

# Devshell

`direnv allow` will enable the devshell.

the devshell provides the following scripts:
- `dev`, which launches the frontend tauri application.
- `dev-fe`,  which launches the frontend application in a browser window.
