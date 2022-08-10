kit:
  name:    bosh
  version: 2.2.6
  features:
    - aws
    - s3-blobstore
    - bosh-dns-healthcheck
    - netop-access
    - sysop-access
    - external-db-postgres

genesis:
  env:            dev
  bosh_env:       ${environment_nickname}
  min_version:    2.7.8

meta:
  trusted_certs:
    - (( vault meta.vault "/external-db:external_db_ca" ))
    - (( vault meta.vault "/trusted_certs:trv_root_ca" ))

params:
  trusted_certs:  (( join "" meta.trusted_certs ))
  static_ip: ${bosh_network_first_3_octets}.4

  aws_region: ${aws_region}
  aws_default_sgs:
    - ${env_bosh_sg_wide_open}
    - ${env_bosh_sg}

  # External S3 Blobstore Configuration
  s3_blobstore_bucket: ${env_bosh_s3_bucket}
  s3_blobstore_region: ${aws_region}

  # External db configuration
  external_db_host: ${env_bosh_rds_host}
  external_db_ca: (( vault meta.vault "/external_db_ca:external_db_ca" ))
  credhub_db_user: ${credhub_username}
  bosh_db_user: ${bosh_username}
  uaa_db_user: ${uaa_username}

  # DNS Caching (for runtime config)
  dns_cache: true