resource "aws_kms_key" "dynamo_db_kms" {
  enable_key_rotation = true
}

resource "aws_dynamodb_table" "terraform-lock" {
  name           = "terraform_state"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamo_db_kms.arn

  }
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}