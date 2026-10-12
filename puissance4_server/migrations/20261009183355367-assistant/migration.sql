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
CREATE TABLE "assistant_conversation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "assistant_conversation_user_idx" ON "assistant_conversation" USING btree ("userId", "updatedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "assistant_message" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "conversationId" uuid NOT NULL,
    "position" bigint NOT NULL,
    "contentJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "assistant_message_position_unique_idx" ON "assistant_message" USING btree ("conversationId", "position");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "assistant_request_log" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "conversationId" uuid,
    "model" text NOT NULL,
    "inputTokens" bigint NOT NULL,
    "outputTokens" bigint NOT NULL,
    "toolsJson" text NOT NULL,
    "turns" bigint NOT NULL,
    "durationMs" bigint NOT NULL,
    "errorCode" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "assistant_request_log_user_idx" ON "assistant_request_log" USING btree ("userId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "assistant_token" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "conversationId" uuid NOT NULL,
    "token" text NOT NULL,
    "kind" text NOT NULL,
    "ref" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "assistant_token_token_unique_idx" ON "assistant_token" USING btree ("conversationId", "token");
CREATE UNIQUE INDEX "assistant_token_ref_unique_idx" ON "assistant_token" USING btree ("conversationId", "ref");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_dashboard" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "version" bigint NOT NULL,
    "definitionJson" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "user_dashboard_user_unique_idx" ON "user_dashboard" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_dashboard_version" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "dashboardId" uuid NOT NULL,
    "version" bigint NOT NULL,
    "definitionJson" text NOT NULL,
    "author" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "user_dashboard_version_unique_idx" ON "user_dashboard_version" USING btree ("dashboardId", "version");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "assistant_conversation"
    ADD CONSTRAINT "assistant_conversation_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "assistant_message"
    ADD CONSTRAINT "assistant_message_fk_0"
    FOREIGN KEY("conversationId")
    REFERENCES "assistant_conversation"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "assistant_request_log"
    ADD CONSTRAINT "assistant_request_log_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "assistant_token"
    ADD CONSTRAINT "assistant_token_fk_0"
    FOREIGN KEY("conversationId")
    REFERENCES "assistant_conversation"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "user_dashboard"
    ADD CONSTRAINT "user_dashboard_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "user_dashboard_version"
    ADD CONSTRAINT "user_dashboard_version_fk_0"
    FOREIGN KEY("dashboardId")
    REFERENCES "user_dashboard"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR puissance4
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('puissance4', '20261009183355367-assistant', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261009183355367-assistant', "timestamp" = now();

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
