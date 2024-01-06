alter table "cooking"."ingredients" alter column "group_id" drop not null;
alter table "cooking"."ingredients" add column "group_id" uuid;
