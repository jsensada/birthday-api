terraform {
  backend "gcs" {
    #bucket = "xxxxxxxx-tfstate" # To setup later
    prefix = "terraform/tfstate"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.30.0"
    }
  }
}