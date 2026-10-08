variable "repositories" {
  description = "ECR repository names to create, for example [\"api\", \"web\"]."
  type        = list(string)

  validation {
    condition     = length(var.repositories) > 0
    error_message = "Provide at least one repository name."
  }
}

variable "immutable_tags" {
  description = "Prevent image tags from being overwritten. Recommended for production."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional customer-managed KMS key. Uses AES256 when null."
  type        = string
  default     = null
}

variable "untagged_expiry_days" {
  description = "Delete untagged images after this many days."
  type        = number
  default     = 7
}

variable "keep_tagged_images" {
  description = "Number of most recent tagged images to keep."
  type        = number
  default     = 30
}

variable "pull_principal_arns" {
  description = "Extra AWS principals (for example other accounts) allowed to pull images."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags added to every resource."
  type        = map(string)
  default     = {}
}
