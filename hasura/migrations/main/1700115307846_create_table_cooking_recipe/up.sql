CREATE TABLE "cooking"."recipe" ("name" text NOT NULL, "description" text, "group_id" uuid NOT NULL, "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "id" uuid NOT NULL DEFAULT gen_random_uuid(), PRIMARY KEY ("id") );
CREATE OR REPLACE FUNCTION "cooking"."set_current_timestamp_updated_at"()
RETURNS TRIGGER AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER "set_cooking_recipe_updated_at"
BEFORE UPDATE ON "cooking"."recipe"
FOR EACH ROW
EXECUTE PROCEDURE "cooking"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_cooking_recipe_updated_at" ON "cooking"."recipe"
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
