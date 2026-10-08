output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "task_role_arn" {
  description = "Role assumed by the application; grant it extra permissions as needed."
  value       = aws_iam_role.task.arn
}

output "log_group_name" {
  description = "CloudWatch Logs group for the containers."
  value       = aws_cloudwatch_log_group.this.name
}

output "target_group_arn" {
  description = "Target group the service registers into."
  value       = aws_lb_target_group.this.arn
}
