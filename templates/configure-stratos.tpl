cf create-space stratos -o system
cf target -o system -s stratos
cf cups console_db_tls_verify_ca  -p '{"uri": "postgres://", "username":"${stratos_db_username}", "password":"${stratos_db_password}", "hostname":"${stratos_db_host}", "port":"5432", "dbname":"console_db", "sslmode":"verify-ca" }'


mkdir ~/stratos-precompiled
cd ~/stratos-precompiled
wget https://github.com/orange-cloudfoundry/stratos-ui-cf-packager/releases/download/4.4.0/stratos-ui-packaged.zip
unzip stratos-ui-packaged.zip

#Need to copy in stratos-app-manifest.yml rendered template 
cp ~/manifests/stratos/manifest.yml .


# which needs to pull a value from credhub
STRATOS_CLIENT_SECRET=$(credhub get -n /dev-bosh/dev-cf/stratos_client_secret -j | jq -r .value)


sed -i -e "s/stratos_client_secret_goes_here/$STRATOS_CLIENT_SECRET/g" manifest.yml


cf push -f manifest.yml