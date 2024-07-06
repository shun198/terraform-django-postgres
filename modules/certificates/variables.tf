variable "project_name" {
  type        = string
  description = "Name of the project you are managing."
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

variable "domain" {
  description = "The domain to use with the project."
  type        = string
  nullable    = false
}

variable "zone_id" {
  type        = string
  description = "Route53 parent zone ID. This will create Route53 DNS records used for verification."
  default     = ""
  nullable    = false
}

variable "cloudfront_hosted_zone_id" {
  type        = string
  description = "CloudFront Hosted Zone ID used for Alias record"
  nullable    = false
}
