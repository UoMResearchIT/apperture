# Adding and adminstering users

The administration of users in smalldata is handled by a service named LLDAP: Light LDAP (Lightweight Directory Access Protocol).

LDAP is a widely used technology for managing users and permissions. However, it is complex to configure and hard to administer. LLDAP provides a user friendly interface to a fairly standard LDAP implementation.

## Startup

When an instance of smalldata is first created, only one user will exist named `admin`.

### Authelia

To create new users, first you will need to pass the Authelia login screen.

For this you will need to use the username `admin` and randomly generated password contained in `./data/lldap/secrets/LLDAP_PASSWORD`.

### LLDAP

The same credentials will allow you to sign in at the ldap subdomain of your instance (e.g. https://ldap.smalldata.oms-lab.org/). Here you can create additional users, include with LLDAP admin rights (see the next section).

## Administration

The administration of LLDAP is performed through a web UI running on the 'ldap' subdomain of your smalldata instance.

If you have admin access (i.e. are a member of the lldap_admin group), you will be presented with a list of users, if you do not you will see only your own user details.

### Create admin

As either the base admin user, or as another admin, to create a new admin user:
- click 'Create a user'
- enter (at least) a username, email and password
- click submit
  
The user is now created, but not yet an admin. To grant admin rights:

- click the username of the new user
- under 'Group memberships', select 'lldap_admin' and click 'Add to group'
The new user is now an admin

### Create regular user

Creating a regular user follows the same process, but ommits adding the user to the 'lldap_admin' group. 

Therefore, as an admin user:

- click 'Create a user'
- enter (at least) a username, email and password
- click submit

### Change a user's password

To modify / reset a user's password, select their username from the main menu and click 'Modfiy password', following prompts from then on.

### Changing a user's group affiliation 

To add or remove users to groups two methods are possible. 

To administer per user:
- select the user's username
- add / remove groups under the 'Group membership' heading

To administer per group:
- select 'Groups' on the top bar
- click the group name you would like to administer
- add users using the dropdown box and 'Add to group'
- or, remove users using the red cross

### Remove a user

To remove a user, click the red cross on their entry on the 'user' tab

## Important notes

### Password policy

Password policies are not enforced by LLDAP and this feature does not appear to be planned.

Authelia may be able to enforce password policies, but this will not be reflected in the LLDAP UI and has not be demonstrated by smalldata as yet.

It is suggested that administrators bear this limitation in mind and work with their users to create a secure platform.

### Password distribution

When an admin creates a new user they must create a password for the user.

It is suggested that admin's create a randomly generated password (e.g. using https://bitwarden.com/password-generator/) which users treat as a one-time login and immediately change.
