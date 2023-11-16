alter table "public"."user_to_group"
  add constraint "user_to_group_user_id_fkey"
  foreign key ("user_id")
  references "public"."user"
  ("user_id") on update restrict on delete restrict;
