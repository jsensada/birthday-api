variable "project_id" {}
variable "zone" {
  default = "europe-southwest1-a"
}
variable "ssh_username" {
  default = "packer"
}

packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}


source "googlecompute" "ubuntu_image" {
  project_id          = var.project_id
  source_image_family = "ubuntu-2404-lts"
  zone                = var.zone
  ssh_username        = var.ssh_username
  machine_type        = "e2-medium"
  image_name          = "birthday-api-instance"
}

build {
  sources = ["source.googlecompute.ubuntu_image"]

  provisioner "file" {
    source = "files/birthday-api.service"
    destination = "/tmp/birthday-api.service"
  }
  provisioner "file" {
    source = "../../requirements.txt"
    destination = "/tmp/requirements.txt"
  }
  provisioner "file" {
    source = "../../app.py"
    destination = "/tmp/app.py"
  }
  provisioner "shell" {
    script = "files/customize.sh"
  }
}