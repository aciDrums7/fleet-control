# Step-by-Step Guide: Deploying Fleetbase to Oracle Cloud Infrastructure (OCI)

This guide outlines the process for deploying Fleetbase to Oracle Cloud Infrastructure (OCI), primarily leveraging OCI's "Always Free" tier resources where possible. It assumes a deployment model using Docker and Docker Compose on an OCI Compute Instance.

**Assumptions:**

*   You have an active OCI account.
*   Your Fleetbase application code is accessible via a Git repository.
*   The Fleetbase `docker-compose.yml` file defines services for the application, web server (e.g., Caddy/Nginx), `database` (MySQL), and `cache` (Redis).
*   You have SSH public/private key pairs for secure VM access.

---

## Phase 1: Set Up OCI Infrastructure

### Step 1: Create a Virtual Cloud Network (VCN)

If you don't already have one, a VCN is required to provide a private network for your cloud resources.

1.  In the OCI Console, navigate to **Networking** -> **Virtual Cloud Networks**.
2.  Click **Start VCN Wizard**.
3.  Select **VCN with Internet Connectivity** and click **Start VCN Wizard**.
4.  **Name:** Assign a descriptive name (e.g., `fleetbase-vcn`).
5.  Review the proposed CIDR blocks for the VCN and subnets. Defaults are usually acceptable for initial setups.
6.  Ensure the option **Use DNS hostnames in this VCN** is checked.
7.  Click **Next**, then review and click **Create**. This process will provision the VCN, a public subnet, an internet gateway, route tables, and security lists.

### Step 2: Create an "Always Free" ARM Compute Instance

1.  Navigate to **Compute** -> **Instances** in the OCI Console.
2.  Click **Create Instance**.
3.  **Name:** e.g., `fleetbase-server`.
4.  **Placement:** Ensure you are in a region that supports "Always Free" Ampere A1 shapes.
5.  **Image and shape:**
    *   Click **Edit** in the "Image and shape" section.
    *   **Image:** Choose an operating system. **Oracle Linux** or **Ubuntu** (e.g., Ubuntu 22.04) are recommended.
    *   **Shape:** Select **Ampere** under "Shape series." Choose an "Always Free-eligible" shape like `VM.Standard.A1.Flex`. You can allocate up to 4 OCPUs and 24GB of memory in total across your "Always Free" A1 instances. For Fleetbase, starting with **1 or 2 OCPUs** and **6-12 GB of Memory** is a good baseline.
6.  **Networking:**
    *   Select the VCN (`fleetbase-vcn`) and the public subnet created earlier.
    *   Ensure **Assign a public IPv4 address** is selected.
7.  **Add SSH keys:** Choose **Paste public keys** and paste your SSH public key.
8.  **Boot volume:** Default settings are generally sufficient.
9.  Click **Create**. Wait for the instance to be provisioned and reach a "Running" state. Note down its **Public IP Address**.

### Step 3: Configure Security List or Network Security Group (NSG)

To allow web traffic (HTTP/HTTPS) and SSH to your instance:

1.  Navigate to **Networking** -> **Virtual Cloud Networks**. Select your VCN.
2.  Under "Resources," click **Security Lists**. Select the **Default Security List for your VCN**.
3.  Click **Add Ingress Rules**.
4.  Add the following ingress rules:
    *   **SSH (if not already present by default):**
        *   Source Type: CIDR
        *   Source CIDR: `0.0.0.0/0` (For wider access during setup; restrict to your IP if possible for production)
        *   IP Protocol: TCP
        *   Destination Port Range: `22`
        *   Description: `Allow SSH`
    *   **HTTP:**
        *   Source Type: CIDR
        *   Source CIDR: `0.0.0.0/0`
        *   IP Protocol: TCP
        *   Destination Port Range: `80`
        *   Description: `Allow HTTP`
    *   **HTTPS:**
        *   Source Type: CIDR
        *   Source CIDR: `0.0.0.0/0`
        *   IP Protocol: TCP
        *   Destination Port Range: `443`
        *   Description: `Allow HTTPS`
    *   *Note: Using Network Security Groups (NSGs) associated with the instance's VNIC is a more granular and often preferred approach over modifying the default security list.*

---

## Phase 2: Configure the Server and Deploy Fleetbase

### Step 4: Connect to Your Instance via SSH

```bash
ssh -i /path/to/your/private_key <username>@<your_instance_public_ip>
```
*   Default username for Oracle Linux: `opc`
*   Default username for Ubuntu: `ubuntu`

### Step 5: Install Docker and Docker Compose

*   **Install Docker Engine:**
    ```bash
    # Example for Ubuntu:
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER # Add current user to docker group
newgrp docker # Activate group changes or log out and back in
    ```
    *(For Oracle Linux, refer to Docker's official documentation for installation, typically using `yum` or `dnf`.)*

*   **Install Docker Compose (v2 Plugin):**
    ```bash
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version # Verify
    ```

### Step 6: Install Git and Clone Fleetbase Repository

```bash
sudo apt update # Or appropriate command for your OS (e.g., sudo yum update)
sudo apt install -y git # Or appropriate command for your OS
cd ~ # Or your preferred project directory
git clone <your_fleetbase_git_repository_url> # e.g., https://github.com/fleetbase/fleetbase.git
cd fleetbase # Navigate into the cloned repository directory
```

### Step 7: Configure Fleetbase Environment Variables

Adapt your local `docker-compose.override.yml` and `api/.env` settings for the OCI server environment.

1.  **Main Environment Configuration (`.env` or `docker-compose.override.yml`):**
    *   If your `docker-compose.yml` relies on a root `.env` file, create it (e.g., `cp .env.example .env`).
    *   Alternatively, create or modify a `docker-compose.override.yml` for OCI-specific settings.
    *   **Key Variables:**
        *   `APP_ENV=production`
        *   `APP_KEY=`: Generate a new key on the server after initial `docker-compose up`. Use `docker-compose exec application php artisan key:generate --show` and copy the output.
        *   `APP_URL=http://<your_instance_public_ip>` (Update later if using a custom domain)
        *   `CONSOLE_HOST=http://<your_instance_public_ip>:4200` (Adjust port/path as needed)
        *   `DB_HOST=database` (Should match the MySQL service name in `docker-compose.yml`)
        *   `DB_DATABASE=fleetbase`
        *   `DB_USERNAME=fleetbase` (Or your chosen username; ensure consistency with MySQL setup)
        *   `DB_PASSWORD=<a_strong_secure_password>` (Ensure consistency)
        *   `REDIS_HOST=cache` (Should match the Redis service name in `docker-compose.yml`)
        *   Include any other necessary API keys (Google Maps, etc.).

2.  **API Specific Environment (`api/.env`):**
    *   Navigate to the `api` directory: `cd api`
    *   Create the `.env` file: `cp .env.example .env`
    *   Edit `api/.env` to ensure `APP_KEY`, `APP_URL`, database credentials (`DB_*`), and Redis settings (`REDIS_*`) are correctly set. Environment variables defined in `docker-compose` usually override these.
    *   Return to the project root: `cd ..`

**Important Note on Docker Images for ARM (OCI Ampere A1 Instances):**
Your local setup memory indicates `platform: linux/amd64`. OCI Ampere A1 instances are ARM-based.
*   Verify if Fleetbase's `docker-compose.yml` or its underlying Dockerfiles specify multi-arch images or provide native ARM64 image support for PHP, web server, MySQL, and Redis.
*   If images are hardcoded for `amd64`, Docker on ARM *may* attempt emulation, potentially leading to performance issues or instability.
*   **Best Practice:** Whenever possible, use official ARM64-compatible Docker images (e.g., `arm64v8/mysql:8.0`, `arm64v8/redis`). You might need to adjust image names in your `docker-compose.yml`.

### Step 8: Build and Run Fleetbase with Docker Compose

From the root of your Fleetbase project directory:
```bash
docker-compose up -d --build
```
*   This command will download/build the necessary Docker images and start all defined services in detached mode.
*   Monitor the startup logs: `docker-compose logs -f`
*   To view logs for a specific service: `docker-compose logs -f <service_name>` (e.g., `application`, `database`).

### Step 9: Run Fleetbase Installation/Deployment Script

Refer to your Fleetbase setup memory regarding a `deploy.sh` script or installation command.

1.  Identify your application container's name or ID: `docker-compose ps`
2.  Execute the installation/deployment script. This often involves running an `artisan` command. Example ( **adapt this command based on Fleetbase's actual requirements** ):
    ```bash
    docker-compose exec application php /fleetbase/api/artisan fleetbase:install \
        --key=$(grep APP_KEY api/.env | cut -d '=' -f2-) \
        --db-host=database \
        --db-name=fleetbase \
        --db-user=YOUR_CONFIGURED_DB_USER \
        --db-pass=YOUR_CONFIGURED_DB_PASSWORD \
        --admin-email=your_admin@example.com \
        --admin-pass=a_strong_admin_password \
        --network=fleetbase \
        --template=fleetops \
        --no-interaction -vvv
    ```
    *   If a `deploy.sh` script is provided and configured within the `api` directory:
        `docker-compose exec application sh /fleetbase/api/deploy.sh`
    *   **Critical:** Ensure that the environment variables (especially `APP_KEY` and database credentials) available *inside* the `application` container are correct for the installation script.

### Step 10: Test Your Deployment

Open a web browser and navigate to `http://<your_instance_public_ip>`. You should be able to access your Fleetbase application.

---

## Phase 3: Further Steps & Considerations (Recommended)

*   **Configure a Domain Name:**
    *   In your DNS provider's settings, point your desired domain (e.g., `app.yourdomain.com`) to the OCI instance's public IP address.
    *   Update `APP_URL`, `CONSOLE_HOST`, and any other relevant URL configurations in your Fleetbase environment files.
*   **Set Up HTTPS/SSL:**
    *   This is typically handled by the web server container (e.g., Caddy, Nginx) defined in your `docker-compose.yml`.
    *   **Caddy:** Often handles SSL certificate acquisition (e.g., from Let's Encrypt) automatically when configured with a domain name.
    *   **Nginx:** You might need to use tools like Certbot within the Nginx container or on the host to obtain and configure SSL certificates.
*   **Persistent Storage for Docker Volumes:**
    *   Ensure your `docker-compose.yml` correctly defines named volumes for MySQL data, Redis data (if persistence is required), and any other application data that needs to persist across container restarts. Docker on the VM manages these volumes (typically under `/var/lib/docker/volumes/`).
*   **Backup Strategy:**
    *   Implement regular backups for your OCI instance (snapshotting the boot volume) and, critically, for your MySQL database. OCI offers block volume backup capabilities. Database backups can also be performed from within the container.
*   **Monitoring:**
    *   Utilize `docker-compose logs` and `docker stats` for container-level monitoring.
    *   Explore OCI's native Monitoring services for instance-level metrics.
*   **Firewall Refinements:**
    *   Once everything is working, consider restricting the SSH (port 22) ingress rule in your Security List/NSG to only allow access from known IP addresses instead of `0.0.0.0/0`.

---

This guide provides a comprehensive path to deploying Fleetbase on OCI. Always refer to the official Fleetbase documentation for any specific installation or configuration commands.

---

## Phase 4: Infrastructure as Code (IaC) with Terraform

Instead of manually creating the OCI infrastructure through the console, you can automate and manage it using Infrastructure as Code (IaC). This approach allows for repeatable, version-controlled, and automated deployments.

**Recommended IaC Tool: Terraform**

For OCI, Terraform by HashiCorp is the most widely used and well-supported IaC tool. OCI provides an official Terraform provider that enables you to define and manage OCI resources through code.

**General Steps to Create This Infrastructure with Terraform:**

1.  **Install Terraform:** Download and install the Terraform CLI on your local machine.
2.  **Set up OCI Provider Configuration:** Configure Terraform to authenticate with your OCI account, typically using API key authentication.
3.  **Write Terraform Configuration Files (.tf):** Create files (e.g., `main.tf`, `variables.tf`) to define:
    *   The OCI provider.
    *   Variables for configurable parameters (region, OCIDs, SSH keys, etc.).
    *   OCI resources like VCNs, subnets, internet gateways, route tables, security lists/NSGs, and compute instances.
4.  **Initialize Terraform:** Run `terraform init` to download necessary provider plugins.
5.  **Plan the Deployment:** Run `terraform plan` to review the changes Terraform will make.
6.  **Apply the Configuration:** Run `terraform apply` to create or update your infrastructure in OCI.

**Information Needed to Build Terraform Configuration:**

To define the infrastructure in Terraform code, you (or an assistant helping you) would need the following details. These will serve as inputs or variables in your Terraform configuration:

1.  **OCI Authentication Details (for Terraform):**
    *   **Tenancy OCID:** Your OCI tenancy's unique identifier.
    *   **User OCID:** The OCID of the OCI user account Terraform will use for authentication.
    *   **API Key Fingerprint:** The fingerprint of the public API key uploaded to the specified OCI user's profile.
    *   **Path to Private API Key File:** The local file system path to the private API key (e.g., `~/.oci/oci_api_key.pem`).
    *   **OCI Region:** The target OCI region for deployment (e.g., `us-ashburn-1`, `eu-frankfurt-1`).

2.  **Compartment Information:**
    *   **Compartment OCID:** The OCID of the compartment where the Fleetbase infrastructure will be provisioned.

3.  **Networking Configuration Choices:**
    *   **VCN Name:** A descriptive name for your Virtual Cloud Network (e.g., `fleetbase-vcn-tf`).
    *   **VCN CIDR Block:** The IP address range for the VCN (e.g., `10.0.0.0/16`).
    *   **Public Subnet Name:** A name for the public subnet (e.g., `fleetbase-public-subnet-tf`).
    *   **Public Subnet CIDR Block:** The IP address range for the public subnet (e.g., `10.0.1.0/24`), which must be within the VCN's CIDR block.
    *   **DNS Label for VCN (optional):** A DNS label for the VCN, used in DNS resolution (e.g., `fleetbasevcn`).
    *   **DNS Label for Public Subnet (optional):** A DNS label for the public subnet (e.g., `fleetbasepubsub`).

4.  **Compute Instance Configuration Choices:**
    *   **Instance Name:** A name for your compute instance (e.g., `fleetbase-server-tf`).
    *   **Availability Domain:** The specific availability domain within your chosen region (e.g., `Uocm:PHX-AD-1`). You can list available ADs in the OCI console or via CLI.
    *   **Instance Shape:** The desired shape for the instance (e.g., `VM.Standard.A1.Flex` for ARM Always Free).
    *   **OCPUs for Flex Shape:** Number of OCPUs if using a Flex shape (e.g., `1`, `2`).
    *   **Memory (GB) for Flex Shape:** Amount of memory in GB if using a Flex shape (e.g., `6`, `12`).
    *   **Operating System Image OCID:** The OCID of the OS image to use (e.g., for Ubuntu 22.04 ARM). This can be found in the OCI console or via OCI CLI for your specific region and image version.
    *   **SSH Public Key String:** The full content of your public SSH key (e.g., `ssh-rsa AAAA... your_email@example.com`).

5.  **Security Rules (for Security List or Network Security Group):**
    *   **Ingress Ports:** List of TCP ports to open (e.g., `22` for SSH, `80` for HTTP, `443` for HTTPS).
    *   **Source CIDR for Ingress Rules:** The source IP range allowed to access these ports (e.g., `0.0.0.0/0` for public access, or a specific IP/range for SSH).
