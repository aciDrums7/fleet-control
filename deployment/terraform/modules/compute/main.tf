terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

# modules/compute/main.tf - Compute resources for Fleetbase OCI deployment

# Create a compute instance
resource "oci_core_instance" "fleetbase_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
    
    # Optional: Specify a custom boot volume size (100GB default)
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    hostname_label   = "fleetbase-server"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    # Below is a cloud-init script that will run on first boot
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {}))
  }

  # Prevent the instance from being destroyed/recreated when shape_config parameters change
  lifecycle {
    ignore_changes = [
      metadata,
      shape_config[0].ocpus,
      shape_config[0].memory_in_gbs
    ]
  }
}

# Create a volume backup policy for the boot volume
resource "oci_core_volume_backup_policy_assignment" "boot_volume_backup_policy" {
  asset_id  = oci_core_instance.fleetbase_instance.boot_volume_id
  policy_id = data.oci_core_volume_backup_policies.predefined_volume_backup_policies.volume_backup_policies[0].id
}

# Get the predefined volume backup policies
data "oci_core_volume_backup_policies" "predefined_volume_backup_policies" {
  filter {
    name   = "display_name"
    values = ["silver"]
    regex  = true
  }
}
