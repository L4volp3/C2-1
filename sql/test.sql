INSERT INTO "User" ("name") VALUES ("UserTest1") ON CONFLICT DO NOTHING;
INSERT INTO "User" ("name") VALUES ("UserTest2") ON CONFLICT DO NOTHING;

INSERT INTO "Agent" ("name", "key", "ips", "os")
VALUES ("TestAgent1", "TestKey1", "127.0.0.1", (SELECT "id" FROM "OS" WHERE "name" = "Windows"))
ON CONFLICT ("name") DO NOTHING;

INSERT INTO "Agent" ("name", "key", "ips", "os")
VALUES ("TestAgent2", "TestKey2", "127.0.0.1", (SELECT "id" FROM "OS" WHERE "name" = "Windows"))
ON CONFLICT ("name") DO NOTHING;

INSERT INTO "AgentsGroup" ("name", "description") VALUES ("TestGroup1", "Test Group 1");
INSERT INTO "AgentsGroup" ("name", "description") VALUES ("TestGroup2", "Test Group 2");

INSERT INTO "UnionGroupAgent" ("agent", "group", "user")
VALUES (
    (SELECT "id" FROM "Agent" WHERE "name" = "TestAgent1"),
    (SELECT "id" FROM "AgentsGroup" WHERE "name" = "TestGroup1"),
    (SELECT "id" FROM "User" WHERE "name" = "UserTest1")
);

INSERT INTO "UnionGroupAgent" ("agent", "group", "user")
VALUES (
    (SELECT "id" FROM "Agent" WHERE "name" = "TestAgent2"),
    (SELECT "id" FROM "AgentsGroup" WHERE "name" = "TestGroup2"),
    (SELECT "id" FROM "User" WHERE "name" = "UserTest2")
);

INSERT INTO "OrderTemplate" (
    "type",
    "user",
    "data",
    "readPermission",
    "executePermission",
    "after",
    "name",
    "description"
) VALUES (
    (SELECT "id" FROM "OrderType" WHERE "name" = "COMMAND"),
    (SELECT "id" FROM "User" WHERE "name" = "UserTest1"),
    "ls -la",
    1001,
    1001,
    (SELECT "id" FROM "OrderTemplate" WHERE "name" = null),
    "TestCommand1",
    "Test Command 1"
);

INSERT INTO "OrderTemplate" (
    "type",
    "user",
    "data",
    "readPermission",
    "executePermission",
    "after",
    "name",
    "description"
) VALUES (
    (SELECT "id" FROM "OrderType" WHERE "name" = "UPLOAD"),
    (SELECT "id" FROM "User" WHERE "name" = "UserTest2"),
    "filename",
    50,
    500,
    (SELECT "id" FROM "OrderTemplate" WHERE "name" = 0),
    "TestCommand2",
    "Test Command 2"
);

INSERT INTO "OrderInstance" (
    "startDate",
    "user",
    "orderTargetType",
    "template"
) VALUES (
    "2023-05-12 02:45:14",
    (SELECT "id" FROM "User" WHERE "name" = "UserTest1"),
    (SELECT CASE WHEN "Agent" = "Agent" THEN 1 ELSE 0 END AS "TargetType"),
    (SELECT "id" FROM "OrderTemplate" WHERE "name" = "TestCommand1")
);

INSERT INTO "OrderToGroup" (
    "group",
    "instance"
) VALUES (
    (SELECT "id" FROM "AgentsGroup" WHERE "name" = "TestGroup1"),
    last_insert_rowid()
);

INSERT INTO "OrderInstance" (
    "startDate",
    "user",
    "orderTargetType",
    "template"
) VALUES (
    "2016-06-22 18:12:25",
    (SELECT "id" FROM "User" WHERE "name" = "UserTest2"),
    (SELECT CASE WHEN "Agent" = "Agent" THEN 1 ELSE 0 END AS "TargetType"),
    (SELECT "id" FROM "OrderTemplate" WHERE "name" = "TestCommand2")
);

INSERT INTO "OrderToGroup" (
    "group",
    "instance"
) VALUES (
    (SELECT "id" FROM "AgentsGroup" WHERE "name" = "TestGroup2"),
    last_insert_rowid()
);

INSERT INTO "OrderInstance" (
    "startDate",
    "user",
    "orderTargetType",
    "template"
) VALUES (
    "2023-05-12 02:45:14",
    (SELECT "id" FROM "User" WHERE "name" = "UserTest1"),
    (SELECT CASE WHEN "Agent" = "Agent" THEN 1 ELSE 0 END AS "TargetType"),
    (SELECT "id" FROM "OrderTemplate" WHERE "name" = "TestCommand1")
);

INSERT INTO "OrderToAgent" (
    "agent",
    "instance"
) VALUES (
    (SELECT "id" FROM "Agent" WHERE "name" = "TestAgent1"),
    last_insert_rowid()
);

INSERT INTO "OrderInstance" (
    "startDate",
    "user",
    "orderTargetType",
    "template"
) VALUES (
    "2016-06-22 18:12:25",
    (SELECT "id" FROM "User" WHERE "name" = "UserTest2"),
    (SELECT CASE WHEN "Agent" = "Agent" THEN 1 ELSE 0 END AS "TargetType"),
    (SELECT "id" FROM "OrderTemplate" WHERE "name" = "TestCommand2")
);

INSERT INTO "OrderToAgent" (
    "agent",
    "instance"
) VALUES (
    (SELECT "id" FROM "Agent" WHERE "name" = "TestAgent2"),
    last_insert_rowid()
);