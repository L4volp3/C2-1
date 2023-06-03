#!/usr/bin/env python3
# -*- coding: utf-8 -*-

###################
#    This tool is a secure C2 working in WebScripts
#    environment for SOC and Blue Team automations
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
###################

"""
This WebScripts module is used to send order to C2-EX-MACHINA client/agent.
"""

__version__ = "0.0.1"
__author__ = "KrysCat-KitKat, C2-EX-MACHINA"
__author_email__ = "c2-ex-machina@proton.me"
__maintainer__ = "KrysCat-KitKat, C2-EX-MACHINA"
__maintainer_email__ = "c2-ex-machina@proton.me"
__description__ = """
This tool is a secure C2 working in WebScripts environment
for SOC and Blue Team automations
"""
license = "GPL-3.0 License"
__url__ = "https://github.com/C2-EX-MACHINA/Agent/"

copyright = """
WebScripts  Copyright (C) 2023  C2-EX-MACHINA
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it
under certain conditions.
"""
__license__ = license
__copyright__ = copyright

__all__ = ["order"]

print(copyright)

from time import time
from json import dumps
from os import _Environ
from os.path import join
from collections import namedtuple
from collections.abc import Callable
from typing import Dict, Union, TypeVar, List, Tuple, Iterable

Server = TypeVar("Server")
User = TypeVar("User")
Task = namedtuple('Task', [
    'type',
    'user',
    'name',
    'description',
    'data',
    'filename',
    'timestamp',
    'id',
    'after',
])

def get_tasks_by_agent(environ: _Environ, key: str, hostname: str) -> List[Task]:
    """
    This function performs SQL requests to check
    agent key/hostname and to get tasks for the agent.
    """

    connection = connect(join(environ["WEBSCRIPTS_DATA_PATH"], "c2_ex_machina.db"))
    cursor = connection.cursor()
    cursor.execute('SELECT "id" FROM "Agent" WHERE "name" = ? AND "key" = ?;', hostname, key)
    if not cursor.fetchone():
        return None
    cursor.execute('SELECT * FROM InstancesToAgents WHERE "agent" = ?;', hostname)
    orders = cursor.fetchall()
    cursor.close()
    connection.close()
    return [Task(*order) for order in orders]

def check_is_agent(environ: _Environ) -> bool:
    """
    This function checks the client is a C2-EX-MACHINA agent using User-Agent.
    """

    return environ["HTTP_USER_AGENT"].strip().startswith("Agent-C2-EX-MACHINA ")


def encode_data(
    encoding: Callable, data: Dict[str, Union[str, Dict[str, str]]]
) -> str:
    """
    This function encodes data to
    """

    return encoding(data)


def malware_encode(data: Dict[str, Union[str, Dict[str, str]]]) -> str:
    """
    This function encodes response object for Malware Order API.
    """

    raise NotImplemented

def get_orders(environ: _Environ, next_request_time: int, agent_id: str, hostname: str) -> Dict[str, Union[str, Dict[str, str]]]:
    """
    This function returns formatted orders for an agent.
    """
    
    tasks = get_tasks_by_agent(environ, agent_id, hostname)

    if tasks is None:
        return None

    api_webscript = { 
        "NextRequestTime": time() + next_request_time,
        "Tasks": [{
            "Type": task.type,
            "User": task.user,
            "Description": task.description,
            "Data": task.data,
            "Timestamp": task.timestamp,
            "Id": task.id,
            "After": task.after,       
        } for task in tasks]
    }

    return api_webscript

def order(
    environ: _Environ,
    user: User,
    server: Server,
    agent_id: str,
    arguments: Dict[str, Dict[str, str]],
    inputs: List[str],
    csrf_token: str = None,
) -> Tuple[str, Dict[str, str], Union[str, Iterable[bytes]]]:
    """
    This function generates and returns response for Agent Order API.
    """

    user_agent = environ["HTTP_USER_AGENT"]
    user_agent_split = user_agent.split()
    if not user_agent.get("Agent-C2-EX-MACHINA ") or len(user_agent_split) != 4:
        return (
            "403",
            {},
            b"",
        )

    data = get_orders(environ, getattr(server.configuration, "c2_next_request_time", 300), agent_id, user_agent_split[-1])
    if data is None:
        return (
            "403",
            {},
            b"",
        )

    is_agent = check_is_agent(environ, agent_id)
    return (
        "200 OK",
        {},
        encode_data(dumps if is_agent else malware_encode, data),
    )
