output "resource_group_name" {
  value = azurerm_resource_group.aks-rg.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "vm_instance_ids" {
  value = data.azurerm_virtual_machine_scale_set.aks_vmss.instances[*].instance_id
  description = "The instance IDs of the VMs in the AKS node pool."
}

output "vm_private_ip_addresses" {
  value = data.azurerm_virtual_machine_scale_set.aks_vmss.instances[*].private_ip_address
  description = "The private IP addresses of the VMs in the AKS node pool."
}

output "vm_public_ip_addresses" {
  value = data.azurerm_virtual_machine_scale_set.aks_vmss.instances[*].public_ip_address
  description = "The public IP addresses of the VMs in the AKS node pool."
}
