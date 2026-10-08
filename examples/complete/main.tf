terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }

  # Remote state with native S3 locking (Terraform >= 1.10). Supply values with
  #   terraform init -backend-config=backend.hcl
  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

locals {
  name = "${var.project}-${var.environment}"
}

module "vpc" {
  source = "../../modules/vpc"

  name               = local.name
  cidr_block         = "10.20.0.0/16"
  az_count           = 2
  single_nat_gateway = var.environment != "prod"
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = ["${var.project}/api"]
}

module "assets" {
  source = "../../modules/s3-bucket"

  bucket_name                = "${local.name}-assets-${data.aws_caller_identity.current.account_id}"
  transition_to_ia_days      = 30
  transition_to_glacier_days = 120
}

module "alb" {
  source = "../../modules/alb"

  name                = local.name
  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = module.vpc.vpc_cidr_block
  public_subnet_ids   = module.vpc.public_subnet_ids
  certificate_arn     = var.certificate_arn
  deletion_protection = var.environment == "prod"
}

module "cluster" {
  source = "../../modules/ecs-cluster"

  name                = local.name
  fargate_spot_weight = var.environment == "prod" ? 0 : 3
}

module "api" {
  source = "../../modules/ecs-service"

  name         = "api"
  cluster_name = module.cluster.name
  image        = "${module.ecr.repository_urls["${var.project}/api"]}:${var.api_image_tag}"

  environment = {
    APP_ENV = var.environment
  }
  secrets = var.api_secret_arns

  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  alb_security_group_id  = module.alb.security_group_id
  listener_arn           = module.alb.https_listener_arn
  listener_rule_priority = 10
  host_headers           = [var.api_hostname]

  min_count = var.environment == "prod" ? 2 : 1
  max_count = var.environment == "prod" ? 8 : 2
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.api_hostname
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
