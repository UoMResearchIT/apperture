#!/usr/bin/env bash

pass_files=("config/lldap/secrets/LLDAP_JWT_SECRET" \
            "config/lldap/secrets/LLDAP_PASSWORD" \
            "config/lldap/secrets/LLDAP_STORAGE_PASSWORD" \
            "config/authelia/secrets/AUTHELIA_JWT_SECRET" \
            "config/authelia/secrets/AUTHELIA_SESSION_SECRET" \
            "config/authelia/secrets/AUTHELIA_STORAGE_ENCRYPTION_KEY" \
            "config/authelia/secrets/AUTHELIA_STORAGE_PASSWORD" \
            "config/casbin/secrets/CASBIN_STORAGE_PASSWORD" \
           )

for file in ${pass_files[@]}
do
    # only generate passwords if the files do not exist
    if [ ! -f $file ]; then
        echo Generating $file
        tr -cd '[:alnum:]' < /dev/urandom | fold -w "64" | head -n 1 > $file
    else
        echo Skipping $file - it already exists
    fi
done

# Echo the lldap password to the console

echo "
 LLDAP admin credentials:
  User: admin
  Pass: $(cat config/lldap/secrets/LLDAP_PASSWORD)
"

# replace $URL in config/authelia/snippets/authelia-authrequest.conf with the URL stored in the .env file
sed "s|\$URL|$(grep URL .env | cut -d '=' -f2)|g" \
    config/authelia/snippets/authelia-authrequest.conf.template \
    > config/authelia/snippets/authelia-authrequest.conf
