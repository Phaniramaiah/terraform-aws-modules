variable "name" {
  description = "Service name; also used for the container, task family and log stream prefix."
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster to run the service in."
  type        = string
}

variable "image" {
  description = "Full image reference, for example 123456789012.dkr.ecr.ap-south-1.amazonaws.com/api:1.4.2."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP path used by the container and target group health checks."
  type        = string
  default     = "/health"
}

variable "cpu" {
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096)."
  type        = number
  default     = 512
}

variable "memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 1024
}

variable "cpu_architecture" {
  description = "X86_64 or ARM64 (Graviton, usually cheaper)."
  type        = string
  default     = "ARM64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "cpu_architecture must be X86_64 or ARM64."
  }
}

variable "environment" {
  description = "Plain environment variables. Never put secrets here; use var.secrets."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of environment variable name to Secrets Manager or SSM Parameter ARN."
  type        = map(string)
  default     = {}
}

variable "task_policy_arns" {
  description = "IAM policies the application itself needs (attached to the task role)."
  type        = list(string)
  default     = []
}

variable "read_only_root_filesystem" {
  description = "Run the container with a read-only root filesystem."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC of the service."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the tasks."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group of the ALB; only it may reach the containers."
  type        = string
}

variable "listener_arn" {
  description = "HTTPS listener to attach the routing rule to."
  type        = string
}

variable "listener_rule_priority" {
  description = "Unique priority of the listener rule."
  type        = number
}

variable "host_headers" {
  description = "Host names routed to this service, for example [\"api.example.com\"]."
  type        = list(string)
}

variable "min_count" {
  description = "Minimum (and initial) number of tasks."
  type        = number
  default     = 2
}

variable "max_count" {
  description = "Maximum number of tasks for autoscaling."
  type        = number
  default     = 6
}

variable "cpu_target_percent" {
  description = "Average CPU utilisation autoscaling tries to hold."
  type        = number
  default     = 60
}

variable "enable_execute_command" {
  description = "Allow `aws ecs execute-command` into running tasks."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags added to every resource."
  type        = map(string)
  default     = {}
}
