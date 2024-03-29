- type: replace
  path: /instance_groups/name=asapi/jobs/name=loggregator_agent/properties/metrics?
  value:
    server_name: metricsserver.service.cf.internal
    ca_cert: ((loggregator_agent_metrics_tls.ca))
    cert: ((loggregator_agent_metrics_tls.certificate))
    key: ((loggregator_agent_metrics_tls.private_key))
---
bosh-variables:
  loggregator_agent_metrics_tls:
    ca :            (( vault meta.cf.exodus ":loggregator_agent_metrics_tls_ca"))
    certificate:    (( vault meta.cf.exodus ":loggregator_agent_metrics_tls_certificate"))
    private_key:    (( vault meta.cf.exodus ":loggregator_agent_metrics_tls_private_key"))

