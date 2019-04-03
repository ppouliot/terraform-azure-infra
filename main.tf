variable subscription_id {}
variable tenant_id {}
variable client_id {}
variable client_secret {}

# Configure Terraform State Storage
terraform {
  backend "azurerm" {
    storage_account_name  = "tstate31740"
    container_name        = "tstate"
    key                   = "terraform.tfstate"
  }
}

# AzureRM Provider
provider "azurerm" {
    version = "1.23"
    subscription_id = "${var.subscription_id}"
    tenant_id = "${var.tenant_id}"
    client_id = "${var.client_id}"
    client_secret = "${var.client_secret}"
}

data "azurerm_subscription" "current" {
  subscription_id = "${var.subscription_id}"
}

# dns_management resource group definitions
resource "azurerm_resource_group" "dns_management" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}


# =========================================== DNS 

resource "azurerm_dns_zone" "interoperable" {
  name                = "az.interoperable.systems"
  resource_group_name = "${azurerm_resource_group.dns_management.name}"
  zone_type           = "Public"
}

resource "azurerm_dns_cname_record" "gitops-interoperable" {
  name                = "gitops"
  zone_name           = "${azurerm_dns_zone.interoperable.name}"
  resource_group_name = "${azurerm_resource_group.dns_management.name}"
  ttl                 = 300
  record             = "ppouliot.github.io"
}

resource "azurerm_dns_a_record" "vm_dns" {
  count               = "2"
  name                = "${lookup(var.hostname, count.index)}"
  zone_name           = "${azurerm_dns_zone.interoperable.name}"
  resource_group_name = "${azurerm_resource_group.dns_management.name}"
  ttl                 = 300
  records             = ["${length(azurerm_public_ip.pip.*.id) > 0 ? element(concat(azurerm_public_ip.pip.*.ip_address, list("")), count.index) : ""}"]
  depends_on          = [
    "azurerm_virtual_machine.vm",
  ]
}

# =========================================== VMS

# resource group definitions
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

# Azure Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.resource_group}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Public Cloud Nodes"
  }
}

# Azure Public IP
resource "azurerm_public_ip" "pip" {
  name                         = "${var.rg_prefix}-ip${count.index}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method            = "Dynamic"
  count                        = "${var.count}"
}

# Cloud-Config
data "template_file" "cloud_config" {
  template = "${file("${path.module}/cloud-config.yml.tpl")}"
}

# Azure Network definition
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

# Azure Subnet Definition
resource "azurerm_subnet" "subnet" {
  name                 = "${var.rg_prefix}subnet${count.index}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_prefix}"
}

# Azure VM Network Interface
resource "azurerm_network_interface" "nic" {
  # name                = "nic${var.rg_prefix}${count.index}"
  name                = "primaryNic${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  count               = "${var.count}"
  depends_on          = ["azurerm_public_ip.pip"]

  ip_configuration {
    name                          = "ipconfig${var.rg_prefix}${count.index}"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${length(azurerm_public_ip.pip.*.id) > 0 ? element(concat(azurerm_public_ip.pip.*.id, list("")), count.index) : ""}" 
  }

  tags {
    environment = "Public Cloud"
  }

}

# Define VMs
resource "azurerm_virtual_machine" "vm" {
  name                             = "vm${count.index}"
  location                         = "${var.location}"
  resource_group_name              = "${azurerm_resource_group.rg.name}"
  vm_size                          = "${var.vm_size}"
  network_interface_ids            = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true
  count                            = "${var.count}"
  depends_on                       = ["azurerm_network_interface.nic"]

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name          = "${lookup(var.osdisk, count.index)}"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${lookup(var.hostname, count.index)}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    custom_data    = "${base64encode(data.template_file.cloud_config.rendered)}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
       path     = "/home/core/.ssh/authorized_keys"
       key_data = "${tls_private_key.azure_vms.public_key_openssh}"
    }
  }

}
# Create SSH Key
resource "tls_private_key" "azure_vms" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}


# =========================================== OUTPUT
output "Azure VM Public IP Addresses: " {
  value = "${azurerm_public_ip.pip.*.ip_address}"
}
output "Azure VM1 DNS Name: " {
  value = "${element(concat(azurerm_dns_a_record.vm_dns.*.name, list(" ")), 0)}.${element(concat(azurerm_dns_a_record.vm_dns.*.zone_name, list(" ")), 0)}"
}
output "Azure VM2 DNS Name: " {
  value = "${element(concat(azurerm_dns_a_record.vm_dns.*.name, list(" ")), 1)}.${element(concat(azurerm_dns_a_record.vm_dns.*.zone_name, list(" ")), 1)}"
}
output "Azure VM SSH Public Key" {
  value = "${tls_private_key.azure_vms.public_key_openssh}"
}
output "Azure VM SSH Private Key" {
  value = "${tls_private_key.azure_vms.private_key_pem}"
}
