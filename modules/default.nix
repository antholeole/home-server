{withSystem, ...}: {
  flake.modules.nixos = {
    core = {
      pkgs,
      system,
      inputs,
      ...
    }: {
      imports = [
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.nixos-facter-modules.nixosModules.facter

        ./core/default.nix
        ./agenix-generators.nix
      ];

      nixpkgs = {
        overlays = let
          overlay = final: prev:
            withSystem system ({
              inputs',
              config,
              ...
            }: {
              # and the following to pkgs.
              helm-charts = inputs.nixhelm.charts {pkgs = prev;};

              manifests = config.packages.manifests;
              tldraw-server = inputs'.tldraw-server-client.packages.tldraw-server;
              tldraw-web-client = inputs'.tldraw-server-client.packages.web-frontend;
            });
        in [
          overlay

          # 3rd party overlays
          inputs.nix-snapshotter.overlays.default
          inputs.nixzx.overlays.default
        ];
      };
    };

    k3s = ./k3s;
    disk-efi = ./disk-efi.nix;
    wifi = ./metal/wifi.nix;
    netboot = ./metal/netboot.nix;
  };
}
