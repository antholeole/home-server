{...}: {
  # TODO: write a script that re-seals these; these are dependent on the certs
  # created by k3s.
  #
  # current process:
  # 1. ssh into the server
  # 2. kubectl create secret -n <namespace> generic <secret name> <populate> --dry-run=client -o json > file.json
  # 3. kubeseal --controller-namespace sealed-secrets --controller-name sealed-secrets -f file.json -w sealed.json
  # 4. look in contents of sealed, copy the secret over.
  secrets = builtins.fromJSON (builtins.readFile ./sealed.json);
}
