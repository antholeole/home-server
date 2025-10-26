{flake-config, pkgs,...}: {
  imports = with flake-config.flake.modules.nixos; [
    core
    wifi
    disk-efi

    k3s
    
    {config.facter.reportPath = ./facter.json;}
  ];

  environment.systemPackages = with pkgs; [
    k9s
  ];

  services.k3s.role = "server";

  networking.hostName = "riverwood";
  diskName = "/dev/nvme0n1";
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBF5GFDJhwfox9ITJJJrYKtaXVCX9J+X43bTJR09iXtb";
}
