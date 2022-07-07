variable "public_key_path" {
  description = "Path to key for ssh access"
}

variable "gitlab_disc_image" {
  description = "Boot image for VM"
  default     = "minimal-2004-focal-v20220622"
}

variable "gitlab_machine_type" {
  description = "GCP machine type for VM"
}
