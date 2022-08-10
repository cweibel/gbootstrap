cf curl -X PUT -d '{"reservable_ports":"40000-40099"}' /routing/v1/router_groups/$(cf curl /routing/v1/router_groups | jq  -r '.[].guid')
cf create-shared-domain ${tcp_domain} --router-group default-tcp
cf domains # just observe output

