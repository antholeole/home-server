alter table "public"."user_to_group"
  add constraint "user_to_group_group_id_fkey"
  foreign key ("group_id")
  references "public"."group"
  ("id") on update restrict on delete restrict;
