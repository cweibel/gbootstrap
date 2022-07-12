# Ok, why all the coalesce(one(blah[*])) stuff?  All of the modules referenced have a `count` variable that
# is used to either enable or disable the creation of the resource.  The existence of `count` forces the
# existence of [*].  The coalesce piece is for if opt to not enable the resource, the first parameter will 
# return null, so coalesce will then skip to the "none" value and return that since Output variables are 
# required to HAVE a value other than null. 

output "rds_mgmt_bosh_db_instance_dbuser"      {value = coalesce(one(module.mgmt_bosh_rds[*].rds_db_instance_dbuser), "none") }
output "rds_mgmt_bosh_db_instance_dbpass"      {value = coalesce(one(module.mgmt_bosh_rds[*].rds_db_instance_dbpass), "none") }
output "rds_mgmt_bosh_db_instance_dbhost"      {value = coalesce(one(module.mgmt_bosh_rds[*].rds_db_instance_dbhost), "none") }
output "rds_mgmt_concourse_db_instance_dbuser" {value = coalesce(one(module.mgmt_concourse_rds[*].rds_db_instance_dbuser), "none") }
output "rds_mgmt_concourse_db_instance_dbpass" {value = coalesce(one(module.mgmt_concourse_rds[*].rds_db_instance_dbpass), "none") }
output "rds_mgmt_concourse_db_instance_dbhost" {value = coalesce(one(module.mgmt_concourse_rds[*].rds_db_instance_dbhost), "none") }
output "rds_env_bosh_db_instance_dbuser"       {value = coalesce(one(module.env_bosh_rds[*].rds_db_instance_dbuser), "none") }
output "rds_env_bosh_db_instance_dbpass"       {value = coalesce(one(module.env_bosh_rds[*].rds_db_instance_dbpass), "none") }
output "rds_env_bosh_db_instance_dbhost"       {value = coalesce(one(module.env_bosh_rds[*].rds_db_instance_dbhost), "none") }
output "rds_env_cf_db_instance_dbuser"         {value = coalesce(one(module.env_cf_rds[*].rds_db_instance_dbuser), "none") }
output "rds_env_cf_db_instance_dbpass"         {value = coalesce(one(module.env_cf_rds[*].rds_db_instance_dbpass), "none") }
output "rds_env_cf_db_instance_dbhost"         {value = coalesce(one(module.env_cf_rds[*].rds_db_instance_dbhost), "none") }
output "rds_env_stratos_db_instance_dbuser"    {value = coalesce(one(module.env_stratos_rds[*].rds_db_instance_dbuser), "none") }
output "rds_env_stratos_db_instance_dbpass"    {value = coalesce(one(module.env_stratos_rds[*].rds_db_instance_dbpass), "none") }
output "rds_env_stratos_db_instance_dbhost"    {value = coalesce(one(module.env_stratos_rds[*].rds_db_instance_dbhost), "none") }
output "rds_env_autoscaler_db_instance_dbuser" {value = coalesce(one(module.env_autoscaler_rds[*].rds_db_instance_dbuser), "none") }
output "rds_env_autoscaler_db_instance_dbpass" {value = coalesce(one(module.env_autoscaler_rds[*].rds_db_instance_dbpass), "none") }
output "rds_env_autoscaler_db_instance_dbhost" {value = coalesce(one(module.env_autoscaler_rds[*].rds_db_instance_dbhost), "none") }


output "s3_proto_bosh"       {value = coalesce(one(module.proto-bosh-blobstore[*].bucket_id),   "none")}
output "s3_env_bosh"         {value = coalesce(one(module.env-bosh-blobstore[*].bucket_id),     "none")}
output "s3_cf_app_packages"  {value = coalesce(one(module.app-packages-blobstore[*].bucket_id), "none")}
output "s3_cf_buildpacks"    {value = coalesce(one(module.buildpacks-blobstore[*].bucket_id),   "none")}
output "s3_cf_droplets"      {value = coalesce(one(module.droplets-blobstore[*].bucket_id),     "none")}
output "s3_cf_resources"     {value = coalesce(one(module.resources-blobstore[*].bucket_id),    "none")}


output "concourse_alb_dns_name"      {value = coalesce(one(module.concourse-lb[*].dns_name),       "none")}
output "vault_alb_dns_name"          {value = coalesce(one(module.vault-lb[*].dns_name),           "none")}
output "blacksmith_alb_dns_name"     {value = coalesce(one(module.blacksmith-lb[*].dns_name),      "none")}
output "cf_ssh_nlb_dns_name"         {value = coalesce(one(module.cf-ssh-lb[*].dns_name),          "none")}
output "cf_tcp_elb_dns_name"         {value = coalesce(one(module.cf-tcp-lb[*].dns_name),          "none")}
output "cf_system_app_alb_dns_name"  {value = coalesce(one(module.cf-system-apps-lb[*].dns_name),  "none")}


output "concourse_alb_name"          {value = coalesce(one(module.concourse-lb[*].lb_name),        "none")}
output "vault_alb_name"              {value = coalesce(one(module.vault-lb[*].lb_name),            "none")}
output "blacksmith_alb_name"         {value = coalesce(one(module.blacksmith-lb[*].lb_name),       "none")}
output "cf_ssh_nlb_name"             {value = coalesce(one(module.cf-ssh-lb[*].lb_name),           "none")}
output "cf_tcp_elb_name"             {value = coalesce(one(module.cf-tcp-lb[*].lb_name),           "none")}
output "cf_system_app_alb_name"      {value = coalesce(one(module.cf-system-apps-lb[*].lb_name),   "none")}

output "ssh_to_bastion"              {value = "ssh -i ${var.aws_key_file} ubuntu@${module.bastion.box-bastion-public} "}
output "box-bastion-public"          { value = module.bastion.box-bastion-public }

#output "mgmt_configure_bosh_db_rendered_file_contents" {value = coalesce(one(module.mgmt-configure-bosh-db[*].rendered_file_contents), "none") }
#output "mgmt_configure_bosh_db_rendered_file_location" {value = coalesce(one(module.mgmt-configure-bosh-db[*].rendered_file_location), "none") }
#
#output "env_configure_bosh_db_rendered_file_contents" {value = coalesce(one(module.env-configure-bosh-db[*].rendered_file_contents), "none") }
#output "env_configure_bosh_db_rendered_file_location" {value = coalesce(one(module.env-configure-bosh-db[*].rendered_file_location), "none") }