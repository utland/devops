resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-base.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_network" "lab_network" {
  name      = "lab_network"
  mode      = "nat"
  domain    = "lab.local"
  addresses = ["10.0.10.0/24"]

  dns {
    enabled    = true
    local_only = false 
    forwarders {
      address = "8.8.8.8" 
    }
    forwarders {
      address = "1.1.1.1" 
    }
  }
}

resource "tls_private_key" "ansible_key" {
  algorithm = "ED25519"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ansible_key.private_key_openssh
  filename        = "${path.module}/../ansible/ansible_key.pem"
  file_permission = "0600"
  directory_permission = "0700"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.yml")
  vars = {
    ssh_key = tls_private_key.ansible_key.public_key_openssh
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
  pool      = "default"
}

# VM1: WORKER (Nginx + NodeApp)
resource "libvirt_volume" "worker_disk" {
  name           = "worker.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  pool           = "default"
  size           = 10737418240
}

resource "libvirt_domain" "worker" {
  name   = "worker-vm"
  memory = "1024"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_id     = libvirt_network.lab_network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.worker_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

# VM 2: DATABASE (Postgres)
resource "libvirt_volume" "db_disk" {
  name           = "db.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  pool           = "default"
  size           = 10737418240 
}

resource "libvirt_domain" "db" {
  name   = "db-vm"
  memory = "1024"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_id     = libvirt_network.lab_network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.db_disk.id
  }
}