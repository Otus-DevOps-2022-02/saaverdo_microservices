output "master_external_ip" {
value = "${google_compute_instance.k8-master.network_interface.0.access_config.0.nat_ip}"
}
output "master_internal_ip" {
value = "${google_compute_instance.k8-master.network_interface.0.network_ip}"
}
output "worker_external_ip" {
value = "${google_compute_instance.k8-worker.network_interface.0.access_config.0.nat_ip}"
}
output "worker_internal_ip" {
value = "${google_compute_instance.k8-worker.network_interface.0.network_ip}"
}
