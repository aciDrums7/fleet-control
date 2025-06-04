# modules/network/variables.tf - Network module variables

variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "vcn_display_name" {
  description = "Display name for the VCN"
  type        = string
}

variable "vcn_cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN"
  type        = string
}

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
