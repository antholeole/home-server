# I don't really use this file. Its just a convienent way to remember commands.
apply-all:
    colmena apply --all --impure
agenix-new-device:
    echo "generating a new private key..."
    rage ~/.secrets/age-pk.age
    echo "make the above a master key in /secrets/secrets.nix!"
