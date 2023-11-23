# Configuring Authelia

To change the behaviour of Authelia, envirnoment variables can be set in the Docker Compose configuration.

First, the server must be taken down:

```console
docker compose down
```

n.b. This will remove any non-persistent data, however, smalldata is configured to retail all important information.

The configuration file may then be edited.

## Docker compose file

[This configuration file](docker-composey.yml) controls the behaviour of Authelia (and smalldata more widely).

To reconfigure authelia:
- locate the service named 'Authelia'
- locate the 'environment' section
- change the desired variables

The variables shown in this section are a subset of [those available](https://www.authelia.com/configuration/methods/environment/#environment-variables), users may add and reconfigure variables from the reference, at their own risk.

The behaviour, valid inputs and general discussion of the environment variables can be found throughout Authelia's documentation. For example, for controlling the behaviour of the fail2ban services (which bans acounts if brute force attacks are detected) this [document](https://www.authelia.com/configuration/security/regulation/) details the parameters and their options.
