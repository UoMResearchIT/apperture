# Structure of Smalldata

This document will outline the structure of containers within smalldata, with a particular focus on authentication and authorisation.

We will start with a couple of definitions:
- **Authentication**: Checking user credientials against a managed list of accounts. `Is sirUserLot a valid smalldata user?`
- **Authorisation**: Checking user privileges for specific resources. `Is sirUserLot allowed to access this table?`

In smalldata:
- Authentication is imlemented using [Authelia](https://www.authelia.com/), a portal which allows users to sign in to access protected services.
- Authorisation is implemented using [Casbin](https://casbin.org/), a library which allows developes to specify access rules and roles for resources.

## Overview

Below is a diagram of the container structure of smalldata. 

- A user's request passes left to right
- Vertical slices are layers of access with incresing privilege from left to right
- If the request is successful, the requested data is passed from right to left
  
These layers will be discussed below:

![Smalldata_io-Authentication drawio (4)](https://github.com/p-parkinson/smalldata_io/assets/86293426/971fe904-2573-4b74-b23a-bb3ce65198aa)

## User layer

This layer is the outer surface of smalldata, users may make requests through one of the distributed clients or raw API calls, through a browser or through an automated system. Regardless of the approach, their traffic is directed through the authentication layer.

## Authentication

The Authentication layer contains the only publicly exposed surface of smalldata, the [SWAG container](https://docs.linuxserver.io/general/swag/). This container contains an Nginx reverse proxy, responsible for forwarding a user's traffic to the requested service (in addition to securing the connection, obtaining and using SSL certificates). 

The SWAG container has been extended to protect its servies with Authelia. As such, no traffic will be passed to any endpoint without first being authenticated using Authelia. 

Authelia occupies it's own container and provides services which are accessed using API calls within the smalldata architecture - see, for example, [here](https://authelia.smalldata.oms-lab.org/api/) for API documentation.

Authelia (in this configuration) does not hold its own list of users, this is instead implemented using another service, [LLDAP](https://github.com/lldap/lldap) a simple (to use) implementation of [LDAP](https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol) which associates users with groups and provides services like user management and password changes.

LLDAP does not directly store a list of users either, instead storing the users and groups in an Postgres database.

## Priviledged Applications

Behind the Authentication layer (i.e. accessible to logged in users) sits a simple Work-In-Progress web UI for smalldata. There is no need for a user to provide further authentication to access smalldata, their authentication is propagated. 

## Authorisation

Authenticated traffic is further checked when it reaches the authorisation layer. A full explanation of the behaviour of this layer is given [here](docs/explanation/casbin.md), but for this document it suffices to say that this layer is where a user's right to perform a certain action on a certain resource is checked. These policies are stored in a postgres database.

If a user does not have sufficient rights, their request is rejected, otherwise it is passed to the smalldata API.

## Smalldata

The inner layer of the stucture is smalldata itself, providing the advertised functionality and access to the underlying database. 
