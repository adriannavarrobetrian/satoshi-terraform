output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = module.cdn["auth"].cloudfront_distribution_domain_name
}

output "cloudfront_distribution_domain_names" {
  description = "The domain name corresponding to the distribution."
  value       = { for k, v in module.cdn : k => v.cloudfront_distribution_domain_name }
}
