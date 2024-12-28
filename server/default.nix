pkgs: let
  python = pkgs.python312;
in
  python.pkgs.buildPythonApplication {
    pyproject = false;
    pname = "home-server";
    version = "0.0.0";
    src = ./.;

    dependencies = with python.pkgs; [
      fastapi
    ];
  }
