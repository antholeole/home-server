{
  inputs,
  ssot,
  config,
  ...
}: {
  age = {
    # this is incomplete; each device must add the hostPubkey field.
    rekey = {
      masterIdentities = [
        {
          identity = "/home/oleina/.secrets/age-pk.age";
          pubkey = "age1799466kpj0snuc5w7375gcufzq5z5xc6k8jtg4jxjqg9z3r9ufusnu2cly";
        }
      ];
      storageMode = "local";
      localStorageDir = "${inputs.self}/vm/hosts/${config.networking.hostName}/secrets";
    };
  };
}
