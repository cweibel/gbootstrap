---
kit:
  name:    concourse
  version: 4.1.3
  features:
    - (( replace ))
    - full
    - no-haproxy
    - self-signed-cert
    - external-db
#    - vault
#    - vault-approle
## Uncomment for deploy 2

    
genesis:
  env:            ${environment_nickname}
  min_version:    2.7.6


params:
  external_domain: ${concourse_alb_domain}
  concourse_network: ${concourse_network_name}

  num_web_nodes: ${concourse_web_node_count}
  worker_count:  ${concourse_worker_node_count}

  availability_zone: [${concourse_azs}]

## Uncomment for deploy 2
#  vault_approle_role_id: (( vault "secret/${environment_nickname}/concourse/approle/concourse:approle-id" ))
#  vault_approle_secret_id: (( vault "secret/${environment_nickname}/concourse/approle/concourse:approle-secret" ))
  vault_url: https://${network}.1.20
  vault_token: (( vault "secret/${environment_nickname}/full/concourse/vault:token" ))
  vault_insecure_skip_verify: true

  external_db_host: ${concourse_rds_host}
  external_db_port: ${concourse_rds_port}
  external_db_name: ${concourse_rds_db_name}
  external_db_user: ${concourse_rds_db_user}
  external_db_sslmode: verify-ca
  external_db_ca: (( vault "secret/rds/external_db_ca:external_db_ca" ))

instance_groups:
  - name: web
    vm_extensions:
      - ${concourse_alb_name}
