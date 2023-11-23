# Deploy smalldata

This guide will walk you through the creation of a new smalldata instance.

## Caveat

For demonstration purposes, this guide will show how to deploy smalldata with a [duckns](https://www.duckdns.org/) URL. This will allow us to quickly and easily set up an https connection, with appropriate routing. However, this approach **should not be used in production**. The aquisition of SSL certificates and creation of DNS entries is left to the discresion and preference of the user deploying smalldata. 

Significantly, smalldata utilises the [SWAG](https://docs.linuxserver.io/general/swag/) container provided by [linuxserver](https://www.linuxserver.io/). Their documentation details how various approchaes to certifiates and hosting may be made. The creators of smalldata are unable to recommend a particular approach as the best fit will depend on local conditions.

## Assumptions

This guide assumes installation on a Linux server and is overwhelmingly commandline based. It will be possible to deploy smalldata on other platforms and with other tools, but these are beyond the scope of this guide.

## Prerequisates

To install smalldata you will need:
- Functioning docker installation (see [here](https://docs.docker.com/engine/install/) for an official guide)
- Registered on [duckdns](https://www.duckdns.org/) and created a user token

## Starting out

Let's get started! To begin we need to aquire the smalldata source code.

### Clone the smalldata repository 

The first deployment set is to obtain the smalldata source code. This can be peformed with (e.g.):

```console
git clone git@github.com:p-parkinson/smalldata_io.git
```

You should now navidate to the smalldata source directory

```console
cd smalldata_io
```
### Configure the environment

#### Docker environment

First, create a copy of the template environment (named .env):

```console
cp .env.template .env
```

Please note, the leading '.' is essential.

Next, edit the file using an editor of your choice (e.g.):

```console
nano .env
```

Now, populate the file, there are three variables to set.

| Var | Example | Description |
| --- | --- | --- |
| DUCKDNS_TOKEN | TOKEN-WITH-SPECIALCHARS | Your duckdns token, taken from the web UI |
| URL | your.url.org | This should be your desired URL, for this guide it should look something like my_smalldata.duckdns.org |
| EMAIL | email.for.sslcert@example.org | This should be your regular email, which will be used to create a [zerossl](https://app.zerossl.com/) account |

#### Generate random passwords

A helper script is provided to produce random passwords for securing various servers which comprise the smalldata ecosystem.

To run the tools:

```console
./generate_passwords.sh
```

#### Perform additional configuration

Unfortunately, some configuration cannot be done through the .env file. These changes will be described as diffs.

First, `data/swag/config/snippets/authrequest.conf` should be edited:

```diff
-error_page 401 =302 https://authelia.smalldataio.duckdns.org;
+error_page 401 =302 https://authelia.your.url.org;
```

Next, `data/authelia/config/configuration.yml`:

```diff
   rules:
     - domain:
-      - smalldataio.duckdns.org
-      - "*.smalldataio.duckdns.org"
+      - your.url.org
+      - "*.your.url.org"
       policy: one_factor
       
 session:
   name: authelia_session
-  domain: smalldataio.duckdns.org
+  domain: your.url.org
   same_site: lax  
```

Next, `smalldata_io_ui/app.py`:

```diff
 # Connect to smalldata
-client = Smalldata("smalldataio.duckdns.org")
+client = Smalldata("your.url.org")

 # -----------------------------------------------------------------------------
 # Table fetch 
 
 st.header("Your tables:")
 
-response = requests.get('https://api.smalldataio.duckdns.org/list_tables',
+response = requests.get('https://api.your.url.org/list_tables',
                         cookies=authelia_cookie
                         )
```

Finally, `docker-compose.yml`:

```diff
       # General
-      AUTHELIA_DEFAULT_REDIRECTION_URL: https://whoami.smalldataio.duckdns.org/
+      AUTHELIA_DEFAULT_REDIRECTION_URL: https://ui.your.url.org
```

### Deploy smalldata

We can now begin bringing smalldata up! First, containers must be built:

```console
docker compose build
```

When the build has finished, we can bring the services up:

```console
docker compose up
```

It will take several minutes for smalldata to spin up, including a 60 second pause during which there will be no output.

### Add IP address to duckdns

Now you can add your smalldata instance to duckdns.

Go to their web interface, add the IP address of the machine smalldata is deployed on and the URL you entered in the .env file.

### Detach

If you are happy with your deployment you can now cancel `docker compose up` to run the service in the background:

```console
docker compose up -d
```
