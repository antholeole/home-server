`bootstrap-iso` contains the configuration required to to make a minimal boot iso, _except_ for the agenix secret files. To generate an iso, please run `make-iso`: this is to ensure that no secret files end up in the nix store.

To start the minimal iso in qemu, run the `run-iso` app. Then, you can ssh into it with `ssh localhost -p 2222 -l manager`, provided you have configured it with the correct public keys. 
