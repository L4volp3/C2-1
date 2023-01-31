from json import dumps

def check_is_agent(environ, agent_id) -> bool:
    ...
    if ...: is_agent = True
    elif ...: is_agent = False

    return is_agent

# (environ, user, configuration, agent_id, arguments, inputs, csrf_token=None)
def encode_data(encoding:callable, data:tuple) -> tuple: 
    ...
    return encoding(data)

def order(environ, user, configuration, agent_id, arguments, inputs, csrf_token=None):
    data = ...
    is_agent = check_is_agent(environ, agent_id)
    return "200 OK", {}, encode_data(dumps if is_agent else ..., data)

