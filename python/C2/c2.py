"""
This WebScripts module is used to send order to C2-EX-MACHINA client/agent.
"""

from json import dumps
from os import _Environ
from collections import namedtuple
from collections.abc import Callable
from typing import Dict, Union, TypeVar, List, Tuple, Iterable

Server = TypeVar("Server")
User = TypeVar("User")
Task = namedtuple('Task', [
    'type',
    'user',
    'description',
    'data',
    'timestamp',
    'id',
    'after',
])

def check_is_agent(environ: _Environ) -> bool:
    """
    This function checks the client is a C2-EX-MACHINA agent using User-Agent.
    """

    return environ["HTTP_USER_AGENT"].strip().startswith("Agent-C2-EX-MACHINA")


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

def build_dict(agent_id: str) -> Dict[str, Union[str, Dict[str, str]]]:
    """
    This function is building a dict from data
    """
    
    next_request_time = datetime.now() + timedelta(minutes=5)
    # TODO: configurable time
    
    tasks = ...
    api_webscript = { 
        "NextRequestTime": next_request_time.strftime(
            "%Y-%m-%d%H:%M:%S"
        ),
        "Tasks": [{
            "Type": api.type,
            "User": api.user,
            "Description": api.description,
            "Data": api.data,
            "Timestamp": api.timestamp,
            "Id": api.id,
            "After": api.after,       
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

    data = build_dict(agent_id)
    is_agent = check_is_agent(environ, agent_id)
    return (
        "200 OK",
        {},
        encode_data(dumps if is_agent else malware_encode, data),
    )
