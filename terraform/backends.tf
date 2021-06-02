terraform {
  backend "s3" {
    bucket = "skyglass-terraform"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}
