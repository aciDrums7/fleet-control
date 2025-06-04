# modules/compute/outputs.tf - Compute module outputs

output "instance_id" {
  description = "OCID of the compute instance"
  value       = oci_core_instance.fleetbase_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the compute instance"
  value       = oci_core_instance.fleetbase_instance.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the compute instance"
  value       = oci_core_instance.fleetbase_instance.private_ip
}

output "boot_volume_id" {
  description = "OCID of the boot volume"
  value       = oci_core_instance.fleetbase_instance.boot_volume_id
}
