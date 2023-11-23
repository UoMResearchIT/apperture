# Casbin

Casbin's behaviour is dominated by three major components:
- Models
- Policies
- Groups

Of course, the fullest and most complete details of Casbin is given in [their documentation](https://casbin.org/docs/overview). 

However, this document will describe each of the Casbin elements in some detail, and the effect they have on the behaviour of smalldata, through the lense of the Casbin Model definition.

## Model

Casbin Models define the stucture of requests, the stucture of policies and how they are imlemented. 

The Casbin model used in smalldata is found at `data/casbin/config/model.conf.

This file is reproduced here in sections for annotation:

### Request definition

```
[request_definition]
r = sub, dom, obj, act
```
This section creates the structure of the expected request, in smalldata the fields have the following meanings:
- sub (subject) : the user making the request
- dom (domain) : the table being requested
- obj (object) : the column being requested
- act (action) : the endpoint being requested

### Policy definition

```
[policy_definition]
p = sub, dom, obj, act
```
This section defines the structure of the policies implemented by Casbin. [For example](https://github.com/p-parkinson/smalldata_io/blob/9395b3580197fbcffdd0d5e4edec13ab773dc3af/smalldata_io_server/API_server.py#L67), in smalldata one policy reads:

```
"INSERTER * * (insert)|(get)"
```

This should be read as: An INSERTER may _insert_ or _get_ on any (\*) table or (\*) column.

It should be noted that these are user _roles_ not users! A user is assigned a role per table and per column.

### Role definition

```
[role_definition]
g = _, _, _
```

From [Casbin](https://casbin.org/docs/understanding-casbin-detail#the-model-definition-1): "The role_definition is a graph relation builder that uses a Graph to compare the request object with the policy object."

These are used to map between users and roles. [For example](https://github.com/p-parkinson/smalldata_io/blob/9395b3580197fbcffdd0d5e4edec13ab773dc3af/smalldata_io_server/API_server.py#L167), in smalldata, the follwing grouping policy can be found:

```python
enforcer.add_grouping_policy(account_id, "OWNER", str(table.id))
```

This creates a group similar to:

"a_user, OWNER, 123"

Which should be read as "a_user is an OWNER of table 123".

### Policy effect

```
[policy_effect]
e = some(where (p.eft == allow))
```

Of limited relevance to smalldata, the policy effect definition controls the behaviour of Casbin when multiple matchers are specified.

### Matchers

```
[matchers]
m = (r.act == "create")
|| ((r.act == "insert") && g(r.sub, p.sub, r.obj) && g(r.sub, p.sub, r.dom)) \ 
|| (g(r.sub, p.sub, r.dom) && keyMatch(r.dom, p.dom) && keyMatch(r.obj, p.obj) && regexMatch(r.act, p.act)) 
```

Matchers define the logic used when requests are submitted. The prefix `r` denotes the request object, `p` policies.

The above is a series of three potential match conditions (boolean OR), which will be disected individually here:

#### Automatic approval
```
m = (r.act == "create")
```

If the request's acation is create, approve.

#### Column and table approval

```
((r.act == "insert") && g(r.sub, p.sub, r.obj) && g(r.sub, p.sub, r.dom))
```

If an insert action is requested, check that the request user (r.sub), owns a policy (p.sub) that matches the requested column (r.obj) AND owns a policy (p.sub) that matches the requested table (r.dom), approve.

#### Table only approval

```
(g(r.sub, p.sub, r.dom) && keyMatch(r.dom, p.dom) && keyMatch(r.obj, p.obj) && regexMatch(r.act, p.act)) 
```

For any other action, check that the requesting user (r.sub) has a policy (p.sub) which allows them to perform matching actions (r.act, p.act) on the requested table (r.dom), approve. 

n.b. for table only approval a wildcard is used for both the request (r.obj) and policy (p.obj) columns.
