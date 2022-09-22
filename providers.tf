# providers.tf
terraform {
  required_version = ">= 1.1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.70.0"
    }
  }
}
provider "aws" {
  region  = "eu-west-1"
  profile = "lab"
}

provider "aws" {
  alias   = "primary"
  region  = "eu-west-1"
  profile = "lab"
}

provider "aws" {
  alias   = "secondary"
  region  = "eu-central-1"
  profile = "lab"
}
