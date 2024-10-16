#In Azure, all infrastructure elements such as virtual machines, storage, and our Kubernetes cluster need to be attached to a resource group.

resource "azurerm_resource_group" "aks-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = "Standard_D2s_v3"
    type                = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet" 
  }
  
}
# Data source for the Kubernetes node pool
data "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  resource_group_name     = azurerm_resource_group.aks_rg.name
  kubernetes_cluster_name = azurerm_kubernetes_cluster.aks.name
  name                    = azurerm_kubernetes_cluster.aks.default_node_pool[0].name
}

# Data source for the VM Scale Set
data "azurerm_virtual_machine_scale_set" "aks_vmss" {
  name                = "aks-${azurerm_kubernetes_cluster.aks.name}-${data.azurerm_kubernetes_cluster_node_pool.node_pool.name}-vmss"
  resource_group_name = azurerm_resource_group.aks_rg.name
}

