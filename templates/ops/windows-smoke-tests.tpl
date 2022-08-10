- path: /instance_groups/-
  type: replace
  value:
    azs:
    - z1
    instances: 1
    jobs:
    - name: smoke_tests_windows
      properties:
        bpm:
          enabled: true
        smoke_tests:
          enable_windows_tests: true
          windows_stack: windows
          api: "https://api.((system_domain))"
          apps_domain: run.${cf_base_domain}
          client: cf_smoke_tests
          client_secret: "((uaa_clients_cf_smoke_tests_secret))"
          org: cf_smoke_tests_org
          space: cf_smoke_tests_space
          cf_dial_timeout_in_seconds: 300
          skip_ssl_validation: true
      release: cf-smoke-tests
    - name: cf-cli-7-linux
      release: cf-cli
    lifecycle: errand
    name: smoke-tests-windows
    networks:
    - name: cf-runtime
    stemcell: windows2019
    vm_type: minimal
