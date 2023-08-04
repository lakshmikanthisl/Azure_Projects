# Used to add shell files
data "template_file" "linux-vm-cloud-init" {
  template = file("apacheconfig.sh")
}

# Used to access SSH keys from Keyvault
data "azurerm_key_vault_secret" "mysecret" {
    name         = "id-rsa"
    key_vault_id = "/subscriptions/bf7a6566-c7d3-4936-b331-55a557799448/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/keyvault03082023"
}

resource "azurerm_linux_virtual_machine" "myvm" {
  name                  = var.vm_name
  computer_name         = var.vm_name
  location              = azurerm_resource_group.myrg.location
  resource_group_name   = azurerm_resource_group.myrg.name
  network_interface_ids = [azurerm_network_interface.mynic.id]
  size                  = "Standard_DS1_v2"
  admin_username        = "azureuser"
  custom_data           = base64encode(data.template_file.linux-vm-cloud-init.rendered)

  admin_ssh_key {
    username = "azureuser"
    public_key = data.azurerm_key_vault_secret.mysecret.value
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}