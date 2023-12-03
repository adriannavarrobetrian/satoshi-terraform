locals {
  bucket_name     = "${var.bucket_origin}-${random_string.this.id}"
  bucket_log_name = "${var.bucket_origin}-log-${random_string.this.id}"
  region          = "eu-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

data "aws_iam_policy_document" "policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${module.cdn.cloudfront_distribution_id}"]
    }
  }
}

resource "random_string" "this" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  enable_key_rotation = true
  deletion_window_in_days = 7
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name
  acl    = "private"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  attach_policy            = true
  policy                   = data.aws_iam_policy_document.policy.json
  versioning = {
    enabled = true
  }
  tags = {
    Owner = "Satoshi"
  }
}
module "cloudfront_log_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket                   = local.bucket_log_name
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.current.id
    }, {
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id 
    }
  ]

  owner = {
    id = data.aws_canonical_user_id.current.id
  }

  force_destroy = true
  versioning = {
    enabled = true
  }
  tags = {
    Owner = "Satoshi"
  }
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
    auth = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  logging_config = {
    bucket = module.cloudfront_log_bucket.s3_bucket_bucket_domain_name
  }

  origin = {


    auth = { # with origin access control settings (recommended)
      domain_name           = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      origin_access_control = "auth" # key in `origin_access_control`
    }

  }
  default_root_object = "index.html"
  default_cache_behavior = {
    target_origin_id       = "auth"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  tags = {
    Owner = "Satoshi"
  }
}