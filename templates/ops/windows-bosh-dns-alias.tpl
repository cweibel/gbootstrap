---
# Otherwise auctioneer to assign jobs :1801 doesn't get response from any windows boxes
addons:
- name: bosh-dns-aliases
  jobs:
  - name: bosh-dns-aliases
    properties:
      aliases:
      - domain: _.cell.service.cf.internal
        targets:
        - (( append ))
        - deployment: ${cf_deployment_name}
          domain: bosh
          instance_group: windows2019-cell
          network: cf-runtime
          query: _
