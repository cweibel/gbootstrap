networks:
- name: default
  type: manual
  subnets:
  - range: ${first_3_octets_subnet_dev_infra_0}.0/24
    gateway: ${first_3_octets_subnet_dev_infra_0}.1
    azs: ["z1"]
    static: [${first_3_octets_subnet_dev_infra_0}.6-${first_3_octets_subnet_dev_infra_0}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_dev_infra_0}} 
    reserved: [${first_3_octets_subnet_dev_infra_0}.0-${first_3_octets_subnet_dev_infra_0}.5, ${first_3_octets_subnet_dev_infra_0}.245-${first_3_octets_subnet_dev_infra_0}.254]
  - range: ${first_3_octets_subnet_dev_infra_1}.0/24
    gateway: ${first_3_octets_subnet_dev_infra_1}.1
    azs: ["z2"]
    static: [${first_3_octets_subnet_dev_infra_1}.6-${first_3_octets_subnet_dev_infra_1}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_dev_infra_1}}
    reserved: [${first_3_octets_subnet_dev_infra_1}.0-${first_3_octets_subnet_dev_infra_1}.5]
  - range: ${first_3_octets_subnet_dev_infra_2}.0/24 
    gateway: ${first_3_octets_subnet_dev_infra_2}.1
    azs: ["z3"]
    static: [${first_3_octets_subnet_dev_infra_2}.6-${first_3_octets_subnet_dev_infra_2}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_dev_infra_2}} 
    reserved: [${first_3_octets_subnet_dev_infra_2}.0-${first_3_octets_subnet_dev_infra_2}.5]

- name: compilation
  type: manual
  subnets:
  - range: ${first_3_octets_subnet_dev_infra_0}.0/24
    gateway: ${first_3_octets_subnet_dev_infra_0}.1
    azs: ["z1"]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_dev_infra_0}}
    reserved: [${first_3_octets_subnet_dev_infra_0}.0-${first_3_octets_subnet_dev_infra_0}.244]



- name: cf-edge
  type: manual
  subnets:
  - range: ${first_3_octets_subnet_cf_edge_0}.0/24
    gateway: ${first_3_octets_subnet_cf_edge_0}.1
    azs: ["z1"]
    static: [${first_3_octets_subnet_cf_edge_0}.4-${first_3_octets_subnet_cf_edge_0}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_cf_edge_0}} #snw-dev-cf-edge-0
    reserved: [${first_3_octets_subnet_cf_edge_0}.0-${first_3_octets_subnet_cf_edge_0}.3]
  - range: ${first_3_octets_subnet_cf_edge_1}.0/24
    gateway: ${first_3_octets_subnet_cf_edge_1}.1
    azs: ["z2"]
    static: [${first_3_octets_subnet_cf_edge_1}.4-${first_3_octets_subnet_dev_infra_1}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_cf_edge_1}} #snw-dev-cf-edge-1
    reserved: [${first_3_octets_subnet_cf_edge_1}.0-${first_3_octets_subnet_cf_edge_1}.3]
  - range: ${first_3_octets_subnet_cf_edge_2}.0/24
    gateway: ${first_3_octets_subnet_cf_edge_2}.1
    azs: ["z3"]
    static: [${first_3_octets_subnet_cf_edge_2}.4-${first_3_octets_subnet_cf_edge_2}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_cf_edge_2}} #snw-dev-cf-edge-1
    reserved: [${first_3_octets_subnet_cf_edge_2}.0-${first_3_octets_subnet_cf_edge_2}.3]

- name: cf-core
  type: manual
  subnets:
  - range: ${first_3_octets_subnet_cf_core_0}.0/24
    gateway: ${first_3_octets_subnet_cf_core_0}.1
    azs: ["z1"]
    static: [${first_3_octets_subnet_cf_core_0}.6-${first_3_octets_subnet_cf_core_0}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_cf_core_0}} #snw-dev-cf-core-0
    reserved: [${first_3_octets_subnet_cf_core_0}.0-${first_3_octets_subnet_cf_core_0}.5]
  - range: ${first_3_octets_subnet_cf_core_1}.0/24
    gateway: ${first_3_octets_subnet_cf_core_1}.1
    azs: ["z2"]
    static: [${first_3_octets_subnet_cf_core_1}.6-${first_3_octets_subnet_cf_core_1}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_cf_core_1}} #snw-dev-cf-core-1
    reserved: [${first_3_octets_subnet_cf_core_1}.0-${first_3_octets_subnet_cf_core_1}.5]
  - range: ${first_3_octets_subnet_cf_core_2}.0/24
    gateway: ${first_3_octets_subnet_cf_core_2}.1
    azs: ["z3"]
    static: [${first_3_octets_subnet_cf_core_2}.6-${first_3_octets_subnet_cf_core_2}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_cf_core_2}} #snw-dev-cf-core-2
    reserved: [${first_3_octets_subnet_cf_core_2}.0-${first_3_octets_subnet_cf_core_2}.5]  

- name: cf-runtime
  type: manual
  subnets:
  - range: ${first_3_octets_subnet_cf_runtime_0}.0/24
    gateway: ${first_3_octets_subnet_cf_runtime_0}.1
    azs: ["z1"]
    static: [${first_3_octets_subnet_cf_runtime_0}.6-${first_3_octets_subnet_cf_runtime_0}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_cf_runtime_0}} #snw-dev-cf-runtime-0
    reserved: [${first_3_octets_subnet_cf_runtime_0}.0-${first_3_octets_subnet_cf_runtime_0}.5]
  - range: ${first_3_octets_subnet_cf_runtime_1}.0/24
    gateway: ${first_3_octets_subnet_cf_runtime_1}.1
    azs: ["z2"]
    static: [${first_3_octets_subnet_cf_runtime_1}.6-${first_3_octets_subnet_cf_runtime_1}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_cf_runtime_1}} #snw-dev-cf-runtime-1
    reserved: [${first_3_octets_subnet_cf_runtime_1}.0-${first_3_octets_subnet_cf_runtime_1}.5]
  - range: ${first_3_octets_subnet_cf_runtime_2}.0/24
    gateway: ${first_3_octets_subnet_cf_runtime_2}.1
    azs: ["z3"]
    static: [${first_3_octets_subnet_cf_runtime_2}.6-${first_3_octets_subnet_cf_runtime_2}.16]
    dns: [1.1.1.1, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_cf_runtime_2}} #snw-dev-cf-runtime-2
    reserved: [${first_3_octets_subnet_cf_runtime_2}.0-${first_3_octets_subnet_cf_runtime_2}.5]  


compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: large
  network: default

azs:
- name: z1
  cloud_properties: {availability_zone: ${aws_az1}}
- name: z2
  cloud_properties: {availability_zone: ${aws_az2}}
- name: z3
  cloud_properties: {availability_zone: ${aws_az3}}

disk_types:
  - {"name": "default","disk_size": 2048, cloud_properties: {type: gp2} }
  - {"name": "consul","disk_size": 2048, cloud_properties: {type: gp2} }
  - {"name": "concourse","disk_size": 10240, cloud_properties: {type: gp2} }
  - {"name": "postgres","disk_size": 4096, cloud_properties: {type: gp2} }
  - {"name": "blobstore","disk_size": 4096, cloud_properties: {type: gp2} }
  - {"name": "vault","disk_size": 1024, cloud_properties: {type: gp2} }
  - {"name": "bosh","disk_size": 65536, cloud_properties: {type: gp2} }
  - {"name": "bosh-large","disk_size": 131072, cloud_properties: {type: gp2} }
  - {"name": "shield","disk_size": 2048, cloud_properties: {type: gp2} }
  - {"name": "jumpbox","disk_size": 51200, cloud_properties: {type: gp2} }
  - {"name": "prometheus","disk_size": 51200, cloud_properties: {type: gp2} }
  - {"name": "rabbitmq","disk_size": 4096, cloud_properties: {type: gp2} }
  - {"name": "5GB","disk_size": 5120, cloud_properties: {type: gp2} }
  - {"name": "10GB","disk_size": 10240, cloud_properties: {type: gp2} }
  - {"name": "100GB","disk_size": 100240, cloud_properties: {type: gp2} }
  - {"name": "minio","disk_size": 10240, cloud_properties: {type: gp2} }

vm_extensions:
  - name: 100GB_ephemeral_disk
    cloud_properties:
      ephemeral_disk:
        size: 102400
        type: gp2
  - name: 50GB_ephemeral_disk
    cloud_properties:
      ephemeral_disk:
        size: 51200
        type: gp2  
  - name: cf-router-network-properties
    cloud_properties:
       lb_target_groups:
         - ${cf_system_tg} 
  - name: cf-router-network-and-system-properties
    cloud_properties:
       lb_target_groups:
         - ${cf_system_tg} 
         - ${cf_ssh_tg}
  - {"name": "cf-tcp-router-network-properties"}
  - {"name": "diego-ssh-proxy-network-properties"}



vm_types:
  - {"name": "default","cloud_properties":          {instance_type: t3.small, ephemeral_disk: {size: 8192, type: gp2}} }
  - {"name": "compilation","cloud_properties":      {instance_type: t3.medium, ephemeral_disk: {size: 32768, type: gp2}} }
  - {"name": "small","cloud_properties":            {instance_type: t3.small, ephemeral_disk: {size: 8192, type: gp2}} }
  - {"name": "medium","cloud_properties":           {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }
  - {"name": "large","cloud_properties":            {instance_type: t3.medium, ephemeral_disk: {size: 32768, type: gp2}} }
  - {"name": "haproxy","cloud_properties":          {instance_type: t3.small, ephemeral_disk: {size: 8192, type: gp2}} }
  - {"name": "api","cloud_properties":              {instance_type: t3.medium, ephemeral_disk: {size: 32768, type: gp2}} }
  - {"name": "bbs","cloud_properties":              {instance_type: t3.small, ephemeral_disk: {size: 8192, type: gp2}} }
  - {"name": "blobstore","cloud_properties":        {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }
  - {"name": "cell","cloud_properties":             {instance_type: t3.large, ephemeral_disk: {size: 40960, type: gp2}} }
  - {"name": "diego","cloud_properties":            {instance_type: t3.small, ephemeral_disk: {size: 36384, type: gp2}} }
  - {"name": "doppler","cloud_properties":          {instance_type: t3.small, ephemeral_disk: {size: 8192, type: gp2}} }
  - {"name": "errand","cloud_properties":           {instance_type: t3.small, ephemeral_disk: {size: 8192, type: gp2}} }
  - {"name": "loggregator","cloud_properties":      {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }
  - {"name": "nats","cloud_properties":             {instance_type: t3.small, ephemeral_disk: {size: 8192, type: gp2}} }
  - {"name": "postgres","cloud_properties":         {instance_type: t3.medium, ephemeral_disk: {size: 32768, type: gp2}} }
  - {"name": "router","cloud_properties":           {instance_type: t3.small, ephemeral_disk: {size: 8192, type: gp2}} }
  - {"name": "syslogger","cloud_properties":        {instance_type: t3.small, ephemeral_disk: {size: 8192, type: gp2}} }
  - {"name": "uaa","cloud_properties":              {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }
  - {"name": "minimal","cloud_properties":          {instance_type: t3.small, ephemeral_disk: {size: 10240, type: gp2}} }
  - {"name": "small-cf","cloud_properties":         {instance_type: t3.medium, ephemeral_disk: {size: 10240, type: gp2}} }
  - {"name": "small-highmem","cloud_properties":    {instance_type: t3.large, ephemeral_disk: {size: 24576, type: gp2}} }
  - {"name": "blacksmith","cloud_properties":       {instance_type: t3.small, ephemeral_disk: {size: 10240, type: gp2}} }
  - {"name": "jumpbox","cloud_properties":          {instance_type: t3.medium, ephemeral_disk: {size: 10240, type: gp2}} }
  - {"name": "concourse-worker","cloud_properties": {instance_type: t3.medium, ephemeral_disk: {size: 65536, type: gp2}} }
  - {"name": "thunder-dome","cloud_properties":     {instance_type: t3.large, ephemeral_disk: {size: 81920, type: gp2}} }
  - {"name": "bosh","cloud_properties":             {instance_type: t3.medium, ephemeral_disk: {size: 24576, type: gp2}} }
  - {"name": "as-api","cloud_properties":           {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }
  - {"name": "as-broker","cloud_properties":        {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }
  - {"name": "as-scheduler","cloud_properties":     {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }
  - {"name": "as-collector","cloud_properties":     {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }
  - {"name": "as-scaler","cloud_properties":        {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }
  - {"name": "as-engine","cloud_properties":        {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }
  - {"name": "as-operator","cloud_properties":      {instance_type: t3.small, ephemeral_disk: {size: 16384, type: gp2}} }