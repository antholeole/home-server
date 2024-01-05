alter table "public"."user_to_group" drop constraint "user_to_group_user_id_fkey",
  add constraint "user_to_group_user_id_fkey"
  foreign key ("user_id")
  references "public"."user"
  ("id") on update restrict on delete restrict;
