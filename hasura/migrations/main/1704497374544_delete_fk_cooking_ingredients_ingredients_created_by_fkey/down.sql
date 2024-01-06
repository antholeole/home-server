alter table "cooking"."ingredients"
  add constraint "ingredients_created_by_fkey"
  foreign key ("group_id")
  references "public"."user"
  ("id") on update restrict on delete restrict;
