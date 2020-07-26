----------------------------------------------------------
# Azure Kubernetes Services (AKS) - Part 04
# Identity and Access Management through Azure AD and RBAC (Cluster Level)


High Level Architecture Diagram:


![Image description](https://github.com/GBuenaflor/01azure-aks-azure-ad-integration/blob/master/Images/GB-AKS-AzureAD01.png)


Configuration Flow :

------------------------------------------------------------------------------

1. Architect/Developer do a "kubectl get svc", prompts a URL to login to.

2. Once authenticated the Azure AD token issuance endpoint issues the access token.

3. Architect/Developer do a "kubectl get svc" again  with Azure AD Token.

4. Azure Kubernetes validates token with AAD and fetches the Developer’s AAD Groups

5. Azure Kubernetes RBAC and cluster policies are applied.


------------------------------------------------------------------------------
# 1. Provision Azure Environment using Azure Terraform

 
 
terraform init

terraform plan

terraform apply



------------------------------------------------------------------------------
# 1.1 Add user(s) in the new created Azure AD Group that will manage the AKS Cluster

![Image description](https://github.com/GBuenaflor/01azure-aks-azure-ad-integration/blob/master/Images/GB-AKS-AzureAD02.png)



------------------------------------------------------------------------------
# 1.2 Check and set the server and client app "Grant admin consent for Default Directory"



![Image description](https://github.com/GBuenaflor/01azure-aks-azure-ad-integration/blob/master/Images/GB-AKS-AzureAD03.png)

 

------------------------------------------------------------------------------
# 2. Deploy the kubernetes Files


az aks get-credentials --resource-group Env02-AD-Integration-RG -n az-k8s --admin 

cd clouddrive/Terraform-Azure-k8s-ActiveDirectory/K8sDeployment


kubectl apply --namespace default -f "01webandsql.yaml"
		
kubectl apply --namespace default -f "02RBAC.yaml"

kubectl apply --namespace default -f "02RBAC-ClusterRoleBinding.yaml"
  
   
  
------------------------------------------------------------------------------
# 3. Test the AKS connectivity

 
#  - Connect to Azure Kubernetes

az aks get-credentials --resource-group Env02-AD-Integration-RG -n az-k8s

 
 
#  -  Do a kubectl get svc , login using a user that is a member of Azure AD Group "az-ad_grp_admin"


![Image description](https://github.com/GBuenaflor/01azure-aks-azure-ad-integration/blob/master/Images/GB-AKS-AzureAD04.png)



 
#  -  Do a kubectl get svc , login with using a user that is not a member of Azure AD Group "az-ad_grp_admin"


![Image description](https://github.com/GBuenaflor/01azure-aks-azure-ad-integration/blob/master/Images/GB-AKS-AzureAD05.png)




#  -  Next Post: To implement the AKS Ingress controller using NGINX  go to this link:


https://github.com/GBuenaflor/01azure-aks-ingresscontroller-https




#  -  Next Post: To implement the AKS Ingress controller using Appplication Gateway go to this link:


https://github.com/GBuenaflor/01azure-aks-ingresscontroller-agic







Note: My Favorite > Microsoft Technologies.

