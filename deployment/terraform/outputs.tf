# outputs.tf - Output values for Fleetbase OCI deployment

output "instance_public_ip" {
  description = "Public IP address of the Fleetbase server"
  value       = module.compute.instance_public_ip
}

output "vcn_id" {
  description = "OCID of the created VCN"
  value       = module.vcn.vcn_id
}

output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = module.vcn.public_subnet_id
}

output "instance_id" {
  description = "OCID of the compute instance"
  value       = module.compute.instance_id
}

output "ssh_connection_string" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i <private_key_file> opc@${module.compute.instance_public_ip}"
}

output "application_url" {
  description = "URL to access the Fleetbase application"
  value       = "http://${module.compute.instance_public_ip}"
}

output "console_url" {
  description = "URL to access the Fleetbase console"
  value       = "http://${module.compute.instance_public_ip}:4200"
}
