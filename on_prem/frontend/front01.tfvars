# vcenter credentials
vsphere_user       = "administrator@vsphere.local"
vsphere_password   = "Vclass123$"
vsphere_server     = "10.173.65.104"
vsphere_datacenter = "HYBRID-DC"
vsphere_datasource = "datastore1"
vsphere_cluster    = "HYBRID-CL-01" # leave empty if no vcenter cluster
vsphere_network    = "Production"

# name of template
vsphere_template = "rocky2_template"
# OS template credentials
jumphost_user     = "root"
jumphost_password = "Secret55"

jumphost_name      = "hy-front01"
jumphost_vm_folder = "" # empty for root location
jumphost_domain    = "vclass.local"
jumphost_cpu       = "2"
jumphost_ram_mb    = "4096"
jumphost_ip        = "10.173.65.21"
jumphost_netmask   = "24"
jumphost_gateway   = "10.173.65.1"
dns_server_list    = ["10.173.65.100"]
dns_suffix_list    = ["vclass.local"]
