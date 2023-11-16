alter table "cooking"."ingredients" alter column "public" set default false;
alter table "cooking"."ingredients" alter column "public" drop not null;
alter table "cooking"."ingredients" add column "public" bool;
