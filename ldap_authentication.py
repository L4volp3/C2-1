import ldap
from argparse import ArgumentParser
from os import environ
from json import dumps
from sys import stderr, exit

# get the groups the user is a member of and their ids
def get_user_groups(ldap_client, user_attributes):
    # get the groups the user is a member of
    groups_dns = user_attributes.get("memberOf", [])[0]
    groups_ids = []
    for group_dn in groups_dns:
        group_attributes = ldap_client.search_s(group_dn, ldap.SCOPE_BASE)
        group_id = group_attributes.get("cn", [None])[0]
        if group_id:
            groups_ids.append(group_id)
    return groups_ids


def user_authentication(ldap_client, username):
    # Specify the search base
    search_base = (
        "dc=C2-EX-MACHINA, dc=com, ou=users"  # Depends on how our ldap tree will be
    )
    # Specify the filter
    search_filter = f"(uid={username})"
    # Search fo the user
    try:
        result = ldap_client.search_s(search_base, ldap.SCOPE_SUBTREE, search_filter)
    except ldap.LDAPError as e:
        return None, f"LDAP error:{e}"

    if result:
        # get the first result (there should only be one)
        _, user_attributes = result[0]
        # get the user ip
        user_ip = user_attributes.get("ip",[None])[0]
        # get the user ID
        user_id = user_attributes.get("uid", [None])[0]
        groups_id = get_user_groups(ldap_client, user_attributes)
        # get the user permissions
        user_permissions = {
            "categories": user_attributes.get("categories", []),
            "scripts": user_attributes.get("scripts", []),
        }

        return {
            "ip": user_ip,
            "id": user_id,
            "name": username,
            "groups": groups_id,
            "categories": user_permissions["categories"],
            "scripts": user_permissions["scripts"],
        }
    else:
        ip = (
            environ.get("X_REAL_IP")
            or environ.get("X_FORWARDED_FOR")
            or environ.get("X_FORWARDED_HOST")
            or environ["REMOTE_ADDR"]
        )
        return {
            "id": "0",
            "name": "Not Authenticated",
            "ip": ip,
            "groups": "0",
            "categories": ["*"],
            "scripts": ["*"],
        }


def main()-> int:
    parser = ArgumentParser(description="Authenticates to the C2 ldap server .....")
    parser.add_argument("-u", "--username")
    parser.add_argument("-p", "--password")

    args = parser.parse_args()
    username = args.username
    password = args.password

    # Creates an LDAP client instance
    try:
        ldap_server = "ldapC2.com"  # (à définir)
        ldap_client = ldap.initialize(ldap_server)
        ldap_client.protocol_version = ldap.VERSION3
    except ldap.LDAPException as e:
        print(f"LDAP error:{e}", file=stderr)

    # Binds the LDAP client with the username and password
    try:
        ldap_client.bind(username, password)
    except ldap.INVALID_CREDENTIALS:
        print("Invalid username or password",file=stderr)
        return 2

    result = user_authentication(ldap_client, username, password)
    print(dumps(result))
    return 0

if "__name__" == "__main__":
    exit(main())
