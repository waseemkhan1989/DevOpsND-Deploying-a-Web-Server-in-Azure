variable "numvm" {
  description = "The number of server vm to create.Please dont exceed 5 and minimum 2"
  type = number
  validation {
    condition     = var.numvm >= 2 && var.numvm <= 5
    error_message = "Accepted vms should be between 2 and 5."
  }
}
variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  type = string
  default = "DP-project#1"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type = string
  default = "eastus"
}
variable "username" {
  description = "User for the VM"
}
variable "password" {
  description = "The password for the user of the VM."
  
}