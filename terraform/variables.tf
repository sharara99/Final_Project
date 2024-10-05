# Adding the region as a variable, used in provider.tf
variable "region" {
  type    = string 
  default = "us-east-1"
}

# Adding the ami as a variable, used in main.tf 
variable "ami" {
  type    = string 
  default = "ami-0866a3c8686eaeeba"
}

# Create terraform.tfvars and add your public ssh key in 
variable "public_key" {
  description = "ssh public key"
}