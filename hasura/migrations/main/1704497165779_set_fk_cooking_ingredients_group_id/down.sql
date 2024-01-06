alter table "cooking"."ingredients" drop constraint "ingredients_group_id_fkey",
  add constraint "ingredients_group_id_fkey"
  foreign key ("group_id")
  references "public"."group"
  ("id") on update cascade on delete cascade;
