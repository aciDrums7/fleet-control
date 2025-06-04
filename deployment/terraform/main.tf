# main.tf - Main Terraform configuration file for Fleetbase OCI deployment

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.2.0"
    }
  }
  required_version = ">= 1.0.0"
}

# Configure the OCI provider with authentication details
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Data source for availability domains
data "oci_identity_availability_domains" "ads" {
  provider       = oci
  compartment_id = var.compartment_ocid
}

# VCN module
module "vcn" {
  source           = "./modules/network"
  providers = {
    oci = oci
  }
  compartment_ocid = var.compartment_ocid
  vcn_display_name = var.vcn_display_name
  vcn_cidr_block   = var.vcn_cidr_block
  vcn_dns_label    = var.vcn_dns_label
  public_subnet_cidr_block = var.public_subnet_cidr_block
  public_subnet_display_name = var.public_subnet_display_name
  public_subnet_dns_label = var.public_subnet_dns_label
}

# Compute instance module
module "compute" {
  source                = "./modules/compute"
  providers = {
    oci = oci
  }
  compartment_ocid      = var.compartment_ocid
  availability_domain   = data.oci_identity_availability_domains.ads.availability_domains[0].name
  subnet_id             = module.vcn.public_subnet_id
  instance_display_name = var.instance_display_name
  shape                 = var.instance_shape
  ocpus                 = var.instance_ocpus
  memory_in_gbs         = var.instance_memory_in_gbs
  image_id              = var.instance_image_id
  ssh_public_key        = var.ssh_public_key
  boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
}
