# Hi There....
#
# Ok, so you found `aws.tf`, found that creates the VPC and subnets and security groups and abstracted
# a bunch of other stuff.  What the heck is this file for?
# 
# The idea is that the `aws.tf` sets up a mostly generic VPC.  A number of customers have an 
# infrustucture team that manages creation of AWS accounts and usually has a prescribed way of
# creating a vpc with certain tags, certain kms aliases, default security groups and similar
# bits.
# 
# This file builds on top of that basic VPC and then fills in gaps with all the resources 
# needed to bootstrap a Mama BOSH and her deployments.  Many of the resources are created 
# in modules.  Why?  Again some of the customers may have their own modules for creating
# s3 buckets, or bastions, or RDS database, so you can plug-n-play and swap out the 
# modules below as long as they have the same outputs to be use for "artifacts"
# 
# What are "artifacts"?  Good question, glad you are still reading this!  The idea is that
# later on you'll need to create dbs on RDS, an artifact will be a bash script you can run
# to connect to the db and create all the users, passwords, databases and extensions needed.
# As these artifacts are created, we'll be providing documentation on where and how to use 
# them to make life a little easier during bootstrapping.
# 
# Now, on with the show:


################################################################################
# Variables
################################################################################

variable "resource_tags"            {}               # (required) - Assigned in tfvars file
variable "vpc_id"                   {}               # (optional) - Assign if a separate TF run creates the VPC.  For codex, this is all in the same repo, so the value is at "aws_vpc.default.id" 
variable "enable_mgmt"              { default = true }  # Create s3, rds resources in management, security groups are created automatically
variable "enable_env"               { default = true }  # Create s3, rds resources in env (ie: CF)

variable "enable_blacksmith_lb"     { default = false }  # Set to true to enable after supplying "system_acm_arn" value, enables blacksmith alb creation
variable "enable_vault_lb"          { default = false }  # Set to true to enable after supplying "vault_acm_arn" value, enables vault alb creation
variable "enable_cf_system_app_lb"  { default = false }  # Set to true to enable after supplying "apps_acm_arn" value, enables apps alb creation
variable "enable_concourse_lb"      { default = false }  # Set to true to enable after supplying "concourse_acm_arn" value, enables concourse alb creation
variable "enable_cf_ssh_lb"         { default = false }  # enables cf ssh nlb creation
variable "enable_cf_tcp_lb"         { default = false }  # enables cf tcp elb creation
variable "enable_shield_lb"         { default = false }   # enables shield alb creation

variable "enable_route_53"          { default = 0 }  # Set to 1 to enable, use for Codex because DNS is managed with CloudFlare

variable "environment_nickname"     { default = "codex2"}



################################################################################
# CIDRs
################################################################################
variable "private_cidrs" {default = [ "192.168.0.0/16", "162.76.0.0/16", "172.16.0.0/12", "169.184.0.0/16", "10.0.0.0/8"]}
variable "aws_s3_cidrs"  {default = [ "18.34.0.0/19", "54.231.0.0/16", "52.216.0.0/15", "52.217.0.0/16","18.34.232.0/21", "3.5.0.0/19", "44.192.134.240/28", "44.192.140.64/28" ]}
variable "env_cidrs"     {default = [ "10.5.0.0/16" ]}   # (required)

################################################################################
# RDS Instances
################################################################################

variable "rds_instance_name_mgmt_bosh"      {default = "sw-rds-mgmt-bosh"}       # (required)
variable "rds_instance_name_mgmt_concourse" {default = "sw-rds-mgmt-concourse"}  # (required)
variable "rds_instance_name_env_bosh"       {default = "sw-rds-env-bosh"}        # (required)
variable "rds_instance_name_env_cf"         {default = "sw-rds-env-cf"}          # (required)
variable "rds_instance_name_env_stratos"    {default = "sw-rds-env-stratos"}     # (required)
variable "rds_instance_name_env_autoscaler" {default = "sw-rds-env-autoscaler"}  # (required)


##################################################
## S3 
##################################################

variable "env_blobstore_bucket_prefix"       {default = "sw-env-codex"}          # (required)
variable "mgmt_blobstore_bucket_prefix"      {default = "sw-mgmt-codex"}         # (required)

################################################################################
# DNS & Certs
################################################################################
variable "route53_zone_id"     {default = ""}                                           # (required if using route53), https://us-east-1.console.aws.amazon.com/route53/v2/hostedzones#
variable "base_domain"         {default =                     "codex2.starkandwayne.com"}       # (required)
variable "vault_domain"        {default =                "vaultcodex2.starkandwayne.com"}       # (required)
variable "system_domain"       {default =            "*.system.codex2.starkandwayne.com"}       # (required)
variable "apps_domain"         {default =               "*.run.codex2.starkandwayne.com"}       # (required)
variable "ssh_domain"          {default =          "ssh.system.codex2.starkandwayne.com"}       # (required)
variable "blacksmith_domain"   {default =   "blacksmith.system.codex2.starkandwayne.com"}       # (required)
variable "tcp_domain"          {default =             "tcp.run.codex2.starkandwayne.com"}       # (required)
variable "concourse_domain"    {default =            "concoursecodex2.starkandwayne.com"}       # (required)

variable "stratos_domain"      {default =            "apps.run.codex2.starkandwayne.com"}       # (required)
variable "system_api_domain"   {default =          "api.system.codex2.starkandwayne.com"}       # (required)
variable "shield_domain"       {default =       "shield.system.codex2.starkandwayne.com"}       # (required)

variable "vault_acm_arn"       {default = "arn:aws:acm:us-west-2:034222900717:certificate/246b1c98-3ecf-488e-9a9f-eb4d849553aa"}     # (required), https://us-east-1.console.aws.amazon.com/acm/home?region=us-east-1#/certificates/list
variable "system_acm_arn"      {default = "arn:aws:acm:us-west-2:034222900717:certificate/1b513c9d-01b0-403d-aa0b-4550b7482f31"}     # (required)
variable "apps_acm_arn"        {default = "arn:aws:acm:us-west-2:034222900717:certificate/1b513c9d-01b0-403d-aa0b-4550b7482f31"}     # (required)
variable "concourse_acm_arn"   {default = "arn:aws:acm:us-west-2:034222900717:certificate/98b71339-5d08-468e-b043-976f083bacf1"}     # (required), https://us-east-1.console.aws.amazon.com/acm/home?region=us-east-1#/certificates/list

##################################################
## Key Pair
##################################################

variable "mgmt_bosh_key_pair_enabled"       {default = 0}                                    # Switch to 1 to enable after kit init and filling in the two values below
variable "mgmt_bosh_key_pair_key_name"      {default = "vcap@codex2"}                        # (required), "vcap@protobosh_deployment_name" is the naming scheme
variable "mgmt_bosh_key_pair_public_key"    {default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw454n8rdtH2KNXEiqhAycLE6EWWw3SqOKBmJ9sVR18j7d+MUvYsqlCGu55swScRAOLxxg7vU+gpcaM16LnnwO/fuVOLZQvaSMtW1BUUzoiSZ5EdFsOZoYt4VseANckHa20srf6vI9PKehU/vqraevoprQkdpr1c7yynhso53PxAo1v9jD5GyzUuT/oPsMGka6k9/4euGjtAMq7QZV1NOTpBEe703BLNT2y2eIPL6jHBdvM4lXyr2QDpIpLAISHBOgMYAUjnGvkRnn51lwMHZdUnSx01g/2TL6n9R304aD3f1jlJiiH/j49mtlBSoPVfyTLwPTq3v5sA3O4enRIPFD"}       # (required)


variable "env_bosh_key_pair_enabled"        {default = 0}                                    # Switch to 1 to enable after kit init and filling in the two values below
variable "env_bosh_key_pair_key_name"       {default = "vcap@dev"}                           # (required), "vcap@envbosh_deployment_name" is the naming scheme
variable "env_bosh_key_pair_public_key"     {default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw454n8rdtH2KNXEiqhAycLE6EWWw3SqOKBmJ9sVR18j7d+MUvYsqlCGu55swScRAOLxxg7vU+gpcaM16LnnwO/fuVOLZQvaSMtW1BUUzoiSZ5EdFsOZoYt4VseANckHa20srf6vI9PKehU/vqraevoprQkdpr1c7yynhso53PxAo1v9jD5GyzUuT/oPsMGka6k9/4euGjtAMq7QZV1NOTpBEe703BLNT2y2eIPL6jHBdvM4lXyr2QDpIpLAISHBOgMYAUjnGvkRnn51lwMHZdUnSx01g/2TL6n9R304aD3f1jlJiiH/j49mtlBSoPVfyTLwPTq3v5sA3O4enRIPFD"}       # (required)


##################################################
## SHIELD
##################################################

variable "shield_binary_version"     {default = "8.8.1"}
variable "shield_ip"                 {default = "10.7.18.10"}
variable "shield_web_username"       {default = "shield"}

################################################################################
# Data
################################################################################
#data "aws_subnets" "aws_managed_subnets" {
#  filter {
#    name   = "tag:Name"
#    values = ["app-aws-managed-*"]
#  }
#}
#

data "aws_subnets" "ocfp_subnets" {

  #Note: these are just used for the load balancers, consider renaming to something more obvious

  depends_on = [aws_subnet.dev-lb-edge-0, aws_subnet.dev-lb-edge-1, aws_subnet.dev-lb-edge-2]       # Specific to codex

  filter {
    name   = "tag:Name"
    #values = ["app-ec2-*"]    #T:
    values = ["${var.aws_vpc_name}-dev-lb-edge-*"]
  }
}

## Infra
data "aws_subnets" "ocfp_subnets_env_infra" {

  depends_on = [aws_subnet.dev-infra-0, aws_subnet.dev-infra-1, aws_subnet.dev-infra-2 ]       # Specific to codex

  filter {
    name   = "tag:Name"
    #values = ["app-ec2-*"]    #T:
    values = ["${var.aws_vpc_name}-dev-infra-*"]
  }
}

data "aws_subnet" "ocfp_subnets_env_infra_cidr_0" { id = data.aws_subnets.ocfp_subnets_env_infra.ids[0] }
data "aws_subnet" "ocfp_subnets_env_infra_cidr_1" { id = data.aws_subnets.ocfp_subnets_env_infra.ids[1] }
data "aws_subnet" "ocfp_subnets_env_infra_cidr_2" { id = data.aws_subnets.ocfp_subnets_env_infra.ids[2] }


## CF Edge
data "aws_subnets" "ocfp_subnets_env_edge" {
  depends_on = [aws_subnet.dev-cf-edge-0, aws_subnet.dev-cf-edge-1, aws_subnet.dev-cf-edge-2 ]       # Specific to codex
  filter {
    name   = "tag:Name"
    values = ["${var.aws_vpc_name}-dev-cf-edge-*"]
  }
}

data "aws_subnet" "ocfp_subnets_env_edge_cidr_0" { id  = data.aws_subnets.ocfp_subnets_env_edge.ids[0] }
data "aws_subnet" "ocfp_subnets_env_edge_cidr_1" { id  = data.aws_subnets.ocfp_subnets_env_edge.ids[1] }
data "aws_subnet" "ocfp_subnets_env_edge_cidr_2" { id  = data.aws_subnets.ocfp_subnets_env_edge.ids[2] }


## CF Core
data "aws_subnets" "ocfp_subnets_env_core" {
  depends_on = [aws_subnet.dev-cf-core-0, aws_subnet.dev-cf-core-1, aws_subnet.dev-cf-core-2 ]       # Specific to codex
  filter {
    name   = "tag:Name"
    values = ["${var.aws_vpc_name}-dev-cf-core-*"]
  }
}

data "aws_subnet" "ocfp_subnets_env_core_cidr_0" { id  = data.aws_subnets.ocfp_subnets_env_core.ids[0] }
data "aws_subnet" "ocfp_subnets_env_core_cidr_1" { id  = data.aws_subnets.ocfp_subnets_env_core.ids[1] }
data "aws_subnet" "ocfp_subnets_env_core_cidr_2" { id  = data.aws_subnets.ocfp_subnets_env_core.ids[2] }


## CF Runtime
data "aws_subnets" "ocfp_subnets_env_runtime" {
  depends_on = [aws_subnet.dev-cf-runtime-0, aws_subnet.dev-cf-runtime-1, aws_subnet.dev-cf-runtime-2 ]       # Specific to codex
  filter {
    name   = "tag:Name"
    values = ["${var.aws_vpc_name}-dev-cf-runtime-*"]
  }
}

data "aws_subnet" "ocfp_subnets_env_runtime_cidr_0" { id  = data.aws_subnets.ocfp_subnets_env_runtime.ids[0] }
data "aws_subnet" "ocfp_subnets_env_runtime_cidr_1" { id  = data.aws_subnets.ocfp_subnets_env_runtime.ids[1] }
data "aws_subnet" "ocfp_subnets_env_runtime_cidr_2" { id  = data.aws_subnets.ocfp_subnets_env_runtime.ids[2] }



data "aws_security_group" "rds-security-group" {

  depends_on = [aws_security_group.cf-db]       # Specific to codex

  filter {
    name   = "tag:Name"
    #values = ["db-access-postgres"]  #T
    values = ["${var.aws_vpc_name}-cf-db"]
  }
}

data "aws_security_group" "default-security-group" {

  depends_on = [aws_security_group.wide-open]       # Specific to codex

  filter {
    name   = "tag:Name"
    #values = ["default"]   #T
    values = ["${var.aws_vpc_name}-wide-open"]
  }
}


#TODO: Add this to T side
data "aws_subnets" "aws_rds_subnets" {

  depends_on = [aws_subnet.dev-cf-db-0, aws_subnet.dev-cf-db-1, aws_subnet.dev-cf-db-2 ]  # Specific to codex

  filter {
    name   = "tag:Name"
    #values = ["app-aws-managed-*"]   #T
    values = ["${var.aws_vpc_name}-dev-cf-db-*"]   
  }
}



################################################################################
# Configure bastion
################################################################################

module "bastion" {
    source = "github.com/cweibel/terraform-module-bastion.git?ref=0.0.8"


    #T Uses
    #resource_tags             = var.resource_tags
    #vpc_id                    = var.vpc_id
    #bastion_security_group_id = module.sg-mgmt.ocfp_mgmt_bastion_sg_id


    aws_region                 = var.aws_region
    aws_key_name               = var.aws_key_name
    aws_key_file               = var.aws_key_file
    vpc_security_group_ids     = [aws_security_group.dmz.id, module.sg-mgmt.ocfp_mgmt_bastion_sg_id] 
    subnet_id                  = aws_subnet.dmz.id
    resource_tags              = var.resource_tags

}


output "box-bastion-public" { value = module.bastion.box-bastion-public }


################################################################################
# Security Group for Management BOSH - Used by Bastion, Vault and Blacksmith
################################################################################

module "sg-mgmt" {
    source = "github.com/cweibel/terraform-module-mgmt-sg.git?ref=0.0.1"

    resource_tags = var.resource_tags
    vpc_id        = coalesce(var.vpc_id, aws_vpc.default.id)
    aws_s3_cidrs  = var.aws_s3_cidrs
    env_cidrs     = var.env_cidrs
    private_cidrs = var.private_cidrs
}

################################################################################
# Security Group for Environment BOSH - Used by CF
################################################################################

module "sg-env" {
    source = "github.com/cweibel/terraform-module-env-sg.git?ref=0.0.3"

    resource_tags = var.resource_tags
    vpc_id        = coalesce(var.vpc_id, aws_vpc.default.id)
    aws_s3_cidrs  = var.aws_s3_cidrs
    env_cidrs     = var.env_cidrs
    private_cidrs = var.private_cidrs

}



################################################################################
# RDS Subnet Group 
################################################################################
resource "aws_db_subnet_group" "rds-db-subnet-group" {
  name       = "rds-subnet-group"
  subnet_ids = data.aws_subnets.aws_rds_subnets.ids
  tags       = merge({Name = "rds-subnet-group"}, var.resource_tags )
}



################################################################################
# ProtoBOSH RDS DB
################################################################################

module "mgmt_bosh_rds" {
    source = "github.com/cweibel/terraform-module-rds.git?ref=0.0.3"
    count  = var.enable_mgmt ? 1 : 0

    rds_instance_name        = var.rds_instance_name_mgmt_bosh
    resource_tags            = var.resource_tags
    rds_security_group_id    = data.aws_security_group.rds-security-group.id
    kms_rds_key_by_arn_arn   = aws_kms_key.default-kms-key.arn                  #T: data.aws_kms_key.kms_rds_key_by_arn.arn 
    rds_db_subnet_group_name = aws_db_subnet_group.rds-db-subnet-group.name
    instance_class           = "db.t3.small"
}

################################################################################
# Concourse RDS DB
################################################################################

module "mgmt_concourse_rds" {
    source = "github.com/cweibel/terraform-module-rds.git?ref=0.0.3"
    count  = var.enable_mgmt ? 1 : 0

    rds_instance_name        = var.rds_instance_name_mgmt_concourse
    resource_tags            = var.resource_tags
    rds_security_group_id    = data.aws_security_group.rds-security-group.id
    kms_rds_key_by_arn_arn   = aws_kms_key.default-kms-key.arn                  #T: data.aws_kms_key.kms_rds_key_by_arn.arn 
    rds_db_subnet_group_name = aws_db_subnet_group.rds-db-subnet-group.name
    instance_class           = "db.t3.small"
}


################################################################################
# Environment BOSH RDS DB
################################################################################

module "env_bosh_rds" {
    source = "github.com/cweibel/terraform-module-rds.git?ref=0.0.3"
    count  = var.enable_env ? 1 : 0

    rds_instance_name        = var.rds_instance_name_env_bosh
    resource_tags            = var.resource_tags
    rds_security_group_id    = data.aws_security_group.rds-security-group.id
    kms_rds_key_by_arn_arn   = aws_kms_key.default-kms-key.arn                  #T: data.aws_kms_key.kms_rds_key_by_arn.arn 
    rds_db_subnet_group_name = aws_db_subnet_group.rds-db-subnet-group.name
    instance_class           = "db.t3.small"                                    # Added for codex


}

################################################################################
# Environment CF RDS DB
################################################################################

module "env_cf_rds" {
    source = "github.com/cweibel/terraform-module-rds.git?ref=0.0.3"
    count  = var.enable_env ? 1 : 0

    rds_instance_name        = var.rds_instance_name_env_cf
    resource_tags            = var.resource_tags
    rds_security_group_id    = data.aws_security_group.rds-security-group.id
    kms_rds_key_by_arn_arn   = aws_kms_key.default-kms-key.arn                  #T: data.aws_kms_key.kms_rds_key_by_arn.arn 
    rds_db_subnet_group_name = aws_db_subnet_group.rds-db-subnet-group.name
    instance_class           = "db.t3.small"                                    # Added for codex

}

################################################################################
# Environment Stratos RDS DB
################################################################################

module "env_stratos_rds" {
    source = "github.com/cweibel/terraform-module-rds.git?ref=0.0.3"
    count  = var.enable_env ? 1 : 0

    rds_instance_name        = var.rds_instance_name_env_stratos
    resource_tags            = var.resource_tags
    rds_security_group_id    = data.aws_security_group.rds-security-group.id
    kms_rds_key_by_arn_arn   = aws_kms_key.default-kms-key.arn                  #T: data.aws_kms_key.kms_rds_key_by_arn.arn 
    rds_db_subnet_group_name = aws_db_subnet_group.rds-db-subnet-group.name

    engine_version           = "10.18"  
    instance_class           = "db.t3.small"

}


################################################################################
# Environment Autoscaler RDS DB
################################################################################

module "env_autoscaler_rds" {
    source = "github.com/cweibel/terraform-module-rds.git?ref=0.0.3"
    count  = var.enable_env ? 1 : 0

    rds_instance_name        = var.rds_instance_name_env_autoscaler
    resource_tags            = var.resource_tags
    rds_security_group_id    = data.aws_security_group.rds-security-group.id
    kms_rds_key_by_arn_arn   = aws_kms_key.default-kms-key.arn                  #T: data.aws_kms_key.kms_rds_key_by_arn.arn 
    rds_db_subnet_group_name = aws_db_subnet_group.rds-db-subnet-group.name
    instance_class           = "db.t3.small"                                    # Added for codex

}


################################################################################
# ProtoBOSH Blobstore
################################################################################

module "proto-bosh-blobstore" {
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.2"
  count                = var.enable_mgmt ? 1 : 0

  name_prefix          = var.mgmt_blobstore_bucket_prefix
  force_destroy        = true
  name_suffix          = "s3-bosh"
  resource_tags        = merge(
    {Environment       = "${var.mgmt_blobstore_bucket_prefix}" },
    var.resource_tags
  )
}

################################################################################
# Env SHIELD Blobstore
################################################################################

module "env-shield-blobstore" {
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.2"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
  force_destroy        = true
  name_suffix          = "s3-shield"
  resource_tags        = merge(
    {Environment       = "${var.env_blobstore_bucket_prefix}" },
    var.resource_tags
  )
}

################################################################################
# Env BOSH Blobstore
################################################################################

module "env-bosh-blobstore" {
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.2"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
  force_destroy        = true
  name_suffix          = "s3-bosh"
  resource_tags        = merge(
    {Environment       = "${var.env_blobstore_bucket_prefix}" },
    var.resource_tags
  )
}


################################################################################
# CF App Packages Blobstore
################################################################################

module "app-packages-blobstore" {
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.2"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
  force_destroy        = true
  name_suffix          = "s3-app-packages"
  resource_tags        = merge(
    {Environment       = "${var.env_blobstore_bucket_prefix}" },
    var.resource_tags
  )
}

################################################################################
# CF Buildpacks Blobstore
################################################################################

module "buildpacks-blobstore" {
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.2"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
  force_destroy        = true
  name_suffix          = "s3-buildpacks"
  resource_tags        = merge(
    {Environment       = "${var.env_blobstore_bucket_prefix}" },
    var.resource_tags
  )
}

################################################################################
# CF Droplets Blobstore
################################################################################

module "droplets-blobstore" {
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.2"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
  force_destroy        = true
  name_suffix          = "s3-droplets"
  resource_tags        = merge(
    {Environment       = "${var.env_blobstore_bucket_prefix}" },
    var.resource_tags
  )
}

################################################################################
# CF Resources Blobstore
################################################################################

module "resources-blobstore" {
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.2"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
  force_destroy        = true
  name_suffix          = "s3-resources"
  resource_tags        = merge(
    {Environment       = "${var.env_blobstore_bucket_prefix}" },
    var.resource_tags
  )
}


################################################################################
# Vault LB 
################################################################################

module "vault-lb" {
    source                   = "github.com/cweibel/terraform-module-vault-lb.git?ref=0.0.11"

    count                    = var.enable_vault_lb || var.enable_mgmt ? 1 : 0

    subnet_ids               = data.aws_subnets.ocfp_subnets.ids 
    resource_tags            = var.resource_tags
    vpc_id                   = coalesce(var.vpc_id, aws_vpc.default.id)
    vault_domain             = var.vault_domain
    route53_zone_id          = var.route53_zone_id
    security_groups          = [data.aws_security_group.default-security-group.id, module.sg-mgmt.ocfp_mgmt_bosh_sg_id]
    vault_acm_arn            = var.vault_acm_arn

    enable_route_53          = 0
}


################################################################################
# Concourse LB 
################################################################################

module "concourse-lb" {
    source                   = "github.com/cweibel/terraform-module-concourse-lb.git?ref=0.0.5"

    count                    = var.enable_concourse_lb || var.enable_mgmt ? 1 : 0

    subnet_ids               = data.aws_subnets.ocfp_subnets.ids 
    resource_tags            = var.resource_tags
    vpc_id                   = coalesce(var.vpc_id, aws_vpc.default.id)
    concourse_domain         = var.concourse_domain
    route53_zone_id          = var.route53_zone_id
    security_groups          = [data.aws_security_group.default-security-group.id, module.sg-mgmt.ocfp_mgmt_bosh_sg_id]
    concourse_acm_arn        = var.concourse_acm_arn
    internal_lb              = false

    enable_route_53          = 0
}




################################################################################
# Blacksmith LB
################################################################################

module "blacksmith-lb" {
    source                   = "github.com/cweibel/terraform-module-blacksmith-lb.git?ref=0.0.4"

    count                    = var.enable_blacksmith_lb || var.enable_env ? 1 : 0

    subnet_ids               = data.aws_subnets.ocfp_subnets.ids
    resource_tags            = var.resource_tags
    vpc_id                   = coalesce(var.vpc_id, aws_vpc.default.id)
    blacksmith_domain        = var.blacksmith_domain
    route53_zone_id          = var.route53_zone_id
    security_groups          = [data.aws_security_group.default-security-group.id, module.sg-mgmt.ocfp_mgmt_bosh_sg_id, module.sg-env.ocfp_env_bosh_sg_id]
    system_acm_arn           = var.system_acm_arn

    enable_route_53          = 0
}



################################################################################
# CF SSH NLB
################################################################################

module "cf-ssh-lb" {
    source                   = "github.com/cweibel/terraform-module-cf-ssh-lb.git?ref=0.0.4"

    count                    = var.enable_cf_ssh_lb || var.enable_env ? 1 : 0

    subnet_ids               = data.aws_subnets.ocfp_subnets.ids
    resource_tags            = var.resource_tags
    vpc_id                   = coalesce(var.vpc_id, aws_vpc.default.id)
    ssh_domain               = var.ssh_domain
    route53_zone_id          = var.route53_zone_id
    internal_lb              = false

    enable_route_53          = 0
}


################################################################################
# CF TCP Router LB
################################################################################

module "cf-tcp-lb" {
    source                   = "github.com/cweibel/terraform-module-cf-tcp-lb.git?ref=0.0.3"

    count                    = var.enable_cf_tcp_lb || var.enable_env ? 1 : 0

    subnet_ids               = data.aws_subnets.ocfp_subnets.ids
    resource_tags            = var.resource_tags
    vpc_id                   = coalesce(var.vpc_id, aws_vpc.default.id)
    tcp_domain               = var.tcp_domain
    route53_zone_id          = var.route53_zone_id
    private_cidrs            = var.private_cidrs
    security_groups          = [ module.sg-env.ocfp_env_bosh_sg_id, data.aws_security_group.default-security-group.id, module.sg-env.cf_tcp_lb_security_group ]
    internal_lb              = true

    enable_route_53          = 0

}

################################################################################
# CF System & Apps LB
################################################################################

module "cf-system-apps-lb" {
    source                   = "github.com/cweibel/terraform-module-cf-system-app-lb.git?ref=0.0.2"

    count                    = var.enable_cf_system_app_lb || var.enable_env ? 1 : 0

    subnet_ids               = data.aws_subnets.ocfp_subnets.ids
    resource_tags            = var.resource_tags
    vpc_id                   = coalesce(var.vpc_id, aws_vpc.default.id)
    apps_domain              = var.apps_domain
    system_domain            = var.system_domain
    route53_zone_id          = var.route53_zone_id
    security_groups          = [ module.sg-env.ocfp_env_bosh_sg_id, data.aws_security_group.default-security-group.id ]
    apps_acm_arn             = var.apps_acm_arn
    system_acm_arn           = var.system_acm_arn
    internal_lb              = false

    enable_route_53          = 0

}


################################################################################
# SHIELD LB
################################################################################

module "shield-lb" {
    source                   = "github.com/cweibel/terraform-module-shield-lb.git?ref=0.0.2"
    count                    = var.enable_shield_lb || var.enable_env ? 1 : 0
 
    subnet_ids               = data.aws_subnets.ocfp_subnets.ids
    resource_tags            = merge({Environment = "cf"}, var.resource_tags)  # Got nailed by Sentinel
    vpc_id                   = coalesce(var.vpc_id, aws_vpc.default.id)
    shield_domain            = var.shield_domain
    route53_zone_id          = var.route53_zone_id
    security_groups          = [ module.sg-env.ocfp_env_bosh_sg_id, data.aws_security_group.default-security-group.id ]
    internal_lb              = false

    shield_acm_arn           = var.system_acm_arn

    enable_route_53          = 0

}




##################################################
## Key Pair
##################################################
 
# Each BOSH director needs an ec2 key pair which will be generated during kit `new` secrets generation,
# HOWEVER THE BOSH DIRECTOR DOESN'T CARE WHAT THE VALUE IS, JUST THAT THE KEY EXISTS, HENCE THE HARD CODING
 
resource "aws_key_pair" "mgmt_bosh" {
  count      = var.mgmt_bosh_key_pair_enabled
  key_name   = var.mgmt_bosh_key_pair_key_name     # NOTE: Genesis bosh kit codes the key name to 'vcap@' + '<genesis.env>' which is:
  public_key = var.mgmt_bosh_key_pair_public_key
  tags       = merge({Name = "${var.mgmt_bosh_key_pair_key_name}"}, var.resource_tags )
}
 
resource "aws_key_pair" "env_bosh" {
  count      = var.env_bosh_key_pair_enabled
  key_name   = var.env_bosh_key_pair_key_name
  public_key = var.env_bosh_key_pair_public_key
  tags       = merge({Name = "${var.env_bosh_key_pair_key_name}"}, var.resource_tags )
}




############### Configure users/dbs on RDS instances ###################


module "install-psql-on-bastion" {

    source                   = "github.com/cweibel/terraform-module-remote-exec-template-run-once.git?ref=0.0.1"
    template_name            = "templates/install-psql-on-bastion.tpl"
    template_vars            = {}
    rendered_file_name       = "install-psql-on-bastion.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


module "configure-bastion" {

    source                   = "github.com/cweibel/terraform-module-remote-exec-template-run-once.git?ref=0.0.1"
    template_name            = "templates/configure-bastion.tpl"
    template_vars            = {}
    rendered_file_name       = "configure-bastion.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}

module "rds-ca-cert-bastion" {
    depends_on = [module.configure-bastion]

    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/rds-ca"
    template_vars            = {}
    rendered_file_name       = "manifests/bosh/rds_ca"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


module "mgmt-configure-bosh-db" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template-run.git?ref=0.0.2"
    count                    = var.enable_mgmt ? 1 : 0
    template_name            = "templates/configure-bosh-db.tpl"
    template_vars            = {
                                    master_username         = "u${coalesce(one(module.mgmt_bosh_rds[*].rds_db_instance_dbuser), "none")}"
                                    master_password         = "p${coalesce(one(module.mgmt_bosh_rds[*].rds_db_instance_dbpass), "none")}"
                                    host                    = coalesce(one(module.mgmt_bosh_rds[*].rds_db_instance_dbhost), "none")
                                    uaa_username            = "uaa"
                                    credhub_username        = "credhub"
                                    bosh_username           = "bosh"
                                    uaa_password            = random_string.uaa-password.result
                                    credhub_password        = random_string.credhub-password.result
                                    bosh_password           = random_string.bosh-password.result
                               }
    rendered_file_name       = "configure-mgmt-bosh-db.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}




module "env-configure-bosh-db" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template-run.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/configure-bosh-db.tpl"
    template_vars            = {
                                    master_username         = "u${coalesce(one(module.env_bosh_rds[*].rds_db_instance_dbuser), "none")}"
                                    master_password         = "p${coalesce(one(module.env_bosh_rds[*].rds_db_instance_dbpass), "none")}"
                                    host                    = coalesce(one(module.env_bosh_rds[*].rds_db_instance_dbhost), "none")
                                    uaa_username            = "uaa"
                                    credhub_username        = "credhub"
                                    bosh_username           = "bosh"
                                    uaa_password            = random_string.uaa-password.result
                                    credhub_password        = random_string.credhub-password.result
                                    bosh_password           = random_string.bosh-password.result
                               }
    rendered_file_name       = "configure-env-bosh-db.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


module "env-configure-cf-db" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template-run.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/configure-cf-db.tpl"
    template_vars            = {
                                    master_username               = "u${coalesce(one(module.env_cf_rds[*].rds_db_instance_dbuser), "none")}"
                                    master_password               = "p${coalesce(one(module.env_cf_rds[*].rds_db_instance_dbpass), "none")}"
                                    host                          = coalesce(one(module.env_cf_rds[*].rds_db_instance_dbhost), "none")
                                    uaa_username                  = "uaa"
                                    credhub_username              = "credhub"
                                    cloud_controller_username     = "cloud_controller"
                                    diego_username                = "diego"
                                    network_connectivity_username = "network_connectivity"
                                    network_policy_username       = "network_policy"
                                    locket_username               = "locket"
                                    routing_api_username          = "routing_api"
                                    uaa_password                  = random_string.uaa-password.result
                                    credhub_password              = random_string.credhub-password.result
                                    cloud_controller_password     = random_string.cloud-controller-password.result
                                    diego_password                = random_string.diego-password.result
                                    network_connectivity_password = random_string.network-connectivity-password.result
                                    network_policy_password       = random_string.network-policy-password.result
                                    locket_password               = random_string.locket-password.result
                                    routing_api_password          = random_string.routing-api-password.result

                               }
    rendered_file_name       = "configure-env-cf-db.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


module "env-configure-autoscaler-db" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template-run.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/configure-autoscaler-db.tpl"
    template_vars            = {
                                    master_username         = "u${coalesce(one(module.env_autoscaler_rds[*].rds_db_instance_dbuser), "none")}"
                                    master_password         = "p${coalesce(one(module.env_autoscaler_rds[*].rds_db_instance_dbpass), "none")}"
                                    host                    = coalesce(one(module.env_autoscaler_rds[*].rds_db_instance_dbhost), "none")
                                    autoscaler_username     = "autoscaler"
                                    autoscaler_password     = random_string.autoscaler-password.result
                               }
    rendered_file_name       = "configure-env-autoscaler-db.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


module "env-configure-stratos-db" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template-run.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/configure-stratos-db.tpl"
    template_vars            = {
                                    master_username         = "u${coalesce(one(module.env_stratos_rds[*].rds_db_instance_dbuser), "none")}"
                                    master_password         = "p${coalesce(one(module.env_stratos_rds[*].rds_db_instance_dbpass), "none")}"
                                    host                    = coalesce(one(module.env_stratos_rds[*].rds_db_instance_dbhost), "none")
                                    stratos_username        = "stratos"
                                    stratos_password         = random_string.stratos-password.result
                               }
    rendered_file_name       = "configure-env-stratos-db.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}



module "env-configure-concourse-db" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template-run.git?ref=0.0.2"
    count                    = var.enable_mgmt ? 1 : 0
    template_name            = "templates/configure-concourse-db.tpl"
    template_vars            = {
                                    master_username         = "u${coalesce(one(module.mgmt_concourse_rds[*].rds_db_instance_dbuser), "none")}"
                                    master_password         = "p${coalesce(one(module.mgmt_concourse_rds[*].rds_db_instance_dbpass), "none")}"
                                    host                    = coalesce(one(module.mgmt_concourse_rds[*].rds_db_instance_dbhost), "none")
                                    concourse_username      = "concourse"
                                    concourse_password      = random_string.concourse-password.result
                               }
    rendered_file_name       = "configure-mgmt-concourse-db.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


module "mgmt-configure-vault-db" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/configure-vault.tpl"
    template_vars            = {
                                    proto_bosh_name = var.environment_nickname
                                    env_bosh_name   = "dev"
                                    bosh_rds_password = random_string.bosh-password.result
                                    credhub_rds_password = random_string.credhub-password.result
                                    uaa_rds_password       = random_string.uaa-password.result
                                    aws_access_key_s3      = var.aws_access_key_s3
                                    aws_secret_key_s3      = var.aws_secret_key_s3
                                    aws_access_key_bosh    = var.aws_access_key_bosh
                                    aws_secret_key_bosh    = var.aws_secret_key_bosh
                                    concourse_rds_password = random_string.concourse-password.result
                                    cf_autoscaler_rds_password = random_string.autoscaler-password.result
                               }
    rendered_file_name       = "configure-vault.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}



##########################################################################
# Render the environment manifests -  Management
##########################################################################

module "mgmt-vault-kit" {
    count                    = var.enable_mgmt ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/mgmt-vault-kit.tpl"
    template_vars            = {
                                  environment_nickname = var.environment_nickname
                                  vault_alb_target_group = coalesce(one(module.vault-lb[*].lb_name), "none")
    }
    rendered_file_name       = "manifests/vault/codex2.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}

module "mgmt-bosh-kit" {
    count                    = var.enable_mgmt ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/mgmt-bosh-kit.tpl"
    template_vars            = {
                                  environment_nickname  = var.environment_nickname
                                  aws_region = var.aws_region
                                  mgmt_bosh_sg_wide_open = aws_security_group.wide-open.id 
                                  mgmt_bosh_sg = module.sg-mgmt.ocfp_mgmt_bosh_sg_id
                                  mgmt_bosh_subnet = aws_subnet.global-infra-0.id
                                  aws_bosh_default_vm_type = "t3.small"
                                  mgmt_bosh_s3_bucket = coalesce(one(module.proto-bosh-blobstore[*].bucket_id),   "none")
                                  mgmt_bosh_rds_host =  coalesce(one(module.mgmt_bosh_rds[*].rds_db_instance_dbhost), "none")
                                  credhub_username = "credhub"
                                  bosh_username = "bosh"
                                  uaa_username =  "uaa"

                                  aws_kms_key = aws_kms_key.default-kms-key.arn 
                                }
    rendered_file_name       = "manifests/bosh/proto/codex2.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}


module "mgmt-concourse-kit" {
    count                    = var.enable_mgmt ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/mgmt-concourse-kit.tpl"
    template_vars            = {
                                  environment_nickname        = var.environment_nickname
                                  concourse_alb_domain        = var.concourse_domain
                                  concourse_network_name      = "concourse"
                                  concourse_web_node_count    = "1"
                                  concourse_worker_node_count = "3"
                                  concourse_azs               = "z1, z2, z3"
                                  concourse_alb_target_group  = coalesce(one(module.concourse-lb[*].lb_target_group_name),        "none")
                                  network = var.network

                                  concourse_alb_name     = coalesce(one(module.concourse-lb[*].lb_name), "none")

                                  concourse_rds_host         = coalesce(one(module.mgmt_concourse_rds[*].rds_db_instance_dbhost), "none")
                                  concourse_rds_port         = "5432"
                                  concourse_rds_db_name      = "atc"
                                  concourse_rds_db_user      = "concourse"
    }
    rendered_file_name       = "manifests/concourse/codex2.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}
module "mgmt-bosh-cloud-config" {
    count                    = var.enable_vault_lb || var.enable_mgmt ? 1 : 0

    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/mgmt-cloud-config.tpl"
    template_vars            = {
                              subnet_global_infra = "${aws_subnet.global-infra-0.id}"
                              aws_default_vm_instance_cloud_config = "t3.small"
                              aws_large_vm_instance_cloud_config = "t3.small"
                              aws_vault_vm_instance_cloud_config = "t3.small"
                              aws_concourse_worker_vm_instance_cloud_config = "t3.small"
                              aws_concourse_small_vm_instance_cloud_config  = "t3.small"

                              aws_az1 = "${var.aws_region}a"
                              aws_az2 = "${var.aws_region}a"
                              aws_az3 = "${var.aws_region}a"

                              vault_alb_tg_name = coalesce(one(module.vault-lb[*].lb_target_group_name),    "none")

                              concourse_alb_name     = coalesce(one(module.concourse-lb[*].lb_name),        "none")
                              concourse_alb_tg_name  = coalesce(one(module.concourse-lb[*].lb_target_group_name),        "none")

                              network            = var.network
                              subnet_dev_infra_1 = aws_subnet.dev-infra-0.id
                              subnet_dev_infra_2 = aws_subnet.dev-infra-1.id
                              subnet_dev_infra_3 = aws_subnet.dev-infra-2.id

#                              bosh_network_first_3_octets_subnet_0  = join( ".",   [split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_0.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_0.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_0.cidr_block)[2]])
#                              bosh_network_first_3_octets_subnet_1  = join( ".",   [split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_1.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_1.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_1.cidr_block)[2]])
#                              bosh_network_first_3_octets_subnet_2  = join( ".",   [split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_2.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_2.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_2.cidr_block)[2]])

                              }
    rendered_file_name       = "manifests/bosh/proto/cc.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}


################################################
##    Environment manifests, (non-management) ##
################################################

#####################
###  Cloud Config  ## 
#####################


module "env-bosh-cloud-config" {
    count                    = var.enable_vault_lb || var.enable_mgmt ? 1 : 0   #TODO: his needs another set of eyes

    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/env-cloud-config.tpl"
    template_vars            = {
                              subnet_dev_infra_0  = aws_subnet.dev-infra-0.id
                              subnet_dev_infra_1  = aws_subnet.dev-infra-1.id
                              subnet_dev_infra_2  = aws_subnet.dev-infra-2.id
                              subnet_cf_edge_0    = aws_subnet.dev-cf-edge-0.id
                              subnet_cf_edge_1    = aws_subnet.dev-cf-edge-1.id
                              subnet_cf_edge_2    = aws_subnet.dev-cf-edge-2.id
                              subnet_cf_core_0    = aws_subnet.dev-cf-core-0.id
                              subnet_cf_core_1    = aws_subnet.dev-cf-core-1.id
                              subnet_cf_core_2    = aws_subnet.dev-cf-core-2.id
                              subnet_cf_runtime_0 = aws_subnet.dev-cf-runtime-0.id
                              subnet_cf_runtime_1 = aws_subnet.dev-cf-runtime-1.id
                              subnet_cf_runtime_2 = aws_subnet.dev-cf-runtime-2.id
                              cf_system_tg        = coalesce(one(module.cf-system-apps-lb[*].lb_target_group_name),   "none")
                              cf_ssh_tg           = coalesce(one(module.cf-ssh-lb[*].lb_target_group_name),           "none")
                              cf_tcp_elb_name     = coalesce(one(module.cf-tcp-lb[*].lb_name),           "none")
                              shield_tg           = coalesce(one(module.shield-lb[*].lb_target_group_name),   "none")

                              aws_az1 = "${var.aws_region}a"
                              aws_az2 = "${var.aws_region}b"
                              aws_az3 = "${var.aws_region}c"

                              vault_alb_tg_name = coalesce(one(module.vault-lb[*].lb_target_group_name), "none")

                              concourse_alb_name     = coalesce(one(module.concourse-lb[*].lb_name), "none")
                              concourse_alb_tg_name  = coalesce(one(module.concourse-lb[*].lb_target_group_name), "none")
                              network            = var.network


                              }
    rendered_file_name       = "manifests/bosh/env/cc.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}



module "env-bosh-cloud-config-v2" {

    # Note to future self, this isn't used yet, the problem is the azs need to match the subnets and there are 4 groups of subnets with
    # no guaranteed order.  For now, revert back to the original until I come up with a better idea.


    count                    = var.enable_vault_lb || var.enable_mgmt ? 1 : 0   #TODO: his needs another set of eyes

    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/env-cloud-config-v2.tpl"
    template_vars            = {
                              subnet_dev_infra_0  = data.aws_subnets.ocfp_subnets_env_infra.ids[0]
                              subnet_dev_infra_1  = data.aws_subnets.ocfp_subnets_env_infra.ids[1]
                              subnet_dev_infra_2  = data.aws_subnets.ocfp_subnets_env_infra.ids[2]
                              subnet_cf_edge_0    = data.aws_subnets.ocfp_subnets_env_edge.ids[0]
                              subnet_cf_edge_1    = data.aws_subnets.ocfp_subnets_env_edge.ids[1]
                              subnet_cf_edge_2    = data.aws_subnets.ocfp_subnets_env_edge.ids[2]
                              subnet_cf_core_0    = data.aws_subnets.ocfp_subnets_env_core.ids[0]
                              subnet_cf_core_1    = data.aws_subnets.ocfp_subnets_env_core.ids[1]
                              subnet_cf_core_2    = data.aws_subnets.ocfp_subnets_env_core.ids[2]
                              subnet_cf_runtime_0 = data.aws_subnets.ocfp_subnets_env_runtime.ids[0]
                              subnet_cf_runtime_1 = data.aws_subnets.ocfp_subnets_env_runtime.ids[1]
                              subnet_cf_runtime_2 = data.aws_subnets.ocfp_subnets_env_runtime.ids[2]
                              cf_system_tg        = coalesce(one(module.cf-system-apps-lb[*].lb_target_group_name),   "none")
                              cf_ssh_tg           = coalesce(one(module.cf-ssh-lb[*].lb_target_group_name),           "none")


                              first_3_octets_subnet_dev_infra_0      =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_0.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_0.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_0.cidr_block)[2]])
                              first_3_octets_subnet_dev_infra_1      =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_1.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_1.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_1.cidr_block)[2]])
                              first_3_octets_subnet_dev_infra_2      =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_2.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_2.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_2.cidr_block)[2]])
                              first_3_octets_subnet_cf_edge_0        =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_edge_cidr_0.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_edge_cidr_0.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_edge_cidr_0.cidr_block)[2]])
                              first_3_octets_subnet_cf_edge_1        =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_edge_cidr_1.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_edge_cidr_1.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_edge_cidr_1.cidr_block)[2]])
                              first_3_octets_subnet_cf_edge_2        =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_edge_cidr_2.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_edge_cidr_2.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_edge_cidr_2.cidr_block)[2]])
                              first_3_octets_subnet_cf_core_0        =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_core_cidr_0.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_core_cidr_0.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_core_cidr_0.cidr_block)[2]])
                              first_3_octets_subnet_cf_core_1        =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_core_cidr_1.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_core_cidr_1.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_core_cidr_1.cidr_block)[2]])
                              first_3_octets_subnet_cf_core_2        =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_core_cidr_2.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_core_cidr_2.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_core_cidr_2.cidr_block)[2]])
                              first_3_octets_subnet_cf_runtime_0     =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_runtime_cidr_0.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_runtime_cidr_0.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_runtime_cidr_0.cidr_block)[2]])
                              first_3_octets_subnet_cf_runtime_1     =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_runtime_cidr_1.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_runtime_cidr_1.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_runtime_cidr_1.cidr_block)[2]])
                              first_3_octets_subnet_cf_runtime_2     =  join( ".", [split(".", data.aws_subnet.ocfp_subnets_env_runtime_cidr_2.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_runtime_cidr_2.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_runtime_cidr_2.cidr_block)[2]])


                              aws_az1 = "${var.aws_region}a"
                              aws_az2 = "${var.aws_region}b"
                              aws_az3 = "${var.aws_region}c"

                              vault_alb_tg_name = coalesce(one(module.vault-lb[*].lb_target_group_name), "none")

                              concourse_alb_name     = coalesce(one(module.concourse-lb[*].lb_name), "none")
                              concourse_alb_tg_name  = coalesce(one(module.concourse-lb[*].lb_target_group_name), "none")
                              network            = var.network


                              }
    rendered_file_name       = "manifests/bosh/env/cc-v2.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}

####### Bosh Kit (Environment) ######

module "env-bosh-kit" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/env-bosh-kit.tpl"
    template_vars            = {
                              environment_nickname  = "codex2"
                              aws_region = var.aws_region
                              bosh_network_first_3_octets  =  "10.7.16" # join( ".",   [split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_0.cidr_block)[0], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_0.cidr_block)[1], split(".", data.aws_subnet.ocfp_subnets_env_infra_cidr_0.cidr_block)[2]])
                              env_bosh_sg_wide_open = aws_security_group.wide-open.id 
                              env_bosh_sg = module.sg-env.ocfp_env_bosh_sg_id
                              env_bosh_s3_bucket = coalesce(one(module.env-bosh-blobstore[*].bucket_id),   "none")
                              env_bosh_rds_host =  coalesce(one(module.env_bosh_rds[*].rds_db_instance_dbhost), "none")
                              credhub_username = "credhub"
                              bosh_username = "bosh"
                              uaa_username =  "uaa"

                              aws_kms_key = aws_kms_key.default-kms-key.arn 
                                }
    rendered_file_name       = "manifests/bosh/env/dev.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}

########## CF Kit ###########

module "env-cf-kit" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/env-cf-kit.tpl"
    template_vars            = {
                              environment_nickname  = "dev"
                              cf_base_domain        = var.base_domain
                              cf_system_domain      = var.system_domain
                              cf_apps_domains        = var.apps_domain
                              aws_region            = var.aws_region
                              cf_s3_app_packages    = coalesce(one(module.app-packages-blobstore[*].bucket_id), "none")
                              cf_s3_buildpacks      = coalesce(one(module.buildpacks-blobstore[*].bucket_id),"none")
                              cf_s3_droplets        = coalesce(one(module.droplets-blobstore[*].bucket_id), "none")
                              cf_s3_resources       = coalesce(one(module.resources-blobstore[*].bucket_id), "none")
                              cf_rds_host           = coalesce(one(module.env_cf_rds[*].rds_db_instance_dbhost), "none")
                              cf_rds_ccdb_password      = random_string.cloud-controller-password.result
                              cf_rds_diego_password     = random_string.diego-password.result
                              cf_rds_netpolicy_password = random_string.network-policy-password.result
                              cf_rds_silkdb_password    = random_string.network-connectivity-password.result
                              cf_rds_credhub_password   = random_string.credhub-password.result
                              cf_rds_locketdb_password  = random_string.locket-password.result
                              cf_rds_uaa_password       = random_string.uaa-password.result
                              cf_rds_routingdb_password = random_string.routing-api-password.result
                              cf_rds_credhub_user         = "credhub"
                              cf_rds_uaa_user             = "uaa"
                              cf_rds_ccdb_user            = "cloud_controller"
                              cf_rds_diego_user           =  "diego"
                              cf_rds_netpolicy_user       = "network_policy"
                              cf_rds_silkdb_user          = "network_connectivity"
                              cf_rds_routingdb_user       = "routing_api"
                              cf_rds_locketdb_user        = "locket"
                              stratos_domain              = var.stratos_domain
                              #### Instance Counts
                              cf_api_instance_count = 1
                              cf_ccworker_instance_count = 1
                              cf_credhub_instance_count = 1
                              cf_diegoapi_instance_count = 1
                              cf_doppler_instance_count = 1
                              cf_logapi_instance_count = 1
                              cf_nats_instance_count = 1
                              cf_router_instance_count = 1
                              cf_scheduler_instance_count = 1
                              cf_tcprouter_instance_count = 1
                              cf_uaa_instance_count = 1
                              cf_diegocell_instance_count = 1
                              cf_windows_diegocell_instance_count = 0
                            ### Refer to the cloud config, for VM type
                              cf_windows_diegocell_vm_type = "cell"
                              cf_api_vm_type = "small-cf"
                              cf_ccworker_vm_type = "small-cf"
                              cf_credhub_vm_type = "small-cf"
                              cf_diegoapi_vm_type = "small-cf"
                              cf_diegocell_vm_type = "cell"
                              cf_doppler_vm_type = "small-cf"
                              cf_nats_vm_type = "small-cf"
                              cf_logapi_vm_type = "small-cf"
                              cf_router_vm_type = "small-cf"
                              cf_errand_vm_type = "small-cf"
                              cf_scheduler_vm_type = "small-cf"
                              cf_tcp_router_vm_type = "small-cf"
                              cf_uaa_vm_type = "small-cf"
                                }
    rendered_file_name       = "manifests/cf/dev.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}

module "env-cf-autoscaler-kit" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/env-cf-autoscaler-kit.tpl"
    template_vars            = {
                              #cf_deployment_name = "${var.environment_nickname}-cf"
                              environment_nickname = "dev" 
                              cf_deployment_env    = "dev"
                              autoscaler_db_host   = coalesce(one(module.env_autoscaler_rds[*].rds_db_instance_dbhost), "none")
                              autoscaler_db_username = "autoscaler"
                              env_bosh_name        = "dev"
    }
    rendered_file_name       = "manifests/autoscaler/dev.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}

module "configure-env-cf-credhub" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/configure-env-cf-credhub.tpl"
    template_vars            = {
                               aws_secret_key_s3 = var.aws_secret_key_s3
                               aws_access_key_s3 = var.aws_access_key_s3
                               }
    rendered_file_name       = "configure-env-cf-credhub.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


#####################
##  Ops Files   ##
#####################

###### CF 

module "env-cf-ops-scale-to-3-azs" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/scale-to-3-az.tpl"
    template_vars            = {}
    rendered_file_name       = "manifests/cf/ops/scale-to-3-az.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}

module "env-cf-ops-config-server-client" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/config-server-client.tpl"
    template_vars            = {}
    rendered_file_name       = "manifests/cf/ops/config-server-client.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}

module "env-cf-ops-smb-volume-services-release" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/smb-volume-services-release.tpl"
    template_vars            = {}
    rendered_file_name       = "manifests/cf/ops/smb-volume-services-release.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}
module "env-cf-ops-encrypt-cf-db-connections" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/encrypt-cf-db-connections.tpl"
    template_vars            = {}
    rendered_file_name       = "manifests/cf/ops/encrypt-cf-db-connections.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}
module "env-cf-ops-nfs-version" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/nfs-version.tpl"
    template_vars            = {}
    rendered_file_name       = "manifests/cf/ops/nfs-version.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}
module "env-cf-ops-custom-router-group-ports" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/custom-router-group-ports.tpl"
    template_vars            = {}
    rendered_file_name       = "manifests/cf/ops/custom-router-group-ports.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}
module "env-cf-ops-windows-bosh-dns-alias" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/windows-bosh-dns-alias.tpl"
    template_vars            = {
                              #cf_deployment_name = "${var.environment_nickname}-cf"
                              cf_deployment_name = "dev-cf"
    }
    rendered_file_name       = "manifests/cf/ops/windows-bosh-dns-alias.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}
module "env-cf-ops-windows-smoke-tests" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/windows-smoke-tests.tpl"
    template_vars            = {
                              #cf_deployment_name = "${var.environment_nickname}-cf"
                              cf_base_domain = var.base_domain
    }
    rendered_file_name       = "manifests/cf/ops/windows-smoke-tests.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}


module "env-cf-ops-apps-trust-rds" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/apps-trust-rds.tpl"
    template_vars            = {}
    rendered_file_name       = "manifests/cf/ops/apps-trust-rds.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}

##### CF Autoscaler
module "env-cf-autoscaler-ops-release-versions-lock" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/release-versions-lock.tpl"
    template_vars            = {}
    rendered_file_name       = "manifests/autoscaler/ops/release-versions-lock.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}
module "env-cf-autoscaler-ops-loggregator-agent" {
    count                    = var.enable_env ? 1 : 0
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    template_name            = "templates/ops/loggregator-agent.tpl"
    template_vars            = {
                              cf_bosh_name = "dev-bosh"
                              cf_deployment_name = "dev-cf" 
    }
    rendered_file_name       = "manifests/autoscaler/ops/loggregator-agent.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)
}

##### TCP Router Custom Ports 
module "configure-cf-tcp-routing-ports" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/configure-cf-tcp-routing-ports.tpl"
    template_vars            = {
                               tcp_domain = var.tcp_domain
                               }
    rendered_file_name       = "configure-env-cf-tcp-routing-ports.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


##### Deploy Stratos 

module "configure-stratos-app-manifest" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/configure-stratos-app-manifest.tpl"
    template_vars            = {
                               stratos_domain     = var.stratos_domain
                               system_api_domain  = var.system_api_domain

                               }
    rendered_file_name       = "manifests/stratos/manifest.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


module "configure-stratos" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/configure-stratos.tpl"
    template_vars            = {
                               stratos_db_host     = coalesce(one(module.env_stratos_rds[*].rds_db_instance_dbhost), "none")
                               stratos_db_username = "stratos"
                               stratos_db_password = random_string.stratos-password.result


                               }
    rendered_file_name       = "configure-stratos.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


##### Deploy SHIELD 

module "configure-shield-kit" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/configure-shield-kit.tpl"
    template_vars            = {
                               shield_ip      = var.shield_ip       #TODO: Need a dynamic way of doing this
                               shield_domain  = var.shield_domain
                               web_username   = var.shield_web_username
                               web_password   = random_string.shield-password.result

                               }
    rendered_file_name       = "manifests/shield/dev.yml"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}


module "init-shield" {
    source                   = "github.com/cweibel/terraform-module-remote-exec-template.git?ref=0.0.2"
    count                    = var.enable_env ? 1 : 0
    template_name            = "templates/init-shield.tpl"
    template_vars            = {
                               shield_ip      = var.shield_ip       #TODO: Need a dynamic way of doing this
                               shield_domain  = var.shield_domain
                               admin_username =                        "ubuntu"
                               shield_environment =                    var.environment_nickname
                               shield_binary_version =                 var.shield_binary_version
                               master_password =                       random_string.shield-master-password.result
                               web_username =                          var.shield_web_username
                               web_password =                          random_string.shield-password.result
                               }
    rendered_file_name       = "init-shield.sh"
    host                     = module.bastion.box-bastion-public
    ssh_private_key          = file(var.aws_key_file)

}






