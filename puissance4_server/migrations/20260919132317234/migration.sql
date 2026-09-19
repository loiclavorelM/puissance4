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
CREATE TABLE "offline_match_result" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "spaceId" bigint,
    "result" text NOT NULL,
    "botLevel" text NOT NULL,
    "moves" json NOT NULL,
    "playedAt" timestamp without time zone NOT NULL,
    "reconciled" boolean NOT NULL DEFAULT false
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "crdt_data_attempted_value" (
    "id" bigserial PRIMARY KEY,
    "fieldId" bigint NOT NULL,
    "value" jsonb NOT NULL,
    "projectionReason" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "crdt_data_attempted_value__fieldId__unique_idx" ON "crdt_data_attempted_value" USING btree ("fieldId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "crdt_data_fields" (
    "id" bigserial PRIMARY KEY,
    "hlcDatetime" timestamp without time zone NOT NULL,
    "hlcCounter" bigint NOT NULL,
    "rowId" bigint NOT NULL,
    "columnId" bigint NOT NULL,
    "nodeId" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "crdt_data_fields_row_column_idx" ON "crdt_data_fields" USING btree ("rowId", "columnId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "crdt_data_rows" (
    "id" bigserial PRIMARY KEY,
    "hlcDatetime" timestamp without time zone NOT NULL,
    "hlcCounter" bigint NOT NULL,
    "spaceId" bigint NOT NULL,
    "tblId" bigint NOT NULL,
    "uuidRowId" uuid NOT NULL,
    "nodeId" bigint NOT NULL,
    "visibility" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "crdt_data_rows_space_tbl_row_idx" ON "crdt_data_rows" USING btree ("spaceId", "tblId", "uuidRowId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "crdt_data_tombstone" (
    "id" bigserial PRIMARY KEY,
    "hlcDatetime" timestamp without time zone NOT NULL,
    "hlcCounter" bigint NOT NULL,
    "rowId" bigint NOT NULL,
    "nodeId" bigint NOT NULL,
    "clFlag" bigint NOT NULL,
    "reason" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "crdt_data_tombstone_row_idx" ON "crdt_data_tombstone" USING btree ("rowId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "crdt_nodes" (
    "id" bigserial PRIMARY KEY,
    "uuidNodeId" uuid NOT NULL DEFAULT gen_random_uuid_v7(),
    "lastHlc" jsonb
);

-- Indexes
CREATE UNIQUE INDEX "crdt_nodes__uuidNodeId__unique_idx" ON "crdt_nodes" USING btree ("uuidNodeId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "crdt_schema_columns" (
    "id" bigserial PRIMARY KEY,
    "tblId" bigint NOT NULL,
    "name" text NOT NULL,
    "columnType" text NOT NULL,
    "dartType" text NOT NULL,
    "isNullable" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "crdt_schema_columns_table_column_idx" ON "crdt_schema_columns" USING btree ("tblId", "name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "crdt_schema_tables" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "crdt_schema_tables__name__unique_idx" ON "crdt_schema_tables" USING btree ("name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "offline_sync_integrity_violations" (
    "id" bigserial PRIMARY KEY,
    "type" text NOT NULL,
    "domainTableName" text NOT NULL,
    "uuidRowId" uuid NOT NULL,
    "ownerSpaceUuid" uuid,
    "incomingSpaceUuid" uuid NOT NULL,
    "operation" text NOT NULL,
    "uuidNodeId" uuid,
    "crdtDataRowId" bigint,
    "hlcDatetime" timestamp without time zone,
    "hlcCounter" bigint,
    "firstSeenAt" timestamp without time zone NOT NULL,
    "lastSeenAt" timestamp without time zone NOT NULL,
    "occurrences" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "offline_sync_integrity_violations_key_idx" ON "offline_sync_integrity_violations" USING btree ("type", "operation", "domainTableName", "uuidRowId", "ownerSpaceUuid", "incomingSpaceUuid");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "offline_sync_space_members" (
    "id" bigserial PRIMARY KEY,
    "spaceId" bigint NOT NULL,
    "userUuid" uuid NOT NULL,
    "role" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "offline_sync_space_member_unique_idx" ON "offline_sync_space_members" USING btree ("userUuid", "spaceId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "offline_sync_space_nodes" (
    "id" bigserial PRIMARY KEY,
    "spaceId" bigint NOT NULL,
    "nodeId" bigint NOT NULL,
    "lastReceivedHlc" jsonb
);

-- Indexes
CREATE UNIQUE INDEX "offline_sync_space_node_unique_idx" ON "offline_sync_space_nodes" USING btree ("spaceId", "nodeId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "offline_sync_spaces" (
    "id" bigserial PRIMARY KEY,
    "uuidSpaceId" uuid NOT NULL DEFAULT gen_random_uuid_v7(),
    "currentNodeId" bigint
);

-- Indexes
CREATE UNIQUE INDEX "offline_sync_spaces__uuidSpaceId__unique_idx" ON "offline_sync_spaces" USING btree ("uuidSpaceId");

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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "crdt_data_attempted_value"
    ADD CONSTRAINT "crdt_data_attempted_value_fk_0"
    FOREIGN KEY("fieldId")
    REFERENCES "crdt_data_fields"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "crdt_data_fields"
    ADD CONSTRAINT "crdt_data_fields_fk_0"
    FOREIGN KEY("rowId")
    REFERENCES "crdt_data_rows"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "crdt_data_fields"
    ADD CONSTRAINT "crdt_data_fields_fk_1"
    FOREIGN KEY("columnId")
    REFERENCES "crdt_schema_columns"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "crdt_data_fields"
    ADD CONSTRAINT "crdt_data_fields_fk_2"
    FOREIGN KEY("nodeId")
    REFERENCES "crdt_nodes"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "crdt_data_rows"
    ADD CONSTRAINT "crdt_data_rows_fk_0"
    FOREIGN KEY("spaceId")
    REFERENCES "offline_sync_spaces"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "crdt_data_rows"
    ADD CONSTRAINT "crdt_data_rows_fk_1"
    FOREIGN KEY("tblId")
    REFERENCES "crdt_schema_tables"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "crdt_data_rows"
    ADD CONSTRAINT "crdt_data_rows_fk_2"
    FOREIGN KEY("nodeId")
    REFERENCES "crdt_nodes"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "crdt_data_tombstone"
    ADD CONSTRAINT "crdt_data_tombstone_fk_0"
    FOREIGN KEY("rowId")
    REFERENCES "crdt_data_rows"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "crdt_data_tombstone"
    ADD CONSTRAINT "crdt_data_tombstone_fk_1"
    FOREIGN KEY("nodeId")
    REFERENCES "crdt_nodes"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "crdt_schema_columns"
    ADD CONSTRAINT "crdt_schema_columns_fk_0"
    FOREIGN KEY("tblId")
    REFERENCES "crdt_schema_tables"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "offline_sync_space_members"
    ADD CONSTRAINT "offline_sync_space_members_fk_0"
    FOREIGN KEY("spaceId")
    REFERENCES "offline_sync_spaces"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "offline_sync_space_nodes"
    ADD CONSTRAINT "offline_sync_space_nodes_fk_0"
    FOREIGN KEY("spaceId")
    REFERENCES "offline_sync_spaces"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "offline_sync_space_nodes"
    ADD CONSTRAINT "offline_sync_space_nodes_fk_1"
    FOREIGN KEY("nodeId")
    REFERENCES "crdt_nodes"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "offline_sync_spaces"
    ADD CONSTRAINT "offline_sync_spaces_fk_0"
    FOREIGN KEY("currentNodeId")
    REFERENCES "crdt_nodes"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR puissance4
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('puissance4', '20260919132317234', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260919132317234', "timestamp" = now();

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
