#----------------------------------------------------
#  Replace correct values or configure values in Azure DevOps variables :
#
#  - subscription_id  
#  - client_id  
#  - client_secret  
#  - tenant_id  
#  - ssh_public_key  
#  - access_key
#---------------------------------------------------- 

variable subscription_id {
      default = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"   
 }

variable client_id       {
      default = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"   # AzureTerraform 
 }

variable client_secret   {
      default = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"   # AzureTerraform 
 }

variable tenant_id       {
      default = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"  
 }
  
variable ssh_public_key {
   default = "azure_rsa.pub"
}  

#----------------------------------------------------
# Application ID from App Registration in Azure AD
#----------------------------------------------------

#variable "az-ad_app_server_application_id" { 
#  default     = "27d932c2-4e20-4a66-a24f-67b1dcde3cea"
#}


#variable "az-ad_app_client_application_id" { 
#  default     = "fc5c66c2-77ba-4c5d-8f7b-95a4740070d5"
#}

 
#----------------------------------------------------
# Azure Vnet Variables
#----------------------------------------------------
variable "virtual_network_address_prefix" { 
  default     = "15.0.0.0/8"
}

variable "aks_subnet_name" { 
  default     = "az-subnet"
}
 
variable "aks_subnet_address_prefix" { 
  default     = "15.0.0.0/16"
}

variable "app_gateway_subnet_address_prefix" { 
  default     = "15.1.0.0/16"
}

#----------------------------------------------------
# Azure Application Gateway Variables
#----------------------------------------------------

variable "app_gateway_sku" {
  description = "Name of the Application Gateway SKU."
  default     = "Standard_v2"
}

variable "app_gateway_tier" {
  description = "Tier of the Application Gateway SKU."
  default     = "Standard_v2"
} 

#----------------------------------------------------
# Azure Role's Variables
#----------------------------------------------------
 
variable "aks_service_principal_object_id" {
  description = "Object ID of the service principal."
  default     = "32a433cd-15ff-422c-b19e-79bafe8ac446" # AzureTerraform 
}
  
#----------------------------------------------------
# Azure AKS Variables
#----------------------------------------------------
    
variable environment {
    default = "Env01"
}

variable location {
    default = "eastus"
}

variable node_count {
  default = 2
}

variable max_pods {
  default = 50
}

variable dns_prefix {
  default = "aks01"
}

variable cluster_name {
  default = "aks01"
}

variable vm_size {
  default = "Standard_D3_v2" # "Standard_D2_v3" # "Standard_DS1_v2"
}


variable "autoscale" {
  default     = "true"
}

variable "autoscale_node_count" {
  default     = "2"
}

variable "autoscale_max_count" {
  default     = "3"
}

variable "autoscale_min_count" {
  default     = "2"
}
 

variable resource_group {
  default = "Env02-AD-Integration-RG"
}

variable "aks_agent_os_disk_size" {
  description = "Disk size (in GB), range from 0 to 1023. Specifying 0 - the default disk size."
  default     = 50
}

variable "aks_service_cidr" {
  default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" { 
  default     = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" { 
  default     = "172.17.0.1/16"
}

 