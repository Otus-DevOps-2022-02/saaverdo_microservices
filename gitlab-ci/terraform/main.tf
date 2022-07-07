provider "google" {
  project = var.project
  region  = var.region
}

module "gitlab" {
  source              = "./modules/gitlab"
  gitlab_machine_type = "e2-medium"
  public_key_path     = var.public_key_path
  gitlab_disc_image   = var.gitlab_disc_image
}

#module "vpc" {
#  source        = "../modules/vpc"
#  source_ranges = ["0.0.0.0/0"]
#}
