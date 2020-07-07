#######################################################
# Azure Terraform - Infrastructure as a Code (IaC)
#  
# - Azure Kubernetes 
#    - Advance Networking - Azure CNI
#
#
# ----------------------------------------------------
#  Initial Configuration
# ----------------------------------------------------
# - Run this in Azure CLI
#   az login
#   az ad sp create-for-rbac -n "AzureTerraform" --role="Contributor" --scopes="/subscriptions/[SubscriptionID]"
#
# - Then complete the variables in the variables.tf file
#   - subscription_id  
#   - client_id  
#   - client_secret  
#   - tenant_id  
#   - ssh_public_key  
#
####################################################### 
#----------------------------------------------------
# Azure Terraform Provider
#----------------------------------------------------

provider "azurerm" { 
  features {}
  version = ">=2.0.0"  
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id 
}

data "azurerm_subscription" "primary" {}

#----------------------------------------------------
# Resource Group
#----------------------------------------------------

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group
  location = var.location
}


#----------------------------------------------------
# Application - Backend Server  
# azuread_application , azuread_service_principal , random_password , azuread_application_password
#----------------------------------------------------  
resource "azuread_application" "az-ad_app_server" {
  name                       = "az-ad_app_server"
  homepage                   = "https://az-ad_app_server"
  identifier_uris            = ["https://az-ad_app_server"]
  reply_urls                 = ["https://az-ad_app_server"]
  
  type                       = "webapp/api"
  group_membership_claims    = "All"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
  
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph - AppID
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"          # Microsoft Graph, Read directory data (Application Permission)
      type = "Role"
    }
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"          # Microsoft Graph, Read directory data (Delegated Permission)
      type = "Scope"
    }
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"          # Microsoft Graph, Sign in and read user profile
      type = "Scope"
    }	
  }
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000" # Azure AD - AppID
    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"          # Azure AD - Sign in and read user profile
      type = "Scope"
    }
  }
}
 
 
resource "azuread_service_principal" "az-ad_app_server" {
  application_id = azuread_application.az-ad_app_server.application_id
}

#resource "random_password" "az-ad_app_server" {
#  length  = 16
#  special = true
#}

resource "azuread_application_password" "az-ad_app_server" {
  application_object_id = azuread_application.az-ad_app_server.object_id 
  description           = "az-ad_app_server"
  value                 = "BdRPk~0s.IhE4DlByClzsRV-M4-3Sy1i6u" # random_password.az-ad_app_server.result        
  end_date              = "2025-02-01T01:02:03Z"
}

#----------------------------------------------------
# Application - Client Server  
# azuread_application, azuread_service_principal
#----------------------------------------------------
 
resource "azuread_application" "az-ad_app_client" {
  name                       = "az-ad_app_client"
  homepage                   = "https://az-ad_app_client"
  reply_urls                 = ["https://az-ad_app_client"]

  type                       = "webapp/api"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
  #public_client              = true
  
  required_resource_access {
    resource_app_id = azuread_application.az-ad_app_server.application_id
    resource_access {
      #id   = "${azuread_application.az-ad_app_server.oauth2_permissions.0.id}"
	  id   = [for permission in azuread_application.az-ad_app_server.oauth2_permissions : permission.id][0]
      type = "Scope"
    }	
  }
   
   
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph - AppID
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"          # Microsoft Graph, Read directory data (Application Permission)
      type = "Role"
    }
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"          # Microsoft Graph, Read directory data (Delegated Permission)
      type = "Scope"
    }
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"          # Microsoft Graph, Sign in and read user profile
      type = "Scope"
    }	
  } 
  
}

resource "azuread_service_principal" "az-ad_app_client" {
  application_id = azuread_application.az-ad_app_client.application_id
}

#----------------------------------------------------
# azuread_group
#---------------------------------------------------- 
resource "azuread_group" "az-ad_grp_admin" {
  name = "az-ad_grp_admin"
}

##----------------------------------------------------
## null_resource , Grant Admin Consent for server and client
##----------------------------------------------------
# 
#resource "null_resource" "az-null_resource01" {
#  provisioner "local-exec" {
#    command = "sleep 60"
#  }
#  depends_on = [
#    azuread_service_principal.az-ad_app_server,
#    azuread_service_principal.az-ad_app_client
#  ]
#}

##--------------------------------------
## Grant Admin Consent for server

#resource "null_resource" "az-null_resource022" {  
#  provisioner "local-exec" {
#    command = "az ad app permission admin-consent --id 27d932c2-4e20-4a66-a24f-67b1dcde3cea" #${azuread_application.az-ad_app_server.application_id}"
#    #command = "az ad app permission grant --id azuread_application.az-ad_app_server.application_id --api 00000003-0000-0000-c000-000000000000" # --scope Directory.Read.All Directory.ReadWrite.All"
#    #command = "az ad app permission grant --id azuread_application.az-ad_app_server.application_id --api 00000003-0000-0000-c000-000000000000 --scope user_impersonation --consent-type AllPrincipals"
#	 #command = "az ad app permission grant --id 27d932c2-4e20-4a66-a24f-67b1dcde3cea --api 00000003-0000-0000-c000-000000000000 --scope user_impersonation --consent-type AllPrincipals"
#	}
#  depends_on = [
#    null_resource.az-null_resource01
#  ]
#}


##--------------------------------------
## Grant Admin Consent for client


#resource "null_resource" "az-null_resource033" { # Grant Admin Consent for client
#  provisioner "local-exec" {
#    command = "az ad app permission admin-consent --id fc5c66c2-77ba-4c5d-8f7b-95a4740070d5" # ${azuread_application.az-ad_app_client.application_id}"
#   # command = "az ad app permission grant --id azuread_application.az-ad_app_client.application_id --api 00000003-0000-0000-c000-000000000000" # --scope Directory.Read.All Directory.ReadWrite.All"
#   # command = "az ad app permission grant --id azuread_application.az-ad_app_client.application_id --api 00000003-0000-0000-c000-000000000000 --scope user_impersonation --consent-type AllPrincipals"
#   #  command = "az ad app permission grant --id fc5c66c2-77ba-4c5d-8f7b-95a4740070d5 --api 00000003-0000-0000-c000-000000000000 --scope user_impersonation --consent-type AllPrincipals"
#	
#   }
#  depends_on = [
#    null_resource.az-null_resource01
#  ]
#}

#resource "null_resource" "az-null_resource04" {
#  provisioner "local-exec" {
#    command = "sleep 60"
#  }
#  depends_on = [
#    null_resource.az-null_resource022,
#    null_resource.az-null_resource033
#  ]
#}
 
 
#----------------------------------------------------
# Virtual Networks
#----------------------------------------------------

resource "azurerm_virtual_network" "az-vnet01" {
  name                = "az-vnet01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = [var.virtual_network_address_prefix]
 
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_subnet" "az-k8s-subnet" {
  name                 = "az-k8s-subnet" 
  virtual_network_name = azurerm_virtual_network.az-vnet01.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefixes     = [var.aks_subnet_address_prefix]
}

resource "azurerm_subnet" "az-apgw-subnet" {
  name                 = "az-apgw-subnet"
  virtual_network_name = azurerm_virtual_network.az-vnet01.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefixes     = [var.app_gateway_subnet_address_prefix]
}


#----------------------------------------------------
# Public Ip (Port 80)
#---------------------------------------------------- 

resource "azurerm_public_ip" "az-pip01" {
  name                = "az-pip01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}
 
#----------------------------------------------------
# Public Ip (Port 443)
#---------------------------------------------------- 

resource "azurerm_public_ip" "az-pip02" {
  name                = "az-pip02"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}
  
#----------------------------------------------------
# azurerm_log_analytics_workspace , azurerm_log_analytics_solution
#----------------------------------------------------
   
resource "azurerm_log_analytics_workspace" "azaksloganalytics01" {
  name                = "azaksloganalytics01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard"
}


resource "azurerm_log_analytics_solution" "azakslogsolution01" {
    solution_name         = "ContainerInsights"
    location              = azurerm_resource_group.resource_group.location
    resource_group_name   = azurerm_resource_group.resource_group.name

    workspace_resource_id = azurerm_log_analytics_workspace.azaksloganalytics01.id
    workspace_name        = azurerm_log_analytics_workspace.azaksloganalytics01.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
	
	depends_on = [
    azurerm_log_analytics_workspace.azaksloganalytics01 
  ]
}


#----------------------------------------------------
# azurerm_kubernetes_cluster
#----------------------------------------------------
  
resource "azurerm_kubernetes_cluster" "az-k8s" {
  name                = "az-k8s"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  
  addon_profile {
    http_application_routing {
      enabled = false
    }
	oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.azaksloganalytics01.id
        }
  }
  
  default_node_pool {
    name                 = "agentpool"
    node_count           = var.node_count
	max_pods             = var.max_pods
    vm_size              = var.vm_size
    os_disk_size_gb      = var.aks_agent_os_disk_size
    vnet_subnet_id       = azurerm_subnet.az-k8s-subnet.id
		
    enable_auto_scaling  = var.autoscale
    #node_count          = var.autoscale_node_count
    max_count            = var.autoscale_max_count 
    min_count            = var.autoscale_min_count
  }
 
  
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
  
  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = var.aks_dns_service_ip
    docker_bridge_cidr = var.aks_docker_bridge_cidr
    service_cidr       = var.aks_service_cidr
  }
  
  role_based_access_control {
    azure_active_directory {
      client_app_id     = azuread_application.az-ad_app_client.application_id
      server_app_id     = azuread_application.az-ad_app_server.application_id
      server_app_secret = azuread_application_password.az-ad_app_server.value          
      tenant_id         = var.tenant_id  
    }
    enabled = true
  }
   
  
  depends_on = [
    azurerm_virtual_network.az-vnet01,
    azuread_service_principal.az-ad_app_server,
	azuread_application.az-ad_app_client,
	azurerm_log_analytics_solution.azakslogsolution01	 
  ]
}
