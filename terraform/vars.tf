variable "aws_account_id" {
  default = "048962136615"
}

variable "primary_aws_region" {
  default = "us-east-2"
}

variable "secondary_aws_region" {
  default = "us-east-1"
}

variable "aws_access_key" {
  type = string
  default = ""
  sensitive = true
}

variable "aws_secret_key" {
  type = string
  default = ""
  sensitive = true
}