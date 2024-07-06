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

variable "is_prd" {
  type        = bool
  description = "Bool which decides whether it is a production environment."
  nullable    = false
}

variable "github_branch_front" {
  type        = string
  description = "Which branch to use for deployment"
  nullable    = false
}

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

variable "amplify_auth" {
  type        = string
  description = "Auth value used for connecting cloudfront to Amplify"
  nullable    = false
}

variable "amplify_default_domain" {
  type        = string
  description = "Default domain of the Amplify App."
  nullable    = false
}

variable "cloudfront_certificate_arn" {
  type        = string
  description = "ARN of the AWS Certificate Manager used for Cloudfront"
  nullable    = false
}

variable "cloudfront_hosted_zone_id" {
  type        = string
  description = "CloudFront Hosted Zone ID used for Alias record"
  nullable    = false
}
