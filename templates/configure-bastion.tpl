#!/bin/bash

# Create database extensions
# Note: this can be run as many times as needed, the CREATE command is ignored if the extension
#       already exists.

set -x


mkdir -p manifests/vault/
mkdir -p manifests/concourse/
mkdir -p manifests/cf/ops/
mkdir -p manifests/bosh/proto/
mkdir -p manifests/bosh/env/
mkdir -p manifests/autoscaler/
mkdir -p manifests/stratos/
mkdir -p manifests/shield/

## Install the Genesis and CF CLI
wget -q -O - https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key | sudo apt-key add -
echo "deb http://apt.starkandwayne.com stable main" | sudo tee /etc/apt/sources.list.d/starkandwayne.list

wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list

DEBIAN_FRONTEND=noninteractive sudo apt-get update

### Install JQ, crehub, and Make
# Install extra utilities. This will make bosh happy
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y git tmux tree pwgen unzip nmap build-essential ruby zlib1g-dev ruby-dev openssl libxslt1-dev libxml2-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 jq make genesis cf8-cli -y



wget https://github.com/cloudfoundry/credhub-cli/releases/download/2.9.3/credhub-linux-2.9.3.tgz
tar xvf credhub-linux-2.9.3.tgz
sudo chmod +x credhub
sudo cp credhub /usr/local/bin


wget wget https://github.com/concourse/concourse/releases/download/v7.7.1/fly-7.7.1-linux-amd64.tgz
tar xvf fly-7.7.1-linux-amd64.tgz
sudo chmod +x fly
sudo cp fly /usr/local/bin

git config --global user.name "Andrew Hartpence"
git config --global user.email "ahartpence@qarik.com"