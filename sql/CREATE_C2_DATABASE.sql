--    This file creates the C2 database.
--    Copyright (C) 2023  Christophe SUBLET (KrysCat-KitKat)

--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.

--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.

--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <https://www.gnu.org/licenses/>.

CREATE TABLE IF NOT EXISTS "OrderTemplate" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "type" INTEGER NOT NULL,
    "user" INTEGER NOT NULL,
    "creationTime" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "data" VARCHAR(255) NOT NULL,
    "readPermission" INTEGER NOT NULL,
    "executePermission" INTEGER NOT NULL,
    "after" INTEGER,
    "name" VARCHAR(100) UNIQUE NOT NULL,
    "description" TEXT NOT NULL,
    "filename" VARCHAR(255),
    "timeout" INTEGER,
    FOREIGN KEY ("type") REFERENCES "OrderType" ("id"),
    FOREIGN KEY ("user") REFERENCES "User" ("id"),
    FOREIGN KEY ("after") REFERENCES "OrderTemplate" ("id")
);

CREATE TABLE IF NOT EXISTS "OrderInstance"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "startDate" DATETIME NOT NULL,
    "user" INTEGER NOT NULL,
    "orderTargetType" INTEGER NOT NULL DEFAULT 1,  -- if 1 then Agent else Group
    "template" INTEGER NOT NULL,
    FOREIGN KEY ("user") REFERENCES "User" ("id"),
    FOREIGN KEY ("template") REFERENCES "OrderTemplate" ("id")
);

CREATE TABLE IF NOT EXISTS "OrderResult"(
    "data" VARCHAR(255) NOT NULL,
    "exitcode" INTEGER NOT NULL,
    "error" VARCHAR(255) NOT NULL,
    "requestDate" DATETIME NOT NULL,
    "responseDate" DATETIME NOT NULL,
    "startDate" DATETIME NOT NULL,
    "endDate" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "agent" INTEGER NOT NULL,
    "instance" INTEGER NOT NULL,
    FOREIGN KEY ("agent") REFERENCES "Agent" ("id"),
    FOREIGN KEY ("instance") REFERENCES "OrderInstance" ("id")
);

CREATE TABLE IF NOT EXISTS "Agent"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "name" CHAR(255) UNIQUE NOT NULL,
    "os" INTEGER NOT NULL,
    "key" CHAR(255) UNIQUE NOT NULL,
    "ips" CHAR(100) NOT NULL,
    FOREIGN KEY ("os") REFERENCES "OS" ("id")
);

CREATE TABLE IF NOT EXISTS "UnionGroupAgent"(
    "agent" INTEGER NOT NULL,
    "group" INTEGER NOT NULL,
    "user" INTEGER NOT NULL,
    UNIQUE("agent", "group"),
    FOREIGN KEY ("agent") REFERENCES "Agent" ("id"),
    FOREIGN KEY ("group") REFERENCES "AgentsGroup" ("id"),
    FOREIGN KEY ("user") REFERENCES "User" ("id")
);

CREATE TABLE IF NOT EXISTS "AgentsGroup"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "name" CHAR(255) UNIQUE NOT NULL,
    "description" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "User"(
    "id" INTEGER PRIMARY KEY NOT NULL,
    "name" VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS "OrderType"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "name" CHAR(255) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS "OrderToGroup"(
    "group" INTEGER NOT NULL,
    "instance" INTEGER NOT NULL,
    FOREIGN KEY ("group") REFERENCES "AgentsGroup" ("id"),
    FOREIGN KEY ("instance") REFERENCES "OrderInstance" ("id")
);

CREATE TABLE IF NOT EXISTS "OrderToAgent"(
    "agent" INTEGER NOT NULL,
    "instance" INTEGER NOT NULL,
    FOREIGN KEY ("agent") REFERENCES "Agent" ("id"),
    FOREIGN KEY ("instance") REFERENCES "OrderInstance" ("id")
);

CREATE TABLE IF NOT EXISTS "OS"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "name" INTEGER UNIQUE NOT NULL
);

CREATE VIEW IF NOT EXISTS "Groups" AS
SELECT 
    "Agent"."name" AS "name",
    "OS"."name" AS "os",
    "Agent"."ips" AS "ips",
    "AgentsGroup"."name" AS "group",
    "AgentsGroup"."description" AS "description",
    "User"."name" AS "user"
FROM "Agent"
INNER JOIN "OS" ON "Agent"."os" = "OS"."id"
INNER JOIN "UnionGroupAgent" ON "UnionGroupAgent"."agent" = "Agent"."id"
INNER JOIN "AgentsGroup" ON "UnionGroupAgent"."group" = "AgentsGroup"."id"
INNER JOIN "User" ON "UnionGroupAgent"."user" = "User"."id";

CREATE VIEW IF NOT EXISTS "AgentToOrdersInstances" AS
SELECT
    "OrderType"."name" AS "type",
    "User"."name" AS "user",
    "OrderTemplate"."name" AS "name",
    "OrderTemplate"."description" AS "description",
    "OrderTemplate"."data" AS "data",
    "OrderTemplate"."filename" AS "filename",
    "OrderInstance"."startDate" AS "timestamp",
    "OrderTemplate"."timeout" AS "timeout",
    "OrderInstance"."id" AS "id",
    "OrderTemplate"."after" AS "after"
FROM "Agent"
INNER JOIN "UnionGroupAgent" ON "Agent"."id" = "UnionGroupAgent"."agent"
INNER JOIN "AgentsGroup" ON "UnionGroupAgent"."group" = "AgentsGroup"."id"
INNER JOIN "OrderToGroup" ON "AgentsGroup"."id" = "OrderToGroup"."group"
INNER JOIN "OrderInstance" ON "OrderToGroup"."instance" = "OrderInstance"."id"
INNER JOIN "OrderTemplate" ON "OrderInstance"."template" = "OrderTemplate"."id"
INNER JOIN "OrderType" ON "OrderTemplate"."type" = "OrderType"."id"
INNER JOIN "OrderResult" ON "OrderInstance"."id" = "OrderResult"."instance"
INNER JOIN "User" ON "OrderInstance"."id" = "User"."id"
WHERE "OrderInstance"."orderTargetType" != 1
AND NOT EXISTS(
    SELECT "OrderResult"."agent" FROM "OrderResult"
    INNER JOIN "OrderInstance" ON "OrderInstance"."id" = "OrderResult"."instance"
    WHERE "OrderResult"."agent" = "Agent"."id"
    AND "OrderResult"."instance" = "OrderInstance"."id"
) UNION SELECT
    "OrderType"."name" AS "type",
    "User"."name" AS "user",
    "OrderTemplate"."name" AS "name",
    "OrderTemplate"."description" AS "description",
    "OrderTemplate"."data" AS "data",
    "OrderTemplate"."filename" AS "filename",
    "OrderInstance"."startDate" AS "timestamp",
    "OrderTemplate"."timeout" AS "timeout",
    "OrderInstance"."id" AS "id",
    "OrderTemplate"."after" AS "after"
FROM "Agent"
INNER JOIN "OrderToAgent" ON "Agent"."id" = "OrderToAgent"."agent"
INNER JOIN "OrderInstance" ON "OrderToAgent"."instance" = "OrderInstance"."id"
INNER JOIN "OrderTemplate" ON "OrderInstance"."template" = "OrderTemplate"."id"
INNER JOIN "OrderType" ON "OrderTemplate"."type" = "OrderType"."id"
INNER JOIN "OrderResult" ON "OrderInstance"."id" = "OrderResult"."instance"
INNER JOIN "User" ON "OrderInstance"."id" = "User"."id"
WHERE "OrderInstance"."orderTargetType" == 1
AND NOT EXISTS(
    SELECT "OrderResult"."agent" FROM "OrderResult"
    INNER JOIN "OrderInstance" ON "OrderInstance"."id" = "OrderResult"."instance"
    WHERE "OrderResult"."agent" = "Agent"."id"
    AND "OrderResult"."instance" = "OrderInstance"."id"
);

CREATE VIEW IF NOT EXISTS "Orders" AS
SELECT
    "OrderTemplate"."name" AS "task",
    "OrderTemplate"."description" AS "description",
    "OrderTemplate"."data" AS "data",
    "OrderTemplate"."creationTime" AS "creation",
    "OrderType"."name" AS "orderType",
    "OrderTemplate"."user" AS "userCreation",
    "OrderTemplate"."readPermission" AS "readPermission",
    "OrderTemplate"."executePermission" AS "executePermission",
    "OrderInstance"."user" AS "userExecution",
    "OrderInstance"."startDate" AS "start",
    "OrderInstance"."orderTargetType" AS "targetType",
    "OrderRequired"."name" AS "requirementTask",
    "OrderInstance"."id" AS "id"
FROM "OrderTemplate"
INNER JOIN "OrderInstance" ON "OrderTemplate"."id" = "OrderInstance"."template"
INNER JOIN "OrderType" ON "OrderTemplate"."type" = "OrderType"."id"
INNER JOIN "OrderTemplate" AS "OrderRequired" ON "OrderTemplate"."after" = "OrderRequired"."id";

CREATE VIEW IF NOT EXISTS "AgentOrders" AS
SELECT
    "Orders"."task" AS "task",
    "Agent"."name" AS "agent",
    "Orders"."description" AS "description",
    "Orders"."data" AS "data",
    "Orders"."start" AS "start",
    "Orders"."userExecution" AS "user",
    "Agent"."ips" AS "ips",
    "OS"."name" AS "os"
FROM "Orders"
INNER JOIN "OrderToAgent" ON "Orders"."id" = "OrderToAgent"."instance"
INNER JOIN "Agent" ON "OrderToAgent"."agent" = "Agent"."id"
INNER JOIN "OS" ON "Agent"."os" = "OS"."id"
WHERE "Orders"."targetType" = 1;

CREATE VIEW IF NOT EXISTS "GroupOrders" AS
SELECT
    "Orders"."task" AS "task",
    "AgentsGroup"."name" AS "group",
    "AgentsGroup"."description" AS "groupDescription",
    "Orders"."description" AS "taskDescription",
    "Orders"."data" AS "data",
    "Orders"."start" AS "start",
    "Orders"."userExecution" AS "user"
FROM "Orders"
INNER JOIN "OrderToGroup" ON "Orders"."id" = "OrderToGroup"."instance"
INNER JOIN "AgentsGroup" ON "OrderToGroup"."group" = "AgentsGroup"."id"
WHERE "Orders"."targetType" != 1;

CREATE VIEW IF NOT EXISTS "Tasks" AS
SELECT
    "OrderResult"."data" AS "data",
    "OrderResult"."exitcode" AS "exitcode",
    "OrderResult"."error" AS "error",
    "OrderResult"."requestDate" AS "requestDate",
    "OrderResult"."responseDate" AS "responseDate",
    "OrderResult"."startDate" AS "startDate",
    "OrderResult"."endDate" AS "endDate",
    "OrderTemplate"."name" AS "task",
    "OrderTemplate"."data" AS "taskData",
    "OrderInstance"."user" AS "user",
    "Agent"."name" AS "agent"
FROM "OrderResult"
INNER JOIN "OrderInstance" ON "OrderInstance"."id" = "OrderResult"."instance"
INNER JOIN "OrderTemplate" ON "OrderInstance"."template" = "OrderTemplate"."id"
INNER JOIN "Agent" ON "OrderResult"."agent" = "Agent"."id";

CREATE VIEW IF NOT EXISTS "GroupTasks" AS
SELECT
    "AgentsGroup"."name" AS "group",
    "AgentsGroup"."description" AS "groupDescription",
    "OrderTemplate"."name" AS "task",
    "OrderTemplate"."description" AS "taskDescription",
    "OrderTemplate"."data" AS "data",
    "OrderInstance"."startDate" AS "start",
    "User"."name" AS "user"
FROM "AgentsGroup"
INNER JOIN "OrderToGroup" ON "OrderToGroup"."group" = "AgentsGroup"."id"
INNER JOIN "OrderInstance" ON "OrderToGroup"."instance" = "OrderInstance"."id"
INNER JOIN "User" ON "OrderInstance"."user" = "User"."id"
INNER JOIN "OrderTemplate" ON "OrderInstance"."template" = "OrderTemplate"."id";

INSERT INTO "OS" ("name") VALUES ("Windows"), ("Linux"), ("Darwin");
INSERT INTO "AgentsGroup" ("name", "description") VALUES ("Windows", "All Windows Agents"), ("Linux", "All Linux Agents"), ("Darwin", "All Darwin (Mac) Agents");
INSERT INTO "OrderType" ("name") VALUES ("COMMAND"), ("UPLOAD"), ("DOWNLOAD");

SELECT * FROM OS;
SELECT * FROM AgentsGroup;
SELECT * FROM OrderType;
