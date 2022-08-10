#!/bin/bash

# Create database extensions
# Note: this can be run as many times as needed, the CREATE command is ignored if the extension
#       already exists.

set -x

################
## Proto Bosh ##
################

safe set /secret/${proto_bosh_name}/bosh/external-db/bosh_user password=${bosh_rds_password}
safe set /secret/${proto_bosh_name}/bosh/external-db/credhub_user password=${credhub_rds_password}
safe set /secret/${proto_bosh_name}/bosh/external-db/uaa_user password=${uaa_rds_password}

safe set /secret/${proto_bosh_name}/bosh/blobstore/s3 access_key=${aws_access_key_s3}
safe set /secret/${proto_bosh_name}/bosh/blobstore/s3 secret_key=${aws_secret_key_s3}

safe set /secret/${proto_bosh_name}/bosh/aws access_key=${aws_access_key_bosh}
safe set /secret/${proto_bosh_name}/bosh/aws secret_key=${aws_secret_key_bosh}

safe gen  -l 64 /secret/${proto_bosh_name}/bosh/db password

###############
## Env Bosh ###
###############

safe set /secret/${env_bosh_name}/bosh/external-db/bosh_user password=${bosh_rds_password}
safe set /secret/${env_bosh_name}/bosh/external-db/credhub_user password=${credhub_rds_password}
safe set /secret/${env_bosh_name}/bosh/external-db/uaa_user password=${uaa_rds_password}

safe set /secret/${env_bosh_name}/bosh/blobstore/s3 access_key=${aws_access_key_s3}
safe set /secret/${env_bosh_name}/bosh/blobstore/s3 secret_key=${aws_secret_key_s3}

safe set /secret/${env_bosh_name}/bosh/aws access_key=${aws_access_key_bosh}
safe set /secret/${env_bosh_name}/bosh/aws secret_key=${aws_secret_key_bosh}

safe gen  -l 64 /secret/${env_bosh_name}/bosh/db password
###############
## Concourse ##
###############
safe set secret/${proto_bosh_name}/concourse/database/external password=${concourse_rds_password}


################
##    RDS     ##
################
safe set /secret/${proto_bosh_name}/bosh/external_db_ca external_db_ca@manifests/bosh/rds_ca
safe set /secret/${proto_bosh_name}/bosh/external-db external_db_ca@manifests/bosh/rds_ca
safe set /secret/${proto_bosh_name}/bosh/trusted_certs trv_root_ca@manifests/bosh/rds_ca
safe set /secret/${env_bosh_name}/bosh/external_db_ca external_db_ca@manifests/bosh/rds_ca
safe set /secret/${env_bosh_name}/bosh/external-db external_db_ca@manifests/bosh/rds_ca
safe set /secret/${env_bosh_name}/bosh/trusted_certs trv_root_ca@manifests/bosh/rds_ca
safe set secret/rds/external_db_ca external_db_ca@manifests/bosh/rds_ca

########
## CF ##
########

safe set /secret/${env_bosh_name}/autoscaler/db password=${cf_autoscaler_rds_password}


############
## SHIELD ##
############

#safe set /secret/${env_bosh_name}/bosh/aws access_key=${aws_access_key_s3}
#safe set /secret/${env_bosh_name}/bosh/aws secret_key=${aws_secret_key_s3}