# !/usr/bin/env python3
# -*- coding: utf-8 -*-

###################
#    Copyright (C) 2023  Black-pearl2498

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
This module parses arguments and return them as a NamedTuple which is used as an argument in the function insert_order_instance()
"""
from ... import insert_order_template
from argparse import ArgumentParser
from collections import namedtuple
from typing import NamedTuple
from json import loads
from os import environ
from sys import exit


# Creates a named tuple with the parsed arguments
OrderTemplate = namedtuple(
    "OrderTemplate",
    [
        "type",
        "data",
        "readpermission",
        "executepermission",
        "after",
        "name",
        "description",
    ],
)


def parse_args() -> NamedTuple:
    """
    This function parses the variables passed as arguments
    """
    parser = ArgumentParser(description="Argument parser")
    add_argument = parser.add_argument
    add_argument(
        "--type",
        choices=["COMMAND", "UPLOAD", "DOWNLOAD"],
        required=True,
        help="Type of operation",
    )
    add_argument(
        "--data", type=str, required=True, help="Path to a file or a command to execute"
    )
    add_argument(
        "--readpermission",
        default=max(loads(environ["USER"])["groups"]),
        type=int,
        help="Read permission",
    )
    add_argument("--executepremission", type=int, help="Execute permission")
    add_argument(
        "--after",
        type=str,
        help="Order Id or null, to execute this order after any precedent order",
    )
    add_argument("--name", type=str, required=True, help="Name")
    add_argument("--description", type=str, resuired=True, help="Description")

    return parser.parse_args()


def main() -> int:
    """
    This function creates an UserTuple instance an pass it as an argument for the the insert_order_instance() function
    """
    arguments = parse_args()
    order = OrderTemplate(
        arguments.type,
        arguments.data,
        arguments.readpermission,
        arguments.executepermission,
        arguments.after,
        arguments.name,
        arguments.description,
    )

    insert_order_template(order)
    return 0


if "__name__" == "__main__":
    exit(main())
