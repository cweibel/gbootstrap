---
kit:
  name:    cf
  version: 2.2.0-rc.14
  features:

    - postgres-db
    - aws-blobstore
    #- routing-api-username ## Do not need, already set as param
   ## - scale-to-3-az
    #- okta-uaa-login      ## Probably not happening in AWS codex
    ##- config-server-client
    ##- app-autoscaler-integration
    ##- app-scheduler-integration
    ##- ssh-proxy-on-routers
    ##- smb-volume-services
    ##- smb-volume-services-release
    ##- windows-bosh-dns-alias
    ##- windows-diego-cells
    #- windows-releases   #### only use in airgapped environments, has to be after windows-diego-cells
    ##- windows-smoke-tests
    #- add-liberty-isolation-segment-diego-cell
    #- add-persistent-isolation-segment-diego-cell
    #- apps-trust-redis-useast1-ca    # Blacksmith Redis Services CA Certificate
    #- apps-trust-rabbitmq-useast1-ca # Blacksmith RabitMQ Services CA Certificate
    #- apps-trust-trv-root-ca      # Moved order to after windows in merge to pick up windows2019-cell
    #- isolation-segment-apps-trust-trv-root-ca      # Moved order to after windows in merge to pick up windows2019-cell
    #- apps-trust-rds-useast1-ca   # Moved order to after windows in merge to pick up windows2019-cell
    - apps-trust-rds
    ##- nfs-volume-services
    ##- nfs-version                  ### release must be manually uploaded first
    #- nfs-ldap-ca-cert
    ##- encrypt-cf-db-connections
    #- uaa-ldap
    #- cf-deployment/operations/enable-nfs-ldap
    #- windows-offline-2019fs # It appears we no longer need this one?
    #- enable-service-discovery
    - custom-router-group-ports   # Used for TCP Routing
    # Post MVP:
    #- prometheus-integration
    #- buildpacks-nexus-releases # Buildpacks from Nexus
    #- buildpacks-install-current # Insall _current versions of buildpacks
    #- buildpacks-install-previous # Insall _previous versions of buildpacks

 

genesis:
  env:         ${environment_nickname}
  min_version: 2.8.4

 

params:
  # Cloud Foundry base domain
  base_domain:   ${cf_base_domain}
  system_domain: system.${cf_base_domain}
  apps_domains:
  - run.${cf_base_domain}

  # External Blobstore
  blobstore_s3_region: ${aws_region}
  blobstore_app_packages_directory: ${cf_s3_app_packages}
  blobstore_buildpacks_directory: ${cf_s3_buildpacks}
  blobstore_droplets_directory: ${cf_s3_droplets}
  blobstore_resources_directory: ${cf_s3_resources}


  # Skip SSL validation since we use self-signed certs

  skip_ssl_validation: true

  # External Database
  external_db_host:        ${cf_rds_host}
  uaadb_password:          ${cf_rds_uaa_password}
  uaadb_user:              ${cf_rds_uaa_user}
  ccdb_password:           ${cf_rds_ccdb_password}
  ccdb_user:               ${cf_rds_ccdb_user}
  diegodb_password:        ${cf_rds_diego_password}
  diegodb_user:            ${cf_rds_diego_user}
  policyserverdb_password: ${cf_rds_netpolicy_password}
  policyserverdb_user:     ${cf_rds_netpolicy_user}
  silkdb_password:         ${cf_rds_silkdb_password}
  silkdb_user:             ${cf_rds_silkdb_user}
  routingapidb_password:   ${cf_rds_routingdb_password}
  routingapidb_user:       ${cf_rds_routingdb_user}
  locketdb_password:       ${cf_rds_locketdb_password}
  locketdb_user:           ${cf_rds_locketdb_user}
  credhubdb_password:      ${cf_rds_credhub_password}
  credhubdb_user:          ${cf_rds_credhub_user}


 

  # Instances Scaling

  api_instances: ${cf_api_instance_count}
  cc_worker_instances: ${cf_ccworker_instance_count}
  credhub_instances: ${cf_credhub_instance_count}
  diego_api_instances: ${cf_diegoapi_instance_count}
  doppler_instances: ${cf_doppler_instance_count}
  log_api_instances: ${cf_logapi_instance_count}
  nats_instances: ${cf_nats_instance_count}
  router_instances: ${cf_router_instance_count}
  scheduler_instances: ${cf_scheduler_instance_count}
  tcp_router_instances: ${cf_tcprouter_instance_count }
  uaa_instances: ${cf_uaa_instance_count}
  diego_cell_instances: ${cf_diegocell_instance_count}  #Max requested scaled down for licensing
  #_diego_cell_instances: ${cf_windows_diegocell_instance_count} # Required for Windows, Max requested scaled down for licensing
  #windows_diego_cell_vm_type: ${cf_windows_diegocell_vm_type} # Required for Windows

 

  # Cloud Config instance vm_type mappings

  api_vm_type: ${cf_api_vm_type}
  cc_worker_vm_type: ${cf_ccworker_vm_type}
  credhub_vm_type: ${cf_credhub_vm_type}
  diego_api_vm_type:  ${cf_diegoapi_vm_type}
  diego_cell_vm_type: ${cf_diegocell_vm_type}
  doppler_vm_type: ${cf_doppler_vm_type}
  nats_vm_type: ${cf_nats_vm_type}
  log_api_vm_type: ${cf_logapi_vm_type}
  router_vm_type: ${cf_router_vm_type}
  errand_vm_type: ${cf_errand_vm_type}
  scheduler_vm_type: ${cf_scheduler_vm_type}
  tcp_router_vm_type: ${cf_tcp_router_vm_type}
  uaa_vm_type: ${cf_uaa_vm_type}
  external_db_ca: (( vault "secret/rds/external_db_ca:external_db_ca" ))
 

instance_groups:
- name: router
  vm_extensions:
  - (( replace ))
  - cf-router-network-and-system-properties
- name: diego-cell
  update:
    max_in_flight: 3
- name: uaa
  jobs:
  - name: uaa
    properties:
      uaa:
        clients:
          stratos:
            authorized-grant-types: authorization_code,client_credentials,refresh_token=
            redirect-uri: https://${stratos_domain}/pp/v1/auth/sso_login_callback
            autoapprove: true # Bypass users approval
            # The following properties are copied from those of the default 'cf' client:
            access-token-validity: 1200
            authorities: uaa.none
            override: true
            refresh-token-validity: 2592000
            scope:  network.admin,network.write,cloud_controller.read,cloud_controller.write,openid,password.write,cloud_controller.admin,scim.read,scim.write,doppler.firehose,uaa.user,routing.router_groups.read,routing.router_groups.write,cloud_controller.admin_read_only,cloud_controller.global_auditor,perm.admin,clients.read
            secret: "((stratos_client_secret))"




stemcells:
- alias: default
  os: ubuntu-bionic
  version: latest
# - alias: windows2019
#   os: windows2019
#   version: latest

variables:
- name: stratos_client_secret
  type: password