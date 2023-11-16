CREATE TABLE "cooking"."ingredient_to_recipe" ("id" serial NOT NULL, "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "ingredient_id" uuid NOT NULL, "recipie_id" uuid NOT NULL, "quantity" serial NOT NULL, "unit" text NOT NULL, PRIMARY KEY ("id") , FOREIGN KEY ("recipie_id") REFERENCES "cooking"."recipe"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("ingredient_id") REFERENCES "cooking"."ingredients"("id") ON UPDATE restrict ON DELETE restrict);
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
CREATE TRIGGER "set_cooking_ingredient_to_recipe_updated_at"
BEFORE UPDATE ON "cooking"."ingredient_to_recipe"
FOR EACH ROW
EXECUTE PROCEDURE "cooking"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_cooking_ingredient_to_recipe_updated_at" ON "cooking"."ingredient_to_recipe"
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
