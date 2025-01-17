let
  systems = {};
  users = {
    oleina-aperature = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILMONUA/E+gApqgOnZViK+TRQzsok9KWay3aaxE0umO1";
  };

  allUsers = builtins.attrValues users;
  allSystems = builtins.attrValues systems;
in {
  "linode.age".publicKeys = [users.oleina-aperature];
}
