terraform {
  backend "s3" {
    bucket = "s3-golunch-database"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}