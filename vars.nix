{
    postgres = {
        password = "pgpass";
        serviceName = "postgres";
        db = "postgres";
        user = "postgres";
        port = 5432;
    };

    hasura = {
      adminSecret = "ImASecret";
      jwtSecret = "jwtSecretAtLeast32CharactersLongLmfaoo";
      webhookUrl = "TODO";
      webookSecret = "SomeSecret";
      migrationDir = "/migrations";
      metadataDir = "/metadata";
    };
}