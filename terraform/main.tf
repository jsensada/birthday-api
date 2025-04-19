terraform {
  backend "gcs" {
    bucket = "birthday-api-20250419-tfstate"
    prefix = "terraform/tfstate"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.30.0"
    }
  }
}