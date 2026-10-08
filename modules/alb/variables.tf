variable "name" {
  description = "Name of the load balancer (max 32 characters are used)."
  type        = string
}

variable "vpc_id" {
  description = "VPC to place the load balancer in."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR of the VPC; the ALB may only forward traffic inside it."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets in at least two AZs."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "An ALB needs subnets in at least two availability zones."
  }
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener."
  type        = string
}

variable "ssl_policy" {
  description = "TLS policy for the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "allowed_cidrs" {
  description = "CIDRs allowed to reach the load balancer."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "access_logs_bucket" {
  description = "Optional S3 bucket for ALB access logs."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Protect the load balancer from accidental deletion."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags added to every resource."
  type        = map(string)
  default     = {}
}
