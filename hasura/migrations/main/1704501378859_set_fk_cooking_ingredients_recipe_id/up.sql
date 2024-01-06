alter table "cooking"."ingredients"
  add constraint "ingredients_recipe_id_fkey"
  foreign key ("recipe_id")
  references "cooking"."recipe"
  ("id") on update cascade on delete cascade;
