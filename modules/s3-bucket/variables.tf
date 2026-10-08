variable "bucket_name" {
  description = "Globally unique bucket name."
  type        = string
}

variable "versioning" {
  description = "Keep previous versions of objects."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional customer-managed KMS key. Uses SSE-S3 (AES256) when null."
  type        = string
  default     = null
}

variable "transition_to_ia_days" {
  description = "Move objects to STANDARD_IA after this many days."
  type        = number
  default     = 30
}

variable "transition_to_glacier_days" {
  description = "Move objects to Glacier Instant Retrieval after this many days."
  type        = number
  default     = 90

  validation {
    condition     = var.transition_to_glacier_days > var.transition_to_ia_days
    error_message = "transition_to_glacier_days must be greater than transition_to_ia_days."
  }
}

variable "expire_after_days" {
  description = "Delete current objects after this many days. 0 keeps them forever."
  type        = number
  default     = 0
}

variable "noncurrent_version_expiry_days" {
  description = "Delete previous object versions after this many days."
  type        = number
  default     = 60
}

variable "force_destroy" {
  description = "Allow terraform destroy to delete a non-empty bucket. Keep false in production."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags added to every resource."
  type        = map(string)
  default     = {}
}
