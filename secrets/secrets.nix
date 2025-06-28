let
  oleinaIdentity = {
    identity = "/home/oleina/.secrets/age-pk.age";
    pubkey = "age102rxc45udneyzn8rea2x9aznpeqjy5huj3f60a2zdg9hzu439urq7m0mh2";
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
