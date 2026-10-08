variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Short project name used in resource names."
  type        = string
  default     = "shop"
}

variable "environment" {
  description = "dev, staging or prod."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "certificate_arn" {
  description = "ACM certificate covering api_hostname."
  type        = string
}

variable "hosted_zone_name" {
  description = "Route 53 public hosted zone, for example example.com."
  type        = string
}

variable "api_hostname" {
  description = "Public host name of the API, for example api.example.com."
  type        = string
}

variable "api_image_tag" {
  description = "Immutable image tag to deploy, usually the Git commit SHA."
  type        = string
}

variable "api_secret_arns" {
  description = "Map of env var name to Secrets Manager ARN injected into the API container."
  type        = map(string)
  default     = {}
}
