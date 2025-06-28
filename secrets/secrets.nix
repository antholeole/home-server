let
  mkIdentity = name: pubkey: {
    inherit pubkey;
    identity = "/home/${name}/.secrets/age-pk.age";
  };
  
  oleinaIdentity = mkIdentity "oleina" "age102rxc45udneyzn8rea2x9aznpeqjy5huj3f60a2zdg9hzu439urq7m0mh2";
  pcIdentity = mkIdentity "anthony" "age1e9w76gh9mhnd8f8gphegpje0x66d8722g8kgr5napaslt7jf5qcswqack4";
in rec {
  masterIdentities = [
    oleinaIdentity
    pcIdentity
  ];

  # DO NOT USE AGENIX DIRECTLY TO REKEY! instead, use agenix-rekey.
  #
  # This file is for compat with agenix-shell, which does not understand agenix
  # rekey.
  "cf-tunnel-secret.age".publicKeys = builtins.map (identity: identity.pubkey) masterIdentities;
}
