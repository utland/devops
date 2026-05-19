output "worker_hosts" {
  value = [ libvirt_domain.worker.network_interface[0].addresses[0] ]
}

output "db_hosts" {
  value = [ libvirt_domain.db.network_interface[0].addresses[0] ]
}