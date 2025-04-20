variable "project_id" {}

variable "region" {
  description = "Region to run the resources"
  default     = "europe-southwest1"
}

variable "machine_type" {
  description = "Machine type for the instances"
  default     = "e2-small"
}

variable "image_name" {
  description = "Compute image name for birthday-api"
  default     = "birthday-api"
}

variable "instance_pool_size" {
  description = "Compute image name for birthday-api"
  default     = 2
}