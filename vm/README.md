# Quickstart

1. to first "infect" the system with nixos, boot it using the iso generated from `make-iso`. 
1. Then, boot the system with the iso. It should show up in your router - grab the private IP that the router assigned.
1. create a disko config in `./devices/<device>.nix`.
1.  `nixos-anywhere --generate-hardware-config nixos-generate-config ./vm/devices/<device>-hardware-config.nix --flake .#<device> root@<device ip>`
1. voila! reboot the system without USB and enjoy your nixOS install.

# Building

`bootstrap-iso` contains the configuration required to to make a minimal boot iso _except_ for the agenix secret files. To generate an iso, please run `make-iso`: this is to ensure that no secret files end up in the nix store. `make-iso` assumes you have a secret key in `~/.secrets/id_ed25519`.  

# Developing

To start the minimal iso in qemu, run the `run-iso` app. Then, you can ssh into it with `ssh localhost -p 2222 -l manager`, provided you have configured it with the correct public keys. 

Once the machine is running in qemu, `nixos-rebuild switch --use-remote-sudo --build-host localhost --target-host localhost:2222 --flake ".#<flake-role>"` should allow you to iterate on a specialization without having to worry about rebuiliding the iso every time (unless, of course, you're working on the iso itself).
