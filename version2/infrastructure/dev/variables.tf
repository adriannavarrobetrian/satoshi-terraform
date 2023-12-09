variable "bucket_origin" {
  description = "Origin Bucket"
  type        = string
}
variable "environment" {
  description = "Origin Bucket"
  type        = string
}

variable "endpoints" {
  type = list(string)
}


variable "default_tags" {
  type    = map(string)
  default = {}
}
