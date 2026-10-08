output "api_url" {
  description = "Public URL of the API."
  value       = "https://${var.api_hostname}"
}

output "ecr_repository_urls" {
  description = "Push images here from CI."
  value       = module.ecr.repository_urls
}

output "assets_bucket" {
  description = "Private, encrypted bucket for application assets."
  value       = module.assets.bucket_id
}

output "nat_public_ips" {
  description = "Outbound IPs to allow-list with third parties."
  value       = module.vpc.nat_public_ips
}
