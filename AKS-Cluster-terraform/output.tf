# output "vm_names" {
#   value = [
#     for instance in data.azurerm_virtual_machine_scale_set.aks_vmss.instance: instance.name
#   ]
# }

# output "resource_group_name" {
#   value = data.azurerm_virtual_machine_scale_set.aks_vmss.resource_group_name
# }