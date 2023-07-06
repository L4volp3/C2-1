#!/usr/bin/env python3
# -*- coding: utf-8 -*-

###################
#    Copyright (C) 2023  C2-EX-MACHINA

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
##################

"""
This script stores a new OrderInstance in C2-EX-MACHINA database.
"""

from argparse import ArgumentParser, Namespace
from collections import namedtuple
from typing import Set, Tuple
from datetime import datetime
from sqlite3 import connect
from sys import exit, argv
from os.path import join
from json import loads
from os import environ

OrderInstance = namedtuple(
    "OrderInstance",
    [
        "startDate",
        "user",
        "orderTargetType",
        "template",
    ],
)


def insert_order_instance(
    order_instance: OrderInstance, target_name: str, max_user_permission: int
) -> None:
    """
    This function inserts an OrderInstance into the database.
    """

    connection = connect(
        join(environ["WEBSCRIPTS_DATA_PATH"], "c2_ex_machina.db")
    )
    cursor = connection.cursor()
    cursor.execute(
        'INSERT INTO "OrderInstance" ("startDate", "user", "orderTargetType", "template") VALUES (?, (SELECT "id" FROM "User" WHERE "name" = ?), (SELECT CASE WHEN "Agent" = ? THEN 1 WHEN "Group" = ? THEN 0 END AS "TargetType"), (SELECT "id" FROM "OrderTemplate" WHERE "name" = ? AND "executePermission" <= ?));',
        (
            order_instance.startDate,
            order_instance.user,
            order_instance.orderTargetType,
            order_instance.orderTargetType,
            order_instance.template,
            max_user_permission,
        ),
    )
    if order_instance.orderTargetType == "GROUP":
        table_insert = "OrderToGroup"
        table_select = "AgentsGroup"
        column = "group"
    else:
        table_insert = "OrderToAgent"
        table_select = "Agent"
        column = "agent"
    cursor.execute(
        'INSERT INTO "'
        + table_insert
        + '" ("'
        + column
        + '","instance") VALUES ((SELECT "id" FROM "'
        + table_select
        + '" WHERE "name" = ?),last_insert_rowid());',
        (target_name,),
    )
    cursor.close()
    connection.close()


def get_targets_templates(
    max_privilege_level: int,
) -> Tuple[Set[str], Set[str]]:
    """
    This function returns targets and templates
    for your user permissions.
    """

    connection = connect(
        join(environ["WEBSCRIPTS_DATA_PATH"], "c2_ex_machina.db")
    )
    cursor = connection.cursor()
    cursor.execute(
        "SELECT name FROM OrderTemplate WHERE executePermission=?;",
        (max_privilege_level,),
    )
    order_template_names = {x[0] for x in cursor.fetchall()}
    cursor.execute(
        "SELECT name FROM Agent UNION SELECT name FROM AgentsGroup;"
    )
    target_names = {x[0] for x in cursor.fetchall()}
    cursor.close()
    connection.close()

    return target_names, order_template_names


def parse_args(max_privilege_level: int) -> Namespace:
    """
    This function parses the variables passed as arguments
    """

    order_template_names, target_names = get_targets_templates(
        max_privilege_level
    )

    parser = ArgumentParser(
        description=(
            "This script stores a new OrderInstance in C2-EX-MACHINA database."
        )
    )
    add_argument = parser.add_argument
    add_argument(
        "target-name",
        choices=target_names,
        help="The target name for the new task.",
    )
    add_argument(
        "order-template-name",
        choices=order_template_names,
        type=str,
        help="The order template name to performs on targets.",
    )
    add_argument(
        "target-type",
        choices={"Group", "Agent"},
        help="Target type (Group or Agent).",
    )

    add_argument(
        "--start-datetime",
        type=lambda x: datetime.strptime(x, "%Y-%m-%d %H:%M:%S"),
        help=("Time to start the tasks (format: YYYY-mm-dd HH:MM:SS)."),
    )

    return parser.parse_args()


def main() -> int:
    """
    This is the main function to starts the script from the command line.
    """

    max_user_permission = max(loads(environ["USER"])["groups"])

    if "--list" in argv:
        targets, templates = get_targets_templates(max_user_permission)
        print(
            "Targets:",
            "\t - " + "\n\t - ".join(repr(target) for target in targets),
            "Templates:",
            "\t - " + "\n\t - ".join(repr(template) for template in templates),
            sep="\n",
        )
        return 2

    arguments = parse_args(max_user_permission)
    order = OrderInstance(
        arguments.start_datetime,
        loads(environ["USER"])["name"],
        arguments.target_type,
        arguments.order_template_name,
    )

    insert_order_instance(order, arguments.target_name, max_user_permission)
    return 0


if "__name__" == "__main__":
    exit(main())
