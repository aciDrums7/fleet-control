# modules/network/outputs.tf - Network module outputs

output "vcn_id" {
  description = "OCID of the created VCN"
  value       = oci_core_vcn.fleetbase_vcn.id
}

output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public_subnet.id
}

output "internet_gateway_id" {
  description = "OCID of the internet gateway"
  value       = oci_core_internet_gateway.internet_gateway.id
}

output "route_table_id" {
  description = "OCID of the route table"
  value       = oci_core_route_table.public_route_table.id
}

output "security_list_id" {
  description = "OCID of the security list"
  value       = oci_core_security_list.public_security_list.id
}
