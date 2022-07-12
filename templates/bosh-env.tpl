kit:
  name:    bosh
  version: fillthisin
  features:
    - aws
    - proto
    - s3-blobstore
    - bosh-dns-healthcheck
    - netop-access
    - sysop-access
    - external-db-postgres
#    - offline-releases     # T speciic
#    - offline-stemcell-mgmt  # T specific 
#    - bosh-cloud-properties




genesis:
  env:            dev
  min_version:    2.7.8

params:
  # These parameters are all that we need to specify for an Environment
  # BOSH, since networking and VM type configuration comes from that cloud-config
  #
  static_ip: 10.4.16.4

  # BOSH on AWS needs to know what region to deploy to, and what
  # default security groups to apply to all VMs by default.
  #
  # AWS credentials are stored in the Vault at
  #   /secret/uswest2demo/dev/bosh/aws
  #

  # TODO: T# has networking info in here...

  aws_region: ${aws_region}
  aws_subnet_id: ${aws_subnet_id}
  aws_default_sgs:
    - ${security_group}

  # External db configuration
  external_db_host: ${rds_host}
  external_db_ca: ${TODO...}
  credhub_db_user: ${credhub_username}
  bosh_db_user: ${bosh_username}
  uaa_db_user: ${uaa_username}

  # External S3 Blobstore Configuration
  s3_blobstore_bucket: ${blobstore_bucket}
  s3_blobstore_region: ${blobstore_region}

  # DNS Caching (for runtime config)
  dns_cache: true

  # KMS Disk Encryption
  aws_ebs_encryption: true
  kms_key_arn: ${kms_key_arn}




  bosh_network: dev
  bosh_vm_type: bosh
  bosh_disk_type: large
  bosh_disk_pool: bosh