variable "project" {
  description = "project ID"
}

variable "region" {
  description = "Region"
  default     = "europe-west4-a"
}

variable "public_key_path" {
  description = "Path to key for ssh access"
}

variable "disk_image" {
  description = "Disk image name"
  default     = "minimal-2004-focal-v20220622"
}

variable "provision_key_path" {
  description = "Path to key for provisioners access"
}

variable "app_disc_image" {
  description = "Boot image for VM"
  default     = "reddit-base-otus-app"
}

variable "db_disc_image" {
  description = "Boot image for VM"
  default     = "reddit-base-otus-db"
}

variable "gitlab_machine_type" {
  description = "GCP machine type for VM"
}

variable "gitlab_disc_image" {
  description = "Boot image for VM"
  default     = "minimal-"
}
