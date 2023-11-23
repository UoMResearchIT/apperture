# Casbin reconfiguration

The Casbin configuration is dominated by three major aspects:
- The modelhttps://github.com/p-parkinson/smalldata_io/blob/9395b3580197fbcffdd0d5e4edec13ab773dc3af/smalldata_io_server/API_server.py#L67
- The policies
- The groups

For a full explanation see [this discussion](docs/explanation/casbin.md "casbin"). This document focuses on the mechanics of changing the behaviour.

## Model

The model definition can be found at [this location](data/casbin/config/model.conf).

To change the behaviour, smalldata must be rebuilt.

```console
docker-compose -f docker-compose.yml down
nano ./data/casbin/config/model.conf
docker-compose build
docker-compose -f docker-compose.yml up
```

## Policies

Policies are set in the Smalldata API source code [beginning here](https://github.com/p-parkinson/smalldata_io/blob/9395b3580197fbcffdd0d5e4edec13ab773dc3af/smalldata_io_server/API_server.py#L67).

The policies are set as an array of arrays:

```
default_policies = [
    ["OWNER", "*", "*", "(modify)|(add)|(insert)|(get)"],
    ["ADDER", "*", "*", "(add)|(insert)|(get)"],
    ["INSERTER", "*", "*", "(insert)|(get)"],
    ["GETTER", "*", "*", "(get)"]
    ]
```

With individual policies evaluating as string delimited, concatenated strings. 

For example:

```
["OWNER", "*", "*", "(modify)|(add)|(insert)|(get)"],
# becomes
"OWNER, *, *, (modify)|(add)|(insert)|(get)"
```

## Groups

Groups are added when needed to link users to roles. This occurs sporacicaly around the smalldata API source code, one example is [here](https://github.com/p-parkinson/smalldata_io/blob/9395b3580197fbcffdd0d5e4edec13ab773dc3af/smalldata_io_server/API_server.py#L167).

Where the line:

```
enforcer.add_grouping_policy(account_id, "OWNER", str(table.id))
# becomes
"account_id, OWNER, table.id"
```
