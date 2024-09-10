# Apperture #

Apperture is a secure web portal for protecting web applications. It takes the form of a docker-compose configuration and is merely the combination of several excellent open source containers.

## Getting started

### Create env file

Copy the template file to the correct name (note leading .)

```shell
cp env.template .env
nano .env
```

Edit URL to your desired value.

```diff
- URL=foobar.org
+ URL=mylovelydomain.org
```

### Setup the environment and obtain admin credentials

```shell
./generate_passwords.sh
```

The script will print the LLDAP admin credentials, that you will need to setup users.

```shell
Generating ...
Generating ...
Generating ...

## Save these for later!! ##
LLDAP admin credentials:
  User: admin
  Pass: kGb6eX8M4oVjd2WeKzGaK3NYTyz29eLmqUvX78JqfTnev9cEQNG9yWsV2w4QfWs88yLxnvj9
```

**Securly save these credientials for later
** 
We suggest using a password manger. 

### Launch apperture

```shell
docker compose up
```

## Tutorial

## How to

### Configure the proxy

#### Setup your first route
Go to [localhost:81](localhost:81) and login with the default credentials: 
- admin@example.com
- changeme
  
Update the credentials to some that suit you.

Click on the menu "Hosts" and then "Proxy Hosts". Add a Proxy Host:
- Add a subdomain
  ```
  whoami.mylovelydomain.org
  ```
- set the Forward Hostname to
  ```
  apperture-whoami
  ```
- Use the port
  ```
  80
  ```

#### Setup Authelia
Add another proxy host:
- Add a subdomain:
  ```
  authelia.mylovelydomain.org
  ```
- Set the Forward Hostname to
  ```
  apperture-authelia
  ```
- Use the port
  ```9091```
- In the "Advanced" tab, paste:
    ```
    location / {
        include /snippets/proxy.conf;
        proxy_pass $forward_scheme://$server:$port;
    }
    ```
    
#### Protect the route
Click on the three vertical dots of the `whoami` route and click on "Edit".
In the "Advanced" tab, paste:
```
include /snippets/authelia-location.conf;
location / {
    include /snippets/proxy.conf;
    include /snippets/authelia-authrequest.conf;
    proxy_pass $forward_scheme://$server:$port;
}
```

#### Setup the user-admin site
Add another proxy host:
- Add a subdomain, for example
  ```
  users.mylovelydomain.org
  ```
- Set the Forward Hostname to
  ```
  apperture-ldap
  ```
- Use the port
  ```
  17170
  ```
- In the "Advanced" tab, paste:
    ```
    include /snippets/authelia-location.conf;
    location / {
        include /snippets/proxy.conf;
        include /snippets/authelia-authrequest.conf;
        proxy_pass $forward_scheme://$server:$port;
    }
    ```
Go to `users.mylovelydomain.org` and login with the LLDAP admin credentials.
Add a non-admin user.

### Use with cloudflare tunnels

#### Remove exposed ports 

Comment the exposed ports in the docker-compose file:
```diff
- - '80:80' # Public HTTP Port
- - '443:443' # Public HTTPS Port
+ # - '80:80' # Public HTTP Port
+ # - '443:443' # Public HTTPS Port

Now restart apperture:

```shell
docker compose down
docker compuse up
```

#### Set up tunnels on Cloudflare

```
- Login to cloudflare.
- On the side menu, select "Zero Trust".
- Create a team name and subscribe to the free plan
- Click on "Networks" and then "Tunnels".
- Click on "Add a Tunnel".
- Select cloudflared as the connector.
- Choose a name for the tunnel, and save it.
- Click on your tunnel.
- Click on "Configure".
- In "Choose your environment", select "Docker".
- Copy the code in the "Install and run a connector" box. It includes the token after the flag `--token`.
```

Now save the token into a file `config/cloudflared/.secret_token` in your project.

The file should look like this:
```
TUNNEL_TOKEN=your_token
```

Add the cloudflared service to your docker-compose file.
A standard configuration would look like this:
```
services:

  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: mylovelyproject-cloudflared
    restart: unless-stopped
    env_file:
      - ./config/cloudflared/.secret_token
    command:
      tunnel --no-autoupdate run
    networks:
      apperture:
```

You can now launch the cloudflared service with `docker-compose up -d cloudflared`.

**Note**: Each domain you add to cloudflare also needs to be added in the proxy, and protected in the "Advanced" tab (See the [Protect the Route](#protect-the-route) section).

#### Add hostnames

You will now be able to add Public Hostnames.
Using your domain (`mylovelydomain.org`), add the subdomains necessary for apperture (see the [Configure the proxy](#configure-the-proxy) section):
- `whoami`
- `authelia`
- `users`
In all three cases, make sure you select `http` for the type, and `apperture-proxy` for the url. You may leave the path empty.


## Explaination

## Reference
