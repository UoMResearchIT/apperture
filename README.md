# Apperture #

Apperture is a secure web portal for protecting web applications. It takes the form of a docker-compose configuration and is merely the combination of several excellent open source containers.

## Docs

### Getting started

#### Create env file

Copy the template file to the correct name (note leading .)

```shell
cp env.template .env
nano .env
```

Edit URL to your desired value.

```diff
- URL=foobar.org
+ URL=my.lovelydomain.org
```

#### Generate secrets

```shell
./generate_passwords.sh
```

#### Launch apperture

```shell
docker compose up
```

### Tutorial

### How to

### Explaination

### Reference
