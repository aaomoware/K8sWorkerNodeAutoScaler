terraform {
  required_version = "~> 0.10"
}

provider "aws" {
  region = "${var.region}"
}
