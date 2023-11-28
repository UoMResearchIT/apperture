#!/bin/bash

# Read the RULES_ENTRY environment variable
RULES_ENTRY=${RULES_ENTRY:-"  # Default rules if RULES_ENTRY is not set"}

# Replace the placeholder in the template with the generated rules
sed -i "s|# This is a placeholder for dynamic access control rules|$RULES_ENTRY|" /etc/authelia/configuration.yml.template

# Rename the generated config file to the expected name
mv /etc/authelia/configuration.yml.template /etc/authelia/configuration.yml

# Start Authelia
exec "$@"
