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
    "creationTime" DATE NOT NULL,
    "startTime" DATE NOT NULL,
    "data" VARCHAR(255) NOT NULL,
    "readPermission" INTEGER NOT NULL,
    "executePermission" INTEGER NOT NULL,
    "after" INTEGER NOT NULL,
    "name" VARCHAR(100) UNIQUE NOT NULL,
    "description" TEXT NOT NULL,
    FOREIGN KEY ("type") REFERENCES "OrderType" ("id"),
    FOREIGN KEY ("user") REFERENCES "User" ("id"),
    FOREIGN KEY ("after") REFERENCES "OrderTemplate" ("id")
);

CREATE TABLE IF NOT EXISTS "OrderResult"(
    "output" VARCHAR(255) NOT NULL,
    "exitcode" INTEGER NOT NULL,
    "error" VARCHAR(255) NOT NULL,
    "requestDate" DATE NOT NULL,
    "responseDate" DATE NOT NULL,
    "startDate" DATE NOT NULL,
    "endDate" DATE NOT NULL,
    "agent" INTEGER NOT NULL,
    "instance" INTEGER NOT NULL,
    FOREIGN KEY ("agent") REFERENCES "Agent" ("id"),
    FOREIGN KEY ("instance") REFERENCES "OrderInstance" ("id")
);

CREATE TABLE IF NOT EXISTS "OrderInstance"(
    "id" INTEGER NOT NULL,
    "startDate" DATE NOT NULL,
    "user" INTEGER NOT NULL,
    "orderTargetType" INTEGER NOT NULL DEFAULT '1',  -- if 1 then Agent else Group
    "template" INTEGER NOT NULL,
    FOREIGN KEY ("user") REFERENCES "User" ("id"),
    FOREIGN KEY ("template") REFERENCES "OrderTemplate" ("id")
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
    FOREIGN KEY ("agent") REFERENCES "Agent" ("id"),
    FOREIGN KEY ("group") REFERENCES "AgentsGroup" ("id"),
    FOREIGN KEY ("user") REFERENCES "User" ("id")
);

CREATE TABLE IF NOT EXISTS "AgentsGroup"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "name" CHAR(255) UNIQUE NOT NULL
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

INSERT INTO "OS" ("name") VALUES ("Windows"), ("Linux"), ("Darwin");
INSERT INTO "AgentsGroup" ("name") VALUES ("Windows"), ("Linux"), ("Darwin");
INSERT INTO "OrderType" ("name") VALUES ("COMMAND"), ("UPLOAD"), ("DOWNLOAD");

SELECT * FROM OS;
SELECT * FROM AgentsGroup;
SELECT * FROM OrderType;

