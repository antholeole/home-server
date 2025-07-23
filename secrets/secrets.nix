let
  mkIdentity = name: pubkey: {
    inherit pubkey;
    identity = "/home/${name}/.secrets/age-pk.age";
  };

  oleinaIdentity = mkIdentity "oleina" "age1y2reh66wsa2v8edt4h0plwpc80qmt44377qah9700dn6dt86hqqq5ffq0r";
  pcIdentity = mkIdentity "anthony" "age1ewp75txs02a33y6tkqcuwqhg53xcf5cmlgcaqvdfxy3cp3nevs6shscypy";
in rec {
  masterIdentities = [
    pcIdentity
    oleinaIdentity
  ];

  # DO NOT USE AGENIX DIRECTLY TO REKEY! instead, use agenix-rekey.
  #
  # This file is for compat with agenix-shell, which does not understand agenix
  # rekey.
  "cf-tunnel-secret.age".publicKeys = builtins.map (identity: identity.pubkey) masterIdentities;
}
