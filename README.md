# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

The contents of this repo are part of the first project for the Azure devops nano degree program.

### Dependencies
1. An [Azure Account](https://portal.azure.com) 
2. [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Image creation with [Packer](https://www.packer.io/downloads)
4. Deployment with [Terraform](https://www.terraform.io/downloads.html)



## Azure Account ##
An azure account subscription id is required to make the scripts in this repo work.

## Azure Policy ##
Create a policy that ensures all indexed resources in your subscription have tags and deny deployment if they do not.
A policy template from [Azure Examples](https://github.com/Azure/Community-Policy/tree/master/Policies) is used. 
Policy mode Indexed, so the policy is only applied to resources that can be tagged.
Below are the commands used to define and assign the policy. 
```sh
az policy definition create --name tagging-policy --display-name 'tagging-policy:Deny untagged resources' --description 'Create a policy that ensures all indexed resources in a subscription have tags and deny deployment if they do not' --rules './require-tag-all-resources/azurepolicy.rules.json --mode indexed

az policy assignment create --name tagging-policy --scope /subscriptions/<id>/resourceGroups/Azuredevops --policy /subscriptions/<id>/providers/Microsoft.Authorization/policyDefinitions/tagging-policy

```

## Packer ##
[server.json](./server.json) file is used to build image of our server virtual machine. To run this file, Azure account details need to be placed in environment variables. Following variables need to set in environment: 
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_SUBSCRIPTION_ID

Image can be build using command:
```sh
packer build server.json
```

## Terraform ##
Terraform is used to deploy the server image created from packer to azure virtual machines.
### User Variables ###
User variables that need to be added are in [vars.tf](vars.tf). The number of virtual machines to be created must be provided. The user name and password for these virtual machines must also be provided.

The condition to check valid virtual machines number is applied. 
```
condition     = var.numvm >= 2 && var.numvm <= 5
error_message = "Accepted vms should be between 2 and 5."

```

### Running the commands ###

Run this command to plan out the deployment.
```
terraform plan -out <outfilename>
```

Run this command to deploy the infrastructure on azure
```
terrform apply "<outfilename>"

```

### Network Security Group Rules ###

- Rule to allow traffic within Virtual network named *azurerm_network_security_rule.allowVNall* can be found in [main.tf](main.tf)
- Rule to deny all outside http *azurerm_network_security_rule.denyhttpinbound*  and *azurerm_network_security_rule.denyhttpoutbound*  traffic can also be found in [main.tf](main.tf)


## Expected Output ##

-For tagging policy expected output is:
![Alt text](./tagging-policy.PNG?raw=true "Tagging Policy screen capture")

-If this policy is violated this is expected:
![Alt text](./Deny.PNG?raw=true "Tagging Policy Checked")


- Sample output from terraform apply looks like :
![Alt text](./terraApply.PNG?raw=true "Terraform apply Output")

-All the created azure resources should look something like in this [Azureresources.csv](Azureresources.csv)