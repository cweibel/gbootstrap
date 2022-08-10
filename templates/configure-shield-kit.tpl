---
kit:
  name:    shield
  version: 1.12.0
  features: []
#    - oauth


genesis:
  env:            dev
  min_version:    2.7.6

params:
  shield_static_ip: ${shield_ip}
  external_domain: https://${shield_domain}
  shield_network: default
  shield_vm_type: shield
  shield_disk_pool: shield
  availability_zone: "z3"
#  authentication:
#    - name: Github
#      identifier: github
#      backend: github
#      properties:
#        client_id: ab88pickles7fe10
#        client_secret: d96782pickles3f0b3d6e9d
#        mapping:

instance_groups:
  - name: shield
    vm_extensions:
      - shield-network-properties
    jobs:
    - name: core
      properties: 
        failsafe:
          username: ${web_username}
          password: ${web_password}