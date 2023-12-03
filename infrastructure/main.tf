data "aws_caller_identity" "current" {}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${random_string.bucket_suffix.result}-${var.bucket_origin}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}


resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id

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
                  "Resource": "arn:aws:s3:::${module.s3_bucket.s3_bucket_id}/*",
                  "Condition": {
                      "StringEquals": {
                        "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${module.cdn.cloudfront_distribution_id}"
                      }
                  }
              }
          ]
        }
  EOT
}

module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

  #aliases = ["cdn.example.com"]

  comment             = "Satoshi CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_control = true
  origin_access_control = {
  s3_oac = {
    description      = "CloudFront access to S3"
    origin_type      = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
  }
}

  # logging_config = {
  #   bucket = "logs-my-cdn.s3.amazonaws.com"
  # }

  origin = {
    auth = {
      domain_name = module.s3_bucket.s3_bucket_bucket_regional_domain_name
#      origin_access_control_id = aws_cloudfront_origin_access_control.default.id
      origin_access_control = "s3_oac" # key in `origin_access_control`

      # origin_id                = module.s3_bucket.s3_bucket_id
      # origin_path              = "/"
      # origin_protocol_policy   = "http-only"
      # origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      # origin_read_timeout      = 3

      # s3_origin_config = {
      #   origin_access_identity = "s3_bucket_one"
      # }
      # custom_origin_config = {
      #   http_port              = 80
      #   https_port             = 443
      #   origin_protocol_policy = "match-viewer"
      #   origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      # }
    }

    # s3_one = {
    #   domain_name = "my-s3-bycket.s3.amazonaws.com"
    #   s3_origin_config = {
    #     origin_access_identity = "s3_bucket_one"
    #   }
    # }
  }

  default_cache_behavior = {
    target_origin_id           = "auth"
    viewer_protocol_policy     = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "auth"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    }
  ]
}