let
  oleinaIdentity = {
    identity = "/home/oleina/.secrets/age-pk.age";
    pubkey = "age1799466kpj0snuc5w7375gcufzq5z5xc6k8jtg4jxjqg9z3r9ufusnu2cly";
  };
in rec {
  masterIdentities = [
    oleinaIdentity
  ];

  # DO NOT USE AGENIX DIRECTLY TO REKEY! instead, use agenix-rekey.
  #
  # This file is for compat with agenix-shell, which does not understand agenix
  # rekey.
  "cf-tunnel-secret.age".publicKeys = builtins.map (identity: identity.pubkey) masterIdentities;
}
