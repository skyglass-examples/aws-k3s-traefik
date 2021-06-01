terraform {
  backend "s3" {
    bucket = "skyglass-keycloak"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}
