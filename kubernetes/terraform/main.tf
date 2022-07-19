provider "google" {
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "k8-master" {
  name         = "k8-master"
  machine_type = "e2-standard-4"
  zone         = "europe-west4-a"
  tags         = ["k8"]
  # boot disk definition
  boot_disk {
    initialize_params {
      image = var.default_disc_image
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
  #provisioner "local-exec" {
  #  command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' apache-install.yml"
  #}

}

resource "google_compute_instance" "k8-worker" {
  name         = "k8-worker"
  machine_type = "e2-standard-4"
  zone         = "europe-west4-a"
  tags         = ["k8"]
  # boot disk definition
  boot_disk {
    initialize_params {
      image = var.default_disc_image
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

resource "google_compute_firewall" "firewall-k8s-api" {
  name = "allow-k8s-api"
  # network where the rule applied
  network = "default"
  #
  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }
  # rule SRC tagss
  source_ranges = ["0.0.0.0/0"]
  # rule target tags
  target_tags = ["k8"]
}
