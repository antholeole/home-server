# Building

`bootstrap-iso` contains the configuration required to to make a minimal boot iso _except_ for the agenix secret files. To generate an iso, please run `make-iso`: this is to ensure that no secret files end up in the nix store. `make-iso` assumes you have a secret key in `~/.secrets/id_ed25519`.  

# Developing

To start the minimal iso in qemu, run the `run-iso` app. Then, you can ssh into it with `ssh localhost -p 2222 -l manager`, provided you have configured it with the correct public keys. 

Once the machine is running in qemu, `nixos-rebuild switch --use-remote-sudo --build-host localhost --target-host localhost:2222 --flake ".#<flake-role>"` should allow you to iterate on a specialization without having to worry about rebuiliding the iso every time (unless, of course, you're working on the iso itself).
