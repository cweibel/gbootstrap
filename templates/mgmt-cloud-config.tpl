azs:
- name: z1
  cloud_properties: {availability_zone: ${aws_az1}}
- name: z2
  cloud_properties: {availability_zone: ${aws_az2}}
- name: z3
  cloud_properties: {availability_zone: ${aws_az3}}

vm_types:
- name: default
  cloud_properties:
    instance_type: ${aws_default_vm_instance_cloud_config}
    ephemeral_disk: {size: 3000, type: gp2}
- name: large
  cloud_properties:
    instance_type: ${aws_large_vm_instance_cloud_config}
    ephemeral_disk: {size: 30000, type: gp2}
- name: vault
  cloud_properties:
    instance_type: ${aws_vault_vm_instance_cloud_config}
    ephemeral_disk: {size: 3000, type: gp2}
- name: concourse-worker
  cloud_properties:
    instance_type: ${aws_concourse_worker_vm_instance_cloud_config}
    ephemeral_disk: {size: 65536, type: gp2}
- name: small
  cloud_properties:
    instance_type: ${aws_concourse_small_vm_instance_cloud_config}
    ephemeral_disk: {size: 6000, type: gp2}

disk_types:
- name: default
  disk_size: 3000
  cloud_properties: {type: gp2}
- name: bosh
  disk_size: 3000
  cloud_properties: {type: gp2}
- name: large
  disk_size: 50_000
  cloud_properties: {type: gp2}
- name: vault
  disk_size: 3000
  cloud_properties: {type: gp2}
- name: concourse
  disk_size: 10240
  cloud_properties: {type: gp2}


networks:
- name: default
  type: manual
  subnets:
  - range: ${network}.1.0/24
    gateway: ${network}.1.1
    azs: ["z1", "z2", "z3"]
    static: [${network}.1.6-${network}.1.16]
    dns: [8.8.8.8, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_global_infra}}
    reserved: [${network}.1.0-${network}.1.5]
- name: vault
  type: manual
  subnets:
  - range: ${network}.1.0/24
    gateway: ${network}.1.1
    azs: ["z1", "z2", "z3"]
    static: [${network}.1.20-${network}.1.25]
    dns: [8.8.8.8, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_global_infra}}
    reserved: [${network}.1.0-${network}.1.19]
- name: concourse
  type: manual
  subnets:
  - range: ${network}.1.0/24
    gateway: ${network}.1.1
    azs: ["z1", "z2", "z3"]
    static: [${network}.1.35-${network}.1.45]
    dns: [8.8.8.8, 8.8.4.4]
    cloud_properties: {subnet: ${subnet_global_infra}}
    reserved: [${network}.1.0-${network}.1.34]
- name: bosh                                                
  type: manual                                             
  subnets:                                                 
  - range: ${network}.16.0/24                                    
    gateway: ${network}.16.1                                     
    azs: ["z1"]                                            
    static: [${network}.16.4-${network}.16.16]                         
    dns: [1.1.1.1, 8.8.4.4]                                
    cloud_properties: {subnet: ${subnet_dev_infra_1}}    
    reserved: [${network}.16.0-${network}.16.3]                          
  - range: ${network}.17.0/24                                    
    gateway: ${network}.17.1                                     
    azs: ["z2"]                                            
    static: [${network}.17.4-${network}.17.16]                         
    dns: [1.1.1.1, 8.8.4.4]                                
    cloud_properties: {subnet: ${subnet_dev_infra_2}}     
    reserved: [${network}.17.0-${network}.17.3]                          
  - range: ${network}.18.0/24                                    
    gateway: ${network}.18.1                                     
    azs: ["z3"]                                            
    static: [${network}.18.4-${network}.18.16]                         
    dns: [1.1.1.1, 8.8.4.4]                                
    cloud_properties: {subnet: ${subnet_dev_infra_3}}     
    reserved: [${network}.18.0-${network}.18.3]                         



compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: large
  network: default

vm_extensions:
  - name: vault-alb
    cloud_properties:
       lb_target_groups:
          - ${vault_alb_tg_name}

  - name: ${concourse_alb_name}
    cloud_properties:
       lb_target_groups:
         - ${concourse_alb_tg_name}