instance_groups:
- name: uaa
  jobs:
  - name: uaa
    release: uaa
    properties:
      uaa:
        ca_certs:
        - (( append ))
        - (( grab params.external_db_ca ))
      uaadb:
        tls: enabled


- name: diego-api
  jobs:
  - name: silk-controller
    release: silk
    properties:
      database:
        ca_cert: (( grab params.external_db_ca ))
        require_ssl: true


- name: api
  jobs:
  - name: routing-api
    release: routing
    properties:
      routing_api:
        sqldb:
          ca_cert: (( grab params.external_db_ca ))

  - name: policy-server
    release: cf-networking
    properties:
      database:
        ca_cert: (( grab params.external_db_ca ))
        require_ssl: true
