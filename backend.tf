# backend.tf
terraform {
  backend "local" {
    path = "backend/terraform.tfstate"
  }
}
