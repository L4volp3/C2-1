-- Get Agents in a group
SELECT "name", "os", "ips", "group", "description", "user"
FROM "Groups"
WHERE "Groups"."group" = ?;

-- Get all Orders Instances
SELECT
    "task",
    "description",
    "data",
    "creation",
    "orderType",
    "userCreation",
    "readPermission",
    "executePermission",
    "userExecution",
    "start",
    "requirementTask"
FROM "Orders";

-- Get Orders Instance with Agent
SELECT "task", "agent", "description", "data", "start", "user", "ips", "os"
FROM "AgentOrders";

-- Get Orders Instance by matching Agent
SELECT "task", "agent", "description", "data", "start", "user", "ips", "os"
FROM "AgentOrders"
WHERE "agent" LIKE '%?%';

-- Get Orders Instance with Group
SELECT "task", "group", "groupDescription", "taskDescription", "data", "start", "user"
FROM "GroupOrders";

-- Get Orders Instance by matching Group
SELECT "task", "group", "groupDescription", "description", "data", "start", "user"
FROM "GroupOrders"
WHERE "group" LIKE '%?%';

-- Get Agents by matching Task
SELECT "task", "agent", "description", "data", "start", "user", "ips", "os"
FROM "AgentOrders"
WHERE "task" LIKE '%?%';

-- Get Groups by matching Task
SELECT "task", "group", "groupDescription", "description", "data", "start", "user"
FROM "GroupOrders"
WHERE "task" LIKE '%?%';

-- List Agents
SELECT "Agent"."name" AS "name", "OS"."name" AS "os", "Agent"."ips" AS "ips"
FROM "Agent"
INNER JOIN "OS" ON "OS"."id" = "Agent"."os";

-- List Groups
SELECT "name", "description" FROM "AgentsGroup";

-- List users
SELECT "name" FROM "User";

-- Get tasks launched by a user
SELECT
    "task",
    "description",
    "data",
    "start"
FROM "Orders"
WHERE "userExecution" = ?;

-- Get tasks created by a user
SELECT
    "OrderTemplate"."name" AS "task",
    "OrderTemplate"."description" AS "description",
    "OrderTemplate"."data" AS "data",
    "OrderTemplate"."readPermission" AS "readPermission",
    "OrderTemplate"."executePermission" AS "executePermission"
FROM "OrderTemplate"
INNER JOIN "User" ON "User"."id" = "OrderTemplate"."user"
WHERE "User"."name" = ?;

-- List Tasks by matching Group
SELECT "group", "groupDescription", "task", "taskDescription", "data", "start", "user"
FROM "GroupTasks";

-- List Tasks by matching Group
SELECT "group", "groupDescription", "task", "taskDescription", "data", "start", "user"
FROM "GroupTasks"
WHERE "group" LIKE '%?%';
