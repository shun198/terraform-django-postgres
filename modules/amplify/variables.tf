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

variable "is_prd" {
  type        = bool
  description = "Bool which decides whether it is a production environment."
  nullable    = false
}

variable "alb_auth_header_name" {
  type        = string
  description = "Auth header name for the ALB to restrict access to our Amplify application."
  nullable    = false
}

variable "alb_auth_header_password" {
  type        = string
  description = "ALB Auth Header Password."
  nullable    = false
}

variable "cicd_topic_arn" {
  type        = string
  description = "CICD Topic Arn."
  nullable    = false
}

variable "github_access_token" {
  type        = string
  description = "Github access token used to connect to the repository."
  nullable    = false
}
