{
  postgres = {
    password = "pgpass";
    serviceName = "postgres";
    db = "postgres";
    user = "postgres";
    port = 5432;
  };

  hasura = {
    image = "hasura/graphql-engine:v2.35.1.cli-migrations-v3";
    serviceName = "graphql-engine";
    adminSecret = "ImASecret";
    jwtSecret = "jwtSecretAtLeast32CharactersLongLmfaoo";
    webhookUrl = "TODO";
    webookSecret = "SomeSecret";
    migrationDir = "/migrations";
    metadataDir = "/metadata";
    port = "8080";
  };

  console = { port = "9695"; };
}
