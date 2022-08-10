kit:
  name:    bosh
  version: 2.2.6
  features:
    - aws
    - proto
    - s3-blobstore
    - bosh-dns-healthcheck
    - netop-access
    - sysop-access
    - external-db-postgres
#    - offline-releases
#    - offline-stemcell

genesis:
  env:            ${environment_nickname}
  bosh_env:       ((prune))
  min_version:    2.7.8

meta:
  trusted_certs:
    - (( vault meta.vault "/external-db:external_db_ca" ))
    - (( vault meta.vault "/trusted_certs:trv_root_ca" ))


params:
  trusted_certs:  (( join "" meta.trusted_certs ))

  # These properties definte the host-level networking for a proto-BOSH.
  # Environmental BOSHes can depend on their parent BOSH cloud-config,
  # but for proto- environments, we have to specify these.
  #
  static_ip:       10.7.1.4
  subnet_addr:     10.7.1.0/24
  default_gateway: 10.7.1.1
  dns:
    - 8.8.8.8
    - 1.1.1.1

  # BOSH on AWS needs to know what region to deploy to, and what
  # default security groups to apply to all VMs by default.
  #
  # AWS credentials are stored in the Vault at
  #   /secret/codex/bosh/aws
  #
  aws_region: ${aws_region}
  aws_default_sgs:
    - ${mgmt_bosh_sg_wide_open}
    - ${mgmt_bosh_sg}

  # The following configuration is only necessary for proto-BOSH
  # deployments, since environment BOSHes will derive their networking
  # and VM/AMI configuration from their parent BOSH cloud-config.
  #
  aws_subnet_id: ${mgmt_bosh_subnet}
  aws_security_groups:
    - ${mgmt_bosh_sg_wide_open}
    - ${mgmt_bosh_sg}

  # External S3 Blobstore Configuration
  s3_blobstore_bucket: ${mgmt_bosh_s3_bucket}
  s3_blobstore_region: ${aws_region}

  aws_instance_type: ${aws_bosh_default_vm_type}


  # External db configuration
  external_db_host: ${mgmt_bosh_rds_host}
  external_db_ca: (( vault meta.vault "/external_db_ca:external_db_ca" ))
  credhub_db_user: ${credhub_username}
  bosh_db_user: ${bosh_username}
  uaa_db_user: ${uaa_username}

  # DNS Caching (for runtime config)
  dns_cache: true

  aws_ebs_encryption: true
  kms_key_arn: ${aws_kms_key}