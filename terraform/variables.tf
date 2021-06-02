variable "aws_region" {
  default = "us-east-1"
}

variable "profile" {
  default = "default"
}

variable "access_ip" {}

#-------database variables

variable "dbname" {
  type = string
}

variable "dbuser" {
  type = string
}

variable "dbpassword" {
  type      = string
  sensitive = true
}

variable "public_key_path" {
  type      = string
  sensitive = true
}

variable "private_key_path" {
  type      = string
  sensitive = true
}

variable "certificate_arn" {
  type      = string
  sensitive = true
}