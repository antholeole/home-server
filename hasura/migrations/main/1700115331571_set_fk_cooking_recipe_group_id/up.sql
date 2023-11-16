alter table "cooking"."recipe"
  add constraint "recipe_group_id_fkey"
  foreign key ("group_id")
  references "public"."group"
  ("id") on update restrict on delete restrict;
