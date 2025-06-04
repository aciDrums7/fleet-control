# modules/compute/variables.tf - Compute module variables

variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for the compute instance"
  type        = string
}

variable "subnet_id" {
  description = "OCID of the subnet for the compute instance"
  type        = string
}

variable "instance_display_name" {
  description = "Display name for the compute instance"
  type        = string
}

variable "shape" {
  description = "Shape of the compute instance"
  type        = string
}

variable "ocpus" {
  description = "Number of OCPUs for Flex shape"
  type        = number
}

variable "memory_in_gbs" {
  description = "Amount of memory in GB for Flex shape"
  type        = number
}

variable "image_id" {
  description = "OCID of the OS image to use for the compute instance"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for accessing the compute instance"
  type        = string
}

variable "boot_volume_size_in_gbs" {
  description = "Size of the boot volume in GB"
  type        = number
  default     = 100
}
