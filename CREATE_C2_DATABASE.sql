--    This file creates the C2 database.
--    Copyright (C) 2023  Christophe SUBLET (Chris38000)

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

CREATE TABLE IF NOT EXISTS "Order" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "type" INTEGER NOT NULL,
    "user" INTEGER NOT NULL,
    "creationTime" DATE NOT NULL,
    "startTime" DATE NOT NULL,
    "file" VARCHAR(255) NOT NULL,
    "output" VARCHAR(255) NOT NULL,
    "exitcode" SMALLINT NOT NULL,
    "error" VARCHAR(255) NOT NULL,
    "readPermission" INTEGER NOT NULL,
    "executePermission" INTEGER NOT NULL,
    "orderTargetType" INTEGER NOT NULL DEFAULT '1',  -- if 1 then Agent else Group
    "requestTime" DATE NOT NULL,
    "after" INTEGER NOT NULL,
    FOREIGN KEY ("type") REFERENCES "OrderType" ("id"),
    FOREIGN KEY ("user") REFERENCES "User" ("id"),
    FOREIGN KEY ("after") REFERENCES "Order" ("id")
);
CREATE TABLE "Agent"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "name" CHAR(255) NOT NULL,
    "os" INTEGER NOT NULL,
    "key" CHAR(255) NOT NULL,
    "ips" CHAR(100) NOT NULL,
    FOREIGN KEY ("os") REFERENCES "OS" ("id")
);
CREATE TABLE "AgentsGroup"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "name" CHAR(255) NOT NULL
);
CREATE TABLE "User"(
    "id" INTEGER PRIMARY KEY NOT NULL,
    "name" VARCHAR(255) NOT NULL
);
CREATE TABLE "OrderType"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "name" CHAR(255) NOT NULL
);
CREATE TABLE "OrderToGroup"(
    "group" INTEGER NOT NULL,
    "order" INTEGER NOT NULL,
    FOREIGN KEY ("group") REFERENCES "AgentsGroup" ("id"),
    FOREIGN KEY ("order") REFERENCES "Order" ("id")
);
CREATE TABLE "UnionGroupAgent"(
    "agent" INTEGER NOT NULL,
    "group" INTEGER NOT NULL,
    "user" INTEGER NOT NULL,
    FOREIGN KEY ("agent") REFERENCES "Agent" ("id"),
    FOREIGN KEY ("group") REFERENCES "AgentsGroup" ("id"),
    FOREIGN KEY ("user") REFERENCES "User" ("id")
);
CREATE TABLE "OrderToAgent"(
    "agent" INTEGER NOT NULL,
    "order" INTEGER NOT NULL,
    FOREIGN KEY ("agent") REFERENCES "Agent" ("id"),
    FOREIGN KEY ("order") REFERENCES "Order" ("id")
);
CREATE TABLE "OS"(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "name" INTEGER NOT NULL
);

INSERT INTO "OS" ("name") VALUES ("Windows"), ("Linux"), ("Darwin");
INSERT INTO "AgentsGroup" ("name") VALUES ("Windows"), ("Linux"), ("Darwin");
INSERT INTO "OrderType" ("name") VALUES ("COMMAND"), ("UPLOAD"), ("DOWNLOAD");


