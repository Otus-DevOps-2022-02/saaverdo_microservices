output "gitlab_external_ip" {
value = "${google_compute_instance.gitlab.network_interface.0.access_config.0.nat_ip}"
}
output "gitlab_internal_ip" {
value = "${google_compute_instance.gitlab.network_interface.0.network_ip}"
}
