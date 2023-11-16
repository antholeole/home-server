CREATE TABLE "public"."user" ("first_name" text NOT NULL, "last_name" text NOT NULL, "user_id" uuid NOT NULL DEFAULT gen_random_uuid(), PRIMARY KEY ("user_id") , UNIQUE ("user_id"));
CREATE EXTENSION IF NOT EXISTS pgcrypto;
