#print out the CloudFront distribution domain name to test access to index.html in origin bucket
output "cloudfront_distribution_domain_names" {
  description = "The domain name corresponding to the distribution."
  value       = { for k, v in module.cdn : k => v.cloudfront_distribution_domain_name }
}
