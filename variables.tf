# ------------------------------
# Variables
# ------------------------------
variable "project_name" {
  type        = string
  description = "Name of the project you are managing."
  nullable    = false
}

variable "domain" {
  description = "The domain to use with the project."
  type        = string
  nullable    = false
}

variable "infra_environment" {
  description = "The environment used for creating the infrastructure."
  type        = string
  nullable    = false
  validation {
    condition     = contains(["dev", "stg", "prd"], var.infra_environment)
    error_message = "infra_environment must be one of the following: [dev, stg, prd]."
  }
}

# ------------------------------
# SES
# ------------------------------
variable "zone_id" {
  type        = string
  description = "Route53 parent zone ID. This will create Route53 DNS records used for verification."
  default     = ""
  nullable    = false
}

# ------------------------------
# VPC
# ------------------------------
variable "availability_zone_one" {
  type        = string
  description = "Availability Zone to use for deployment(1)."
  nullable    = false
}

variable "availability_zone_two" {
  type        = string
  description = "Availability Zone to use for deployment(2)."
  nullable    = false
}

# ------------------------------
# ALB
# ------------------------------
variable "alb_auth_header_name" {
  type        = string
  description = "Auth header name for the ALB to restrict access to our Amplify application."
  nullable    = false
}

# ------------------------------
# Frontend
# ------------------------------
variable "cache_policy_id" {
  type        = string
  description = "Cache policy to use for cloudfront. https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html"
  nullable    = false
}

variable "response_headers_policy_id" {
  type        = string
  description = "Response headers policy to use for cloudfront. https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html"
  nullable    = false
}

variable "amplify_username" {
  type        = string
  description = "Username for amplify authorization."
  nullable    = false
}

variable "amplify_password" {
  type        = string
  description = "Password for amplify authorization."
  nullable    = false
}

variable "github_access_token" {
  type        = string
  description = "Github access token used to connect to the repository."
  nullable    = false
}

variable "github_repository_front" {
  type        = string
  description = "Full path of the github repository for the frontend."
  nullable    = false
}

variable "github_branch_front" {
  type        = string
  description = "Which branch to use for deployment"
  nullable    = false
}

# ------------------------------
# Backend
# ------------------------------
variable "github_repository_back" {
  type        = string
  description = "Full path of the github repository for the backend."
  nullable    = false
}

variable "github_branch_back" {
  type        = string
  description = "Which branch to use for deployment"
  nullable    = false
}

