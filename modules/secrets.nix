{
  inputs,
  config,
  ...
}: let
  masterIdentities = (import "${inputs.self}/secrets/secrets.nix").masterIdentities;
in {
  age = {
    # this is incomplete; each device must add the hostPubkey field.
    rekey = {
      masterIdentities = masterIdentities;

      storageMode = "local";
      localStorageDir = "${inputs.self}/hosts/${config.networking.hostName}/secrets";
    };
  };
}
