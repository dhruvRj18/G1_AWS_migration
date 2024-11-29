terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datasource
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.jumphost_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus  = var.jumphost_cpu
  memory    = var.jumphost_ram_mb
  firmware  = "efi"
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = 32
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.jumphost_name
        domain    = var.jumphost_domain
      }

      network_interface {
        ipv4_address = var.jumphost_ip
        ipv4_netmask = var.jumphost_netmask
      }

      ipv4_gateway = var.jumphost_gateway
      timeout      = 8
    }
  }

  connection {
    type     = "ssh"
    agent    = "false"
    host     = var.jumphost_ip
    user     = var.jumphost_user
    password = var.jumphost_password
  }

  # make script from template
  provisioner "file" {
    destination = "/tmp/run.sh"
    content = templatefile(
      "${path.module}/template_files/run_data.sh.tpl",
      {}
    )
  }

  # script that creates partition and filesystem for data disks
  provisioner "remote-exec" {
    inline = [
      "sleep 120",
      "chmod +x /tmp/run.sh",
      "sleep 120",
      "echo ${var.jumphost_password} | sudo -S /tmp/run.sh ${var.jumphost_name} ${var.jumphost_ip} > /tmp/run.log"
    ]
  }

}
