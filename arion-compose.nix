{ pkgs, ... }:
let dbDataVolume = "db_data";
in {
  config = {

    project.name = "home-manager";

    docker-compose.volumes = { "${dbDataVolume}" = { }; };
    services = let
      postgres = (import ./vars.nix).postgres;
      hasura = (import ./vars.nix).hasura;
      console = (import ./vars.nix).console;
    in {
      "${postgres.serviceName}".service = {
        image = "postgres:15";
        restart = "always";
        volumes = [ "${dbDataVolume}:/var/lib/postgresql/data" ];
        environment = with postgres; {
          POSTGRES_PASSWORD = password;
          POSTGRES_USER = user;
          POSTGRES_DB = db;
        };
      };

      "${hasura.serviceName}".service = {
        image = hasura.image;

        ports = [ "${hasura.port}:${hasura.port}" ];
        depends_on = [ postgres.serviceName ];
        restart = "always";

        environment = with hasura; {
          HASURA_GRAPHQL_DATABASE_URL = with postgres;
            "postgres://${user}:${password}@${serviceName}:${
              builtins.toString port
            }/${db}";

          # we need to use the CLI in order for migrations to be automatically persisted
          HASURA_GRAPHQL_ENABLE_CONSOLE = "false";
          HASURA_GRAPHQL_DEV_MODE = "true";
          HASURA_GRAPHQL_ENABLED_LOG_TYPES =
            "http-log, webhook-log, websocket-log, query-log";
          HASURA_GRAPHQL_ADMIN_SECRET = adminSecret;
          HASURA_GRAPHQL_MIGRATIONS_DIR = migrationDir;
          HASURA_GRAPHQL_METADATA_DIR = metadataDir;
          HASURA_GRAPHQL_JWT_SECRET = builtins.toJSON {
            type = "HS256";
            key = jwtSecret;
          };
          WEBHOOK_URL = webhookUrl;
          WEBHOOK_SECRET_KEY = webookSecret;
          HASURA_GRAPHQL_UNAUTHORIZED_ROLE = "'unauthenticated'";
          HASURA_GRAPHQL_ENABLE_ALLOWLIST = "true";
        };

        healthcheck = with hasura; {
          test = ["CMD" "nc" "-z" "localhost" port];
          interval = "4s";
          timeout = "5s";
          start_period = "10s";
        };

        volumes = with hasura; [
          "${toString ./hasura/migrations}:${migrationDir}"
          "${toString ./hasura/metadata}:${metadataDir}"
        ];
      };

      console.service = with hasura;
        let workDir = "/hasura";
        in {
          inherit image;

          depends_on = {
            "${serviceName}" = { condition = "service_healthy"; };
          };

          ports = with console; [
            "${port}:${port}"
            "9693:9693" # I don't know why this is required
          ];

          volumes = [ "${toString ./hasura}:${workDir}" ];

          working_dir = "${workDir}";

          entrypoint = with hasura; "sh -c 'hasura-cli console --no-browser --address 0.0.0.0 --endpoint http://${serviceName}:${port} --console-hge-endpoint http://localhost:${port}'";

          environment = { HASURA_GRAPHQL_ADMIN_SECRET = hasura.adminSecret; };
        };
    };
  };
}
