variable "subscription" {
    type = string
}

variable "resource_group_name" {
    type    = string
    default = "nebo-app-rg"
}

variable "location" {
    type = string
}

variable "vnet_name" {
    type = string
}

variable "vnet_address_space" {
    type = string
}

variable "public_subnet_address_prefix" {
    type = string
}

variable "private_subnet_address_prefix" {
    type = string
}

variable "frontend_vm_name" {
    type = string
}

variable "backend_vm_name" {
    type = string
}

variable "database_vm_name" {
    type = string
}

variable "frontend_vm_size" {
    type = string
}

variable "backend_vm_size" {
    type = string
}

variable "database_vm_size" {
    type = string
}

variable "admin_username" {
    type = string
}

variable "to_public_key_path" {
    type = string
}

variable "to_private_key_path" {
    type = string
}

variable "publisher" {
    type = string
}

variable "offer" {
    type = string
}

variable "sku" {
    type = string
}

variable "image_version" {
    type = string
}

variable "storage_account_type" {
    type = string
}

variable "caching_type" {
    type = string
}

variable "database_name" {
  type        = string
}

variable "database_user" {
  type        = string
}

variable "database_password" {
  type        = string
  sensitive   = true
}
