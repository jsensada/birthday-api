variable "project_id" {}

variable "machine_type" {
  description = "Machine type for the instances"
  default     = "e2-small"
}

variable "image_name" {
  description = "Compute image name for birthday-api"
  default     = "birthday-api-instance"
}

variable "instance_pool_size" {
  description = "Compute image name for birthday-api"
  default     = "birthday-api-instance"
}