# variables.tf - Input variables for Fleetbase OCI deployment

# OCI Provider Authentication Variables
variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user calling the API"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint for the API key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file on your local machine"
  type        = string
}

variable "region" {
  description = "OCI region to deploy resources to"
  type        = string
}

# Compartment Variables
variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

# VCN Variables
variable "vcn_display_name" {
  description = "Display name for the VCN"
  type        = string
  default     = "fleetbase-vcn"
}

variable "vcn_cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN"
  type        = string
  default     = "fleetbasevcn"
}

# Subnet Variables
variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_display_name" {
  description = "Display name for the public subnet"
  type        = string
  default     = "fleetbase-public-subnet"
}

variable "public_subnet_dns_label" {
  description = "DNS label for the public subnet"
  type        = string
  default     = "fleetbasepubsub"
}

# Compute Instance Variables
variable "instance_display_name" {
  description = "Display name for the compute instance"
  type        = string
  default     = "fleetbase-server"
}

variable "instance_shape" {
  description = "Shape of the compute instance"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs for Flex shape"
  type        = number
  default     = 2
}

variable "instance_memory_in_gbs" {
  description = "Amount of memory in GB for Flex shape"
  type        = number
  default     = 12
}

variable "instance_image_id" {
  description = "OCID of the OS image to use for the compute instance"
  type        = string
  # Note: This needs to be set to an ARM-compatible image OCID for your region
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

# Security Rules Variables
variable "ingress_ports" {
  description = "List of ingress ports to allow"
  type        = list(number)
  default     = [22, 80, 443]
}
