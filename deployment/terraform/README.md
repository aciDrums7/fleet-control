# Fleetbase OCI Terraform Deployment

This directory contains Terraform configurations to deploy Fleetbase on Oracle Cloud Infrastructure (OCI), focusing on the "Always Free" tier with ARM-based Ampere A1 instances.

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) (version 1.0.0 or newer)
2. [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) (optional, but recommended)
3. OCI API key setup (see below)
4. SSH key pair for connecting to the instance

## OCI API Key Setup

Before using these Terraform configurations, you need to set up API keys for OCI:

1. Log in to the OCI Console
2. Click on your user avatar (top-right) and select "User Settings"
3. Under "Resources", click "API Keys"
4. Click "Add API Key"
5. Either generate a new key pair or upload your public key
6. Download the configuration file when prompted
7. Save the private key to a secure location (e.g., `~/.oci/oci_api_key.pem`)

The configuration file will contain your `tenancy_ocid`, `user_ocid`, `fingerprint`, and `region` which you'll need for the Terraform variables.

## Configuration

1. Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your specific OCI information:
   - Authentication details (tenancy OCID, user OCID, etc.)
   - Compartment OCID
   - SSH public key (for accessing the instance)
   - ARM-compatible image OCID for your region

## Usage

### Initialize Terraform

```bash
terraform init
```

### Preview the Deployment Plan

```bash
terraform plan
```

### Apply the Configuration

```bash
terraform apply
```

When prompted, type `yes` to confirm the deployment.

### Destroy Resources

To remove all resources created by Terraform:

```bash
terraform destroy
```

## Deployment Steps

The Terraform configuration will:

1. Create a Virtual Cloud Network (VCN) with internet access
2. Set up security rules for HTTP(S), SSH, and Fleetbase console access
3. Provision an ARM-based Ampere A1 compute instance (OCI "Always Free" tier)
4. Install Docker and Docker Compose on the instance
5. Configure basic security settings

## Post-Deployment

After Terraform completes:

1. Note the output values, especially the instance's public IP
2. SSH into the instance:
   ```bash
   ssh -i /path/to/private_key opc@<instance_public_ip>
   ```
3. Clone your Fleetbase repository and configure environment variables
4. Run Docker Compose to start the Fleetbase services

## Directory Structure

```
terraform/
│
├── main.tf              # Main Terraform configuration
├── variables.tf         # Input variables definition
├── outputs.tf           # Output values definition
├── terraform.tfvars     # Variable values (create from example)
│
└── modules/
    ├── network/         # Network resources (VCN, subnets, etc.)
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── compute/         # Compute resources (VM instance)
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── cloud-init.yaml  # First-boot initialization script
```

## Notes

- The deployment uses an ARM-based Ampere A1 instance to take advantage of OCI's "Always Free" tier
- The cloud-init script installs Docker and Docker Compose, sets up swap space, and configures basic firewall rules
- Remember to set up proper environment variables for Fleetbase in a docker-compose.override.yml file after deployment
