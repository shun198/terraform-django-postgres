# ------------------------------
# Terraform configuration
# ------------------------------
terraform {
  # tfstateファイルを管理するようbackend(s3)を設定
  backend "s3" {
    bucket         = "terraform-playground-for-cicd-shun198"
    key            = "terrafrom-playground.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-playground-tf-state-lock"
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
