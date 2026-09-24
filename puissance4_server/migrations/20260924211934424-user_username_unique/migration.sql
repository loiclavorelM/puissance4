BEGIN;

--
-- DATA TRANSFORMATION (manuel) : l'ancien pseudo par défaut prenait le
-- préfixe horodaté de l'UUID v7, donc des comptes créés à moins d'une minute
-- d'intervalle partagent le même pseudo. On renomme tous les doublons
-- (insensible à la casse) sauf le plus ancien, avec la fin aléatoire de leur
-- id, avant de poser l'index unique.
--
UPDATE "user" AS u
SET "username" = 'Joueur-' || right(replace(u."id"::text, '-', ''), 8)
FROM (
    SELECT "id",
           row_number() OVER (PARTITION BY lower("username") ORDER BY "createdAt", "id") AS rn
    FROM "user"
) AS d
WHERE u."id" = d."id" AND d.rn > 1;

--
-- ACTION ALTER TABLE
--
CREATE UNIQUE INDEX "user_username_unique_idx" ON "user" USING btree ("username");

--
-- MIGRATION VERSION FOR puissance4
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('puissance4', '20260924211934424-user_username_unique', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924211934424-user_username_unique', "timestamp" = now();

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
