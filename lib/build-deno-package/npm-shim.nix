# prefetch the npm deps for deno. in order to use fetchNpmDeps, we must generate
# a package.json.
pkgs: denoLock: let
  generateNpmLockStatement = {
    pname,
    version,
    integrity,
    dependencies,
  }: {
    "node_modules/${pname}" = {
      inherit version integrity;
      "resolved" = "https =//registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
      "integrity" = "sha512-KMReFUr0B4t+D+OBkjR3KYqvocp2XaSzO55UcB6mgQMd3KbcE+mWTyvVV7D/zsdEbNnV6acZUutkiHQXvTr1Rw==";
      "dependencies" = {
        "normalize-path" = "^3.0.0";
        "picomatch" = "^2.0.4";
      };
    };
  };
in
  pkgs.fetchNpmDeps {
  }
