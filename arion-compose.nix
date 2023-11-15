{ pkgs, ... }: let
 dbDataVolume = "db_data";
in {


  config = {

  project.name = "home-manager";

  docker-compose.raw.volumes = { "${dbDataVolume}" = {}; };
  services = let
    postgres = {
        password = "pgpass";
        serviceName = "postgres";
        db = "postgres";
        user = "postgres";
        port = 5432;
    };

    hasura = {
      adminSecret = "ImASecret";
      jwtSecret = "jwtSecret";
      webhookUrl = "TODO";
      webookSecret = "SomeSecret";
      migrationDir = "/migrations";
      metadataDir = "/metadata";
    };
  in {
    "${postgres.serviceName}".service = {
        image = "postgres:16";
        restart = "always";
        volumes = [
            "${dbDataVolume}:/var/lib/postgresql/data"
        ];
        environment = with postgres; {
            POSTGRES_PASSWORD = password;
            POSTGRES_USER = user;
            POSTGRES_DB = db;
        };
    };

    graphql-engine.service = {
        image = "hasura/graphql-engine:v2.35.1.cli-migrations-v3";
        ports = [
            "8080:8080"
        ];
        depends_on = [ postgres.serviceName ];
        restart = "always";

    environment = with hasura; {
      HASURA_GRAPHQL_DATABASE_URL = with postgres; "postgres://${user}:${password}@${serviceName}:${builtins.toString port}/${db}";
      HASURA_GRAPHQL_ENABLE_CONSOLE = "true";
      HASURA_GRAPHQL_DEV_MODE = "true";
      HASURA_GRAPHQL_ENABLED_LOG_TYPES = "http-log, webhook-log, websocket-log, query-log";
      HASURA_GRAPHQL_ADMIN_SECRET = adminSecret;
      HASURA_GRAPHQL_MIGRATIONS_DIR = migrationDir;
      HASURA_GRAPHQL_METADATA_DIR = metadataDir;
      HASURA_GRAPHQL_JWT_SECRET = "{'type': 'HS256','key': '${jwtSecret}'}";
      WEBHOOK_URL = webhookUrl;
      WEBHOOK_SECRET_KEY = webookSecret;
      HASURA_GRAPHQL_UNAUTHORIZED_ROLE = "'unauthenticated'";
      HASURA_GRAPHQL_ENABLE_ALLOWLIST = "true";
    };

    volumes = with hasura; [
        "${toString ./hasura/migrations}:${migrationDir}"
        "${toString ./hasura/metadata}:${metadataDir}"
    ];
    };

   };
  };
}