output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = module.s3_bucket.s3_bucket_id
}


# output "cloudfront_origin_access_identities" {
#   description = "cloudfront_origin_access_identities."
#   value       = module.cdn.cloudfront_origin_access_identities.s3_bucket_one.iam_arn
# }

output "cloudfront_origin_access_controls" {
  description = "The origin access controls created"
  value       = module.cdn.cloudfront_origin_access_controls
}