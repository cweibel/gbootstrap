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

variable "enable_route_53"          { default = 0 }  # Set to 1 to enable, use for Codex because DNS is managed with CloudFlare



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

variable "vault_acm_arn"       {default = "arn:aws:acm:us-west-2:034222900717:certificate/246b1c98-3ecf-488e-9a9f-eb4d849553aa"}     # (required), https://us-east-1.console.aws.amazon.com/acm/home?region=us-east-1#/certificates/list
variable "system_acm_arn"      {default = "arn:aws:acm:us-west-2:034222900717:certificate/1b513c9d-01b0-403d-aa0b-4550b7482f31"}     # (required)
variable "apps_acm_arn"        {default = "arn:aws:acm:us-west-2:034222900717:certificate/1b513c9d-01b0-403d-aa0b-4550b7482f31"}     # (required)
variable "concourse_acm_arn"   {default = "arn:aws:acm:us-west-2:034222900717:certificate/98b71339-5d08-468e-b043-976f083bacf1"}     # (required), https://us-east-1.console.aws.amazon.com/acm/home?region=us-east-1#/certificates/list




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

  depends_on = [aws_subnet.dev-lb-edge-0, aws_subnet.dev-lb-edge-1 ]       # Specific to codex

  filter {
    name   = "tag:Name"
    #values = ["app-ec2-*"]    #T:
    values = ["${var.aws_vpc_name}-dev-lb-edge-*"]
  }
}

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
    source = "github.com/cweibel/terraform-module-bastion.git?ref=0.0.6"


    #T Uses:
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
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.1"
  count                = var.enable_mgmt ? 1 : 0

  name_prefix          = var.mgmt_blobstore_bucket_prefix
  name_suffix          = "s3-bosh"
  resource_tags        = merge(
    {Environment       = "${var.mgmt_blobstore_bucket_prefix}" },
    var.resource_tags
  )
}


################################################################################
# Env BOSH Blobstore
################################################################################

module "env-bosh-blobstore" {
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.1"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
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
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.1"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
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
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.1"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
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
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.1"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
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
  source               = "github.com/cweibel/terraform-module-s3.git?ref=0.0.1"
  count                = var.enable_env ? 1 : 0

  name_prefix          = var.env_blobstore_bucket_prefix
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
    source                   = "github.com/cweibel/terraform-module-vault-lb.git?ref=0.0.10"

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
    source                   = "github.com/cweibel/terraform-module-concourse-lb.git?ref=0.0.4"

    count                    = var.enable_concourse_lb || var.enable_mgmt ? 1 : 0

    subnet_ids               = data.aws_subnets.ocfp_subnets.ids 
    resource_tags            = var.resource_tags
    vpc_id                   = coalesce(var.vpc_id, aws_vpc.default.id)
    concourse_domain         = var.concourse_domain
    route53_zone_id          = var.route53_zone_id
    security_groups          = [data.aws_security_group.default-security-group.id, module.sg-mgmt.ocfp_mgmt_bosh_sg_id]
    concourse_acm_arn        = var.concourse_acm_arn

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
    source                   = "github.com/cweibel/terraform-module-cf-ssh-lb.git?ref=0.0.3"

    count                    = var.enable_cf_ssh_lb || var.enable_env ? 1 : 0

    subnet_ids               = data.aws_subnets.ocfp_subnets.ids
    resource_tags            = var.resource_tags
    vpc_id                   = coalesce(var.vpc_id, aws_vpc.default.id)
    ssh_domain               = var.ssh_domain
    route53_zone_id          = var.route53_zone_id

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

    enable_route_53          = 0

}

################################################################################
# CF System & Apps LB
################################################################################

module "cf-system-apps-lb" {
    source                   = "github.com/cweibel/terraform-module-cf-system-app-lb.git?ref=0.0.1"

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

    enable_route_53          = 0

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


