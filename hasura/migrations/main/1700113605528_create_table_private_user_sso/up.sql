CREATE TABLE "private"."user_sso" ("sub" text NOT NULL, "id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "provider" text NOT NULL, PRIMARY KEY ("id") , FOREIGN KEY ("provider") REFERENCES "private"."login_providers"("name") ON UPDATE restrict ON DELETE restrict, UNIQUE ("id"), UNIQUE ("sub", "provider"));
CREATE OR REPLACE FUNCTION "private"."set_current_timestamp_updated_at"()
RETURNS TRIGGER AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER "set_private_user_sso_updated_at"
BEFORE UPDATE ON "private"."user_sso"
FOR EACH ROW
EXECUTE PROCEDURE "private"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_private_user_sso_updated_at" ON "private"."user_sso"
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
