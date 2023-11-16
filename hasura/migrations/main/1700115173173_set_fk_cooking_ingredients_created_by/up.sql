alter table "cooking"."ingredients"
  add constraint "ingredients_created_by_fkey"
  foreign key ("created_by")
  references "public"."user"
  ("user_id") on update restrict on delete restrict;
