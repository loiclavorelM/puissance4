BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "friendship" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "requesterId" uuid NOT NULL,
    "addresseeId" uuid NOT NULL,
    "pairKey" text NOT NULL,
    "status" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "respondedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "friendship_pair_key_unique_idx" ON "friendship" USING btree ("pairKey");
CREATE INDEX "friendship_requester_idx" ON "friendship" USING btree ("requesterId");
CREATE INDEX "friendship_addressee_idx" ON "friendship" USING btree ("addresseeId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "user" ADD COLUMN "friendCode" text;
CREATE UNIQUE INDEX "user_friend_code_unique_idx" ON "user" USING btree ("friendCode");
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "friendship"
    ADD CONSTRAINT "friendship_fk_0"
    FOREIGN KEY("requesterId")
    REFERENCES "user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "friendship"
    ADD CONSTRAINT "friendship_fk_1"
    FOREIGN KEY("addresseeId")
    REFERENCES "user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR puissance4
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('puissance4', '20261004174321977-friends', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261004174321977-friends', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_offline_sync
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_offline_sync', '20260914143806119', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260914143806119', "timestamp" = now();


COMMIT;
