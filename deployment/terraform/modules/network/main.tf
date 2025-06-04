terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

# modules/network/main.tf - Network resources for Fleetbase OCI deployment

# Create a Virtual Cloud Network (VCN)
resource "oci_core_vcn" "fleetbase_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name
  cidr_block     = var.vcn_cidr_block
  dns_label      = var.vcn_dns_label
}

# Create an Internet Gateway
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.vcn_display_name}-igw"
  vcn_id         = oci_core_vcn.fleetbase_vcn.id
}

# Create a Route Table for the public subnet
resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fleetbase_vcn.id
  display_name   = "${var.vcn_display_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# Create a Security List for the public subnet
resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fleetbase_vcn.id
  display_name   = "${var.vcn_display_name}-public-sl"

  # Allow all outbound traffic
  egress_security_rules {
    destination      = "0.0.0.0/0"
    protocol         = "all"
    destination_type = "CIDR_BLOCK"
  }

  # Allow SSH ingress
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow HTTP ingress
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # Allow HTTPS ingress
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # Allow Fleetbase console port
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 4200
      max = 4200
    }
  }

  # Allow ICMP for ping and traceroute
  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

# Create a Public Subnet
resource "oci_core_subnet" "public_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.fleetbase_vcn.id
  cidr_block                 = var.public_subnet_cidr_block
  display_name               = var.public_subnet_display_name
  dns_label                  = var.public_subnet_dns_label
  route_table_id             = oci_core_route_table.public_route_table.id
  security_list_ids          = [oci_core_security_list.public_security_list.id]
  prohibit_public_ip_on_vnic = false
}
