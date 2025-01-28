{lib, ...}: {
  options = {
    diskName = lib.mkOption {
      type = lib.types.str;
      description = "The name of the primary disk (e.g., sda, nvme0n1).";
      example = "/dev/sda";
    };
  };
}
