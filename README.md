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

### Setup the environment

```shell
./generate_passwords.sh
```

### Launch apperture

```shell
docker compose up
```

## Tutorial

## How to

### Configure the proxy

#### Setup a route
Go to `localhost:81` and login with the default credentials (admin@example.org and changeme).
Update theadmin credentials
Click on the menu "Hosts" and then "Proxy Hosts". Add a Proxy Host:
- Add a subdomain, e.g. `whoami.mylovelydomain.org`
- set the Forward Hostname to `apperture-whoami`
- Use the port `80`.

#### Setup Authelia
Add another proxy host:
- Add a subdomain: `authelia.mylovelydomain.org` (this has to be `authelia`).
- Set the Forward Hostname to `apperture-authelia`
- Use the port `9091`.
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


## Explaination

## Reference
