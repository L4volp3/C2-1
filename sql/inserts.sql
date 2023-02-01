-- Insert User
INSERT INTO "User" ("name") VALUES (?) ON CONFLICT DO NOTHING;

-- Insert OS
INSERT INTO "OS" ("name") VALUES (?) ON CONFLICT DO NOTHING;

-- Insert Agent
INSERT INTO "Agent" ("name", "key", "ips", "os")
VALUES (?, ?, ?, (SELECT "id" FROM "OS" WHERE "name" = ?))
ON CONFLICT ("name") DO NOTHING;

-- Insert Group
INSERT INTO "AgentsGroup" ("name", "description") VALUES (?, ?);

-- Insert Agent into Group
INSERT INTO "UnionGroupAgent" ("agent", "group", "user")
VALUES (
    (SELECT "id" FROM "Agent" WHERE "name" = ?),
    (SELECT "id" FROM "AgentsGroup" WHERE "name" = ?),
    (SELECT "id" FROM "User" WHERE "name" = ?)
);

-- Insert OrderTemplate
INSERT INTO "OrderTemplate" ("type", "user", "data", "readPermission", "executePermission", )
