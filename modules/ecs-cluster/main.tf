terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
}

variable "name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "fargate_spot_weight" {
  description = "Relative weight of FARGATE_SPOT in the default capacity strategy. 0 disables Spot."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags added to every resource."
  type        = map(string)
  default     = {}
}

resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 1
  }

  dynamic "default_capacity_provider_strategy" {
    for_each = var.fargate_spot_weight > 0 ? [var.fargate_spot_weight] : []

    content {
      capacity_provider = "FARGATE_SPOT"
      weight            = default_capacity_provider_strategy.value
    }
  }
}

output "id" {
  description = "ID (ARN) of the cluster."
  value       = aws_ecs_cluster.this.id
}

output "name" {
  description = "Name of the cluster."
  value       = aws_ecs_cluster.this.name
}
