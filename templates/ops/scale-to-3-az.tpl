---
################################################################################
# This override deploys 3 Availability Zones.
################################################################################
- type: replace
  path: /instance_groups/name=nats/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=diego-api/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=uaa/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=scheduler/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=diego-cell/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=router/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=api/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=cc-worker/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=doppler/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=log-api/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=tcp-router/azs
  value: [ z1, z2, z3 ]
- type: replace
  path: /instance_groups/name=credhub/azs
  value: [ z1, z2, z3 ]
