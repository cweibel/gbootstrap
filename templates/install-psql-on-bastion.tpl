#!/bin/bash

# Create database extensions
# Note: this can be run as many times as needed, the CREATE command is ignored if the extension
#       already exists.

set -x

# Install psql client
sudo apt-get --yes --force-yes install curl ca-certificates
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
DEBIAN_FRONTEND=noninteractive sudo apt-get --yes --force-yes update
DEBIAN_FRONTEND=noninteractive sudo apt-get --yes --force-yes install postgresql-client-14 || /bin/true 
