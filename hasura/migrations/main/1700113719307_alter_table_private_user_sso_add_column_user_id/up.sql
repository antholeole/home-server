CREATE EXTENSION IF NOT EXISTS pgcrypto;
alter table "private"."user_sso" add column "user_id" uuid
 null default gen_random_uuid();
