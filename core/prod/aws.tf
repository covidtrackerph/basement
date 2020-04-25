provider "aws" {
  version = "~> 2.59.0"
  region  = var.region
}

terraform {
  backend "s3" {
    bucket         = "covidtrackerph-780046271874"
    dynamodb_table = "tfstate-lock"
    key            = "basement-core-prod.tfstate"
    region         = "ap-southeast-1"
  }
}
