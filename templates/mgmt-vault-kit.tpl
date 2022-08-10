---
kit:
  name:    vault
  version: 1.6.4

genesis:
  env:            ${environment_nickname}
  min_version:    2.7.0

params:
  vault_disk_pool: vault
  vault_vm_type: vault

instance_groups:
  - name: vault
    vm_extensions:
      - ${vault_alb_target_group}

#### Custom, just for testing
update:
  canaries: 1
  canary_watch_time: 1000-60000
  max_in_flight: 2
  serial: false
  update_watch_time: 1000-60000