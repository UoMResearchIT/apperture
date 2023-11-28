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
    echo Generating $file
    tr -cd '[:alnum:]' < /dev/urandom | fold -w "64" | head -n 1 > $file
done
