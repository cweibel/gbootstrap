---
kit:
  name:    cf-app-autoscaler
  version: 4.0.2
  features:
    - postgres
    - external-db
    #- use-bionic-stemcell ### Not needed because this is already in this yaml file.
    #- releases-versions-lock ## For airgapped environments
    #- loggregator-agent ## was previously called "T-ocfp-aws-uswest2-sz-np-dr-cf.yml" ### It seems like the kit is already doing this

genesis:
  env:            ${environment_nickname}
  min_version:    2.7.9

params:
  cf_deployment_env:  ${cf_deployment_env}
  cf_deployment_type: cf


bosh-variables:
  database:
    host:     ${autoscaler_db_host}
    username: ${autoscaler_db_username}

    password: ((vault "secret/${env_bosh_name}/autoscaler/db:password" ))
    tls:
      ca: (( vault "secret/rds/external_db_ca:external_db_ca" ))



stemcells:
  - alias: default
    os: ubuntu-bionic
    version: latest