#!/bin/bash

set -x

echo "Retrieving shield cli..."
wget https://github.com/starkandwayne/shield/releases/download/v${shield_binary_version}/shield-linux-amd64

sudo mv shield-linux-amd64 /usr/local/bin/shield   #some system path
sudo chmod +x /usr/local/bin/shield
shield api https://${shield_ip} ${shield_environment} -k
shield login -c ${shield_environment} -u ${web_username} -p ${web_password}

echo "Writing shield_master.key file to disk..."
shield -c ${shield_environment} init --master ${master_password} >> /home/${admin_username}/shield_master.key  
shield -c ${shield_environment} unlock --master ${master_password} 

