variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "The AWS access key"
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The AWS secret key"
  sensitive   = true
}
