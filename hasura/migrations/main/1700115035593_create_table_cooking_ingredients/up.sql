CREATE TABLE "cooking"."ingredients" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "name" Text NOT NULL, PRIMARY KEY ("id") , UNIQUE ("name"), UNIQUE ("id"));
CREATE EXTENSION IF NOT EXISTS pgcrypto;
