resource "google_compute_instance" "gitlab" {
  name         = "gitlab"
  machine_type = var.gitlab_machine_type
  zone         = "europe-west4-a"
  tags         = ["gitlab"]
  # boot disk definition
  boot_disk {
    initialize_params {
      image = var.gitlab_disc_image
      size = 50
    }
  }
  # network interface definition
  network_interface {
    # network this interface to be attached
    network = "default"
    # we'll use ephemeral IP to have access from the Internet
    access_config {}
  }
  metadata = {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }
  #connection {
  #  type  = "ssh"
  #  host  = google_compute_instance.app.network_interface.0.access_config.0.nat_ip
  #  user  = "appuser"
  #  agent = true
  #  # т.к. был создан ключ с паролем, используется опция agent, взаимоисключающая с private_key
  #  #private_key = "${file(var.provision_key_path)}"
  #}
  #provisioner "file" {
  #  source      = "files/puma.service"
  #  destination = "/tmp/puma.service"
  #}
  #provisioner "remote-exec" {
  #  script = "files/deploy.sh"
  #}
}

#resource "google_compute_firewall" "firewall-gitlab" {
#  name = "allow-gitlab-default"
#  # network where the rule applied
#  network = "default"
#  #
#  allow {
#    protocol = "tcp"
#    ports    = ["80", "443"]
#  }
#  # rule SRC tagss
#  source_tags = ["reddit-app"]
#  # rule target tags
#  target_tags = ["reddit-db"]
#}
