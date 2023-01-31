from json import dumps
from os import _Environ

def check_is_agent(environ: _Environt) -> bool:
    
    """
    This function checks the client is a C2-EX-MACHINA agent using User-Agent.
    """
    
    return environ["HTTP_USER_AGENT"].strip().startswith("Agent-C2-EX-MACHINA")

def encode_data(encoding:callable, data:tuple) -> tuple: 
    ...
    return encoding(data)

def order(environ, user, configuration, agent_id, arguments, inputs, csrf_token=None):
    data = ...
    is_agent = check_is_agent(environ, agent_id)
    return "200 OK", {}, encode_data(dumps if is_agent else ..., data)

