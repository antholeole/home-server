let
  systems = {};
  users = {
    oleina-aperature = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDT9hcQrq60iH/E5VvLyMQzAogZxpatXa924CqosGS7U";
  };

  allUsers = builtins.attrValues users;
  allSystems = builtins.attrValues systems;
in {
  "wifi-pass.age".publicKeys = allUsers ++ allSystems;
}
