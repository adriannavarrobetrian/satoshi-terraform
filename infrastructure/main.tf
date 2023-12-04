locals {
  bucket_name     = "${var.bucket_origin}-${var.environment}-${random_string.this.id}"
  bucket_log_name = "${var.bucket_origin}-${var.environment}-log-${random_string.this.id}"
  endpoints       = toset(["auth", "info", "customers"])
}

data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}
resource "random_string" "this" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  for_each = local.endpoints
  bucket   = module.s3_bucket["${each.key}"].s3_bucket_id

  policy = <<-EOT
  {
          "Version": "2008-10-17",
          "Id": "PolicyForCloudFrontPrivateContent",
          "Statement": [
              {
                  "Sid": "AllowCloudFrontServicePrincipal",
                  "Effect": "Allow",
                  "Principal": {
                      "Service": "cloudfront.amazonaws.com"
                  },
                  "Action": "s3:GetObject",
                  "Resource": "arn:aws:s3:::${module.s3_bucket["${each.key}"].s3_bucket_id}/*",
                  "Condition": {
                      "StringEquals": {
                        "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${module.cdn["${each.key}"].cloudfront_distribution_id}"
                      }
                  }
              }
          ]
        }
  EOT
}

resource "aws_s3_object" "object" {
  for_each = local.endpoints
  bucket = module.s3_bucket["${each.key}"].s3_bucket_id

  key    = "${each.key}/index.html"
  source = "index.html"
  content_type = "text/html"
  etag = filemd5("index.html")
}

module "s3_bucket" {
  for_each = local.endpoints
  source   = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.bucket_name}-${each.key}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  versioning = {
    enabled = true
  }
  force_destroy = true

  tags = merge(var.default_tags, {
    OWNER = "Satoshi"
    }
  )
}
module "cloudfront_log_bucket" {
  for_each = local.endpoints
  source   = "terraform-aws-modules/s3-bucket/aws"

  bucket                   = "${local.bucket_log_name}-${each.key}"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.current.id
    }, {
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
    }
  ]

  owner = {
    id = data.aws_canonical_user_id.current.id
  }

  force_destroy = true
  versioning = {
    enabled = true
  }
  tags = merge(var.default_tags, {
    OWNER = "Satoshi"
    }
  )
}

module "cdn" {
  for_each = local.endpoints
  source   = "terraform-aws-modules/cloudfront/aws"

  #aliases = ["cdn.example.com"]

  comment             = "CloudFront ${each.key}"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_control = true
  origin_access_control = {
    "${each.key}" = {
      description      = "CloudFront ${each.key} access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  logging_config = {
    bucket = module.cloudfront_log_bucket["${each.key}"].s3_bucket_bucket_domain_name
  }

  origin = {
    originid = {
      domain_name           = module.s3_bucket["${each.key}"].s3_bucket_bucket_regional_domain_name
      origin_access_control = "${each.key}" # key in `origin_access_control`
      origin_path           = "/${each.key}"
    }

  }
  default_root_object = "index.html"
  default_cache_behavior = {
    target_origin_id       = "originid"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true
  }

  tags = merge(var.default_tags, {
    OWNER = "Satoshi"
    }
  )
}