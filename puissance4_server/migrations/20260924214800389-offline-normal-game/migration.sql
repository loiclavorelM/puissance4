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
-- ACTION DROP TABLE
--
DROP TABLE "offline_match_result" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "offline_match_result" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "spaceId" bigint,
    "status" text NOT NULL,
    "result" text,
    "botId" uuid NOT NULL,
    "botName" text NOT NULL,
    "playedAs" text NOT NULL,
    "moves" json NOT NULL,
    "playedAt" timestamp without time zone NOT NULL,
    "reconciled" boolean NOT NULL DEFAULT false
);

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "offline_match_result"
    ADD CONSTRAINT "offline_match_result_fk_0"
    FOREIGN KEY("spaceId")
    REFERENCES "offline_sync_spaces"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Ajout manuel : le DROP TABLE ci-dessus supprime les lignes, mais pas les
-- métadonnées CRDT de serverpod_offline_sync qui les référencent — sans ce
-- nettoyage, chaque sync échoue en `missingDomainRow` (outboundInsert).
-- Ne touche aucun schéma : definition.sql reste identique.
--
DELETE FROM "crdt_data_rows" r
    USING "crdt_schema_tables" t
    WHERE r."tblId" = t."id" AND t."name" = 'offline_match_result';
DELETE FROM "offline_sync_integrity_violations"
    WHERE "domainTableName" = 'offline_match_result';


--
-- MIGRATION VERSION FOR puissance4
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('puissance4', '20260924214800389-offline-normal-game', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924214800389-offline-normal-game', "timestamp" = now();

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
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_offline_sync
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_offline_sync', '20260914143806119', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260914143806119', "timestamp" = now();


COMMIT;
