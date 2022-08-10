---
exodus:
  config_server_client:      config_server_client
  config_server_secret:      (( grab instance_groups.uaa.jobs.uaa.properties.uaa.clients.config_server_client.secret ))

instance_groups:
- name: uaa
  jobs:
  - name: uaa
    properties:
      uaa:
        clients:
          config_server_client:
            authorized-grant-types: client_credentials
            authorities: uaa.admin,clients.admin,cloud_controller.read,cloud_controller.admin,uaa.resource
            secret:  "((uaa_clients_config_server_secret))"

variables:
- name: uaa_clients_config_server_secret
  type: password
