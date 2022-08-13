# DevOpsND-Deploying-a-Web-Server-in-Azure
Udacity Nano Degree Program

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Dependencies
1. An [Azure Account](https://portal.azure.com) 
2. [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. [Packer](https://www.packer.io/downloads)
4. [Terraform](https://www.terraform.io/downloads.html)



## Azure Account ##
Udacity Azure account is used for this project and the user shouldbelogin to Azure to perform steps and run scripts

## Azure Policy ##
The first goal is to create the policy so taht it can be ensured that all indexed resources have tags and the resources that do nothave tags can be denied from deployment.
A policy template from [Azure Examples](https://github.com/Azure/Community-Policy/tree/master/Policies) is used. 

For the creation of the policy, the following commands are being used. 
```sh
az policy definition create --name tagging-policy --display-name 'tagging-policy:Deny untagged resources' --description 'Create a policy that ensures all indexed resources in a subscription have tags and deny deployment if they do not' --rules './require-tag-all-resources/azurepolicy.rules.json --mode indexed

az policy assignment create --name tagging-policy --scope /subscriptions/<id>/resourceGroups/Azuredevops --policy /subscriptions/<id>/providers/Microsoft.Authorization/policyDefinitions/tagging-policy

```

## Packer ##
To create the Packer image, the environment variables should be set which actually sets the user ID, secret key and subscription ID. The variables are the following Following variables need to set in environment: 
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_SUBSCRIPTION_ID
The Json file [server.json](./server.json) is used to build the image for virtual machine. 
The following command is used to build the image:
```sh
packer build server.json
```

## Terraform ##
To deploy the server image, Terraform is used to deploy it to virtual machines.        
### User Variables ###
[vars.tf](vars.tf) contains the user variables. As per the requirement, a condition is specified in this file which limits the virtual machines in the range of 2 and 5 In addition to it, the user must specify the username and password for the newly created virtual machines.

### Running the commands ###

Execute the following command to plan the deployment of image.
```
terraform plan -out <outfilename>
```

Finally, the given command deploy the images on virtual machines
```
terrform apply "<outfilename>"

```

### Network Security Group Rules ###
- *azurerm_network_security_rule.allowVNall* defines the rule to allow traffic to virtual network and it is specified in [main.tf](main.tf)

- In the same file, *azurerm_network_security_rule.denyhttpinbound*  and *azurerm_network_security_rule.denyhttpoutbound* can be found that deny the traffic to virtual network


## Expected Output ##

-For tagging policy expected output is:
![Alt text](./tagging-policy.PNG?raw=true "Tagging Policy screen capture")

-If this policy is violated this is expected:
![Alt text](./Deny.PNG?raw=true "Tagging Policy Checked")


- Sample output from terraform apply looks like :
![Alt text](./terraApply.PNG?raw=true "Terraform apply Output")

-All the created azure resources should look something like in this [Azureresources.csv](Azureresources.csv)
