# AWS Variables
variable "aws_ami_id" {
  type = string
}
variable "aws_instance_type" {
  type = string
}
variable "aws_key_name" {
  type = string
}
variable "aws_key_location" {
  type = string
}


# Azure Variables
variable "location" {
  type = string
}
variable "vm_size" {
  type = string
}
variable "admin_username" {
  type = string
}
variable "azure_private_key" {
  type = string
}
variable "azure_public_key" {
  type = string
}