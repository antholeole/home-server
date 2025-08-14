{
  pkgs,
  lib,
  ...
}: {
  age.generators.x509-priv = {
    pkgs,
    file,
    ...
  }: ''
    ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 -out ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".crt")} -days 365 -nodes -subj "/CN=sealed-secret/O=sealed-secret"

    cat ${lib.escapeShellArg (lib.removeSuffix ".age" file)}
  '';
}
