alter table "cooking"."ingredient_to_recipe" drop constraint "ingredient_to_recipe_ingredient_id_fkey",
  add constraint "ingredient_to_recipe_ingredient_id_fkey"
  foreign key ("ingredient_id")
  references "cooking"."ingredients"
  ("id") on update restrict on delete restrict;
