# ------------------------------
# Terraform configuration
# ------------------------------
terraform {
  # tfstateファイルを管理するようbackend(s3)を設定
  backend "s3" {
    bucket         = "terrafrom-practice-shun198"
    key            = "terrafrom-practice.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terrafrom-practice-tf-state-lock"
  }
  # プロバイダを設定
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  # Terraformのバージョン制約
  required_version = ">= 1.2.0"
}

# ------------------------------
# Provider
# ------------------------------
# プロバイダ(AWS)を指定
provider "aws" {
  region = "ap-northeast-1"
}

# ------------------------------
# Current AWS Region(ap-northeast-1)
# ------------------------------
# 現在のAWS Regionの取得方法
data "aws_region" "current" {}

module "certificates" {
  providers = {
    aws.default       = aws.default
    aws.global_region = aws.global_region
  }
  source                    = "./modules/certificates"
  project_name              = var.project_name
  infra_environment         = var.infra_environment
  domain                    = var.domain
  zone_id                   = var.zone_id
  cloudfront_hosted_zone_id = data.aws_route53_zone.amplify.zone_id
}

locals {
  az_one_name              = split("-", var.availability_zone_one)[2]
  az_two_name              = split("-", var.availability_zone_two)[2]
  alb_auth_header_password = base64encode(random_password.alb_password.result)
  amplify_auth             = base64encode("${var.amplify_username}:${var.amplify_password}")
  is_prd                   = var.infra_environment == "prd"
  sns_alert_name           = "shun198-alert"
  sns_warning_name         = "shun198-warning"
  sns_approve_name         = "shun198-approve"
  sns_security_name        = "shun198-security"
  sns_health_name          = "shun198-health"
  sns_cicd_name            = "shun198-cicd-pipeline"
  sns_config_name          = "shun198-config"
}

module "amplify" {
  source                   = "./modules/amplify"
  project_name             = var.project_name
  domain                   = var.domain
  infra_environment        = var.infra_environment
  amplify_username         = var.amplify_username
  amplify_password         = var.amplify_password
  github_repository_front  = var.github_repository_front
  github_branch_front      = var.github_branch_front
  is_prd                   = local.is_prd
  alb_auth_header_name     = var.alb_auth_header_name
  alb_auth_header_password = local.alb_auth_header_password
  cicd_topic_arn           = module.cicd.cicd_topic_arn
  github_access_token      = var.github_access_token
}

module "cloudfront" {
  source                     = "./modules/cloudfront"
  project_name               = var.project_name
  domain                     = var.domain
  infra_environment          = var.infra_environment
  is_prd                     = local.is_prd
  github_branch_front        = var.github_branch_front
  cache_policy_id            = var.cache_policy_id
  response_headers_policy_id = var.response_headers_policy_id
  amplify_auth               = local.amplify_auth
  amplify_default_domain     = module.amplify.amplify_default_domain
  cloudfront_certificate_arn = module.certificates.cloudfront_certificate_arn
  cloudfront_hosted_zone_id  = data.aws_route53_zone.amplify.zone_id
}
