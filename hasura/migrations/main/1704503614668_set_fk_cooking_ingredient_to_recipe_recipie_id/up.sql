alter table "cooking"."ingredient_to_recipe" drop constraint "ingredient_to_recipe_recipie_id_fkey",
  add constraint "ingredient_to_recipe_recipie_id_fkey"
  foreign key ("recipie_id")
  references "cooking"."recipe"
  ("id") on update cascade on delete cascade;
