CREATE TABLE "public"."user_to_group" ("user_id" uuid NOT NULL, "group_id" uuid NOT NULL, "owner" boolean NOT NULL, "id" uuid NOT NULL DEFAULT gen_random_uuid(), PRIMARY KEY ("id") , UNIQUE ("user_id", "group_id"));
CREATE EXTENSION IF NOT EXISTS pgcrypto;
