# 🚀 Server Setup for Dockerized Applications

This section guides you through setting up a cloud server (e.g., DigitalOcean Droplet or AWS EC2 instance) and installing Docker and dependencies to run a Dockerized application.

## 1. Create a Cloud Server

### Option 1: DigitalOcean Droplet
1. Sign up or log in to [DigitalOcean](https://www.digitalocean.com/).
2. Click **Create > Droplet**.
3. Choose an **Ubuntu** image (e.g., Ubuntu 22.04 LTS).
4. Select a plan (e.g., Basic, 1 GB RAM for small projects).
5. Choose a datacenter region (e.g., New York).
6. Set up SSH key authentication:
   - Generate an SSH key locally: `ssh-keygen -t rsa -b 4096`
   - Copy the public key (`~/.ssh/id_rsa.pub`) to DigitalOcean.
7. Name your Droplet and click **Create Droplet**.
8. Note the Droplet’s public IP address.

### Option 2: AWS EC2 Instance
1. Log in to the [AWS Management Console](https://aws.amazon.com/console/).
2. Navigate to **EC2 > Instances > Launch Instances**.
3. Choose an **Ubuntu Server** AMI (e.g., Ubuntu Server 22.04 LTS).
4. Select an instance type (e.g., `t2.micro` for free tier).
5. Configure a key pair for SSH:
   - Create a new key pair, download the `.pem` file, and secure it: `chmod 400 key.pem`.
6. Configure security groups to allow SSH (port 22) and HTTP (port 80).
7. Launch the instance and note the public IP address.

## 2. Connect to the Server
1. SSH into the server:
   ```bash
   ssh -i /path/to/key.pem ubuntu@<server-ip-address>
   ```
   - For DigitalOcean, use `root@<server-ip-address>` if no user is specified.
2. Update the system:
   ```bash
   # Update package lists
   sudo apt update
   # Upgrade installed packages
   sudo apt upgrade -y
   ```

## 3. Install Dependencies
Install required tools (e.g., `zip` for handling archives):
```bash
# Install zip and unzip utilities
sudo apt install zip unzip -y
```

## 4. Install Docker
1. Add Docker’s official GPG key and repository:
   ```bash
   # Install prerequisites
   sudo apt install ca-certificates curl -y
   # Create directory for keyrings
   sudo install -m 0755 -d /etc/apt/keyrings
   # Download Docker GPG key
   sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
   # Set key permissions
   sudo chmod a+r /etc/apt/keyrings/docker.asc
   # Add Docker repository to Apt sources
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
     $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   # Update package lists
   sudo apt update
   ```
2. Install Docker and related components:
   ```bash
   # Install Docker Engine, CLI, and plugins
   sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
   ```
3. Verify Docker installation:
   ```bash
   # Check Docker version
   docker --version
   # Check Docker Compose version
   docker compose version
   ```

## 5. Configure Docker
1. Add your user to the Docker group to run Docker without `sudo`:
   ```bash
   # Add user to docker group
   sudo usermod -aG docker $USER
   # Log out and back in to apply changes
   exit
   ```
2. Reconnect to the server via SSH and verify:
   ```bash
   # Run a test container without sudo
   docker run hello-world
   ```

## 6. Transfer Project Files
1. From your local machine, upload your project files to the server:
   ```bash
   # Copy project zip file to server
   scp /path/to/project.zip ubuntu@<server-ip-address>:/tmp
   ```
2. On the server, unzip the project:
   ```bash
   # Unzip project files
   unzip /tmp/project.zip -d /home/ubuntu/
   # Navigate to project directory
   cd /home/ubuntu/<project-directory>
   ```

## 7. Next Steps
Proceed to the application-specific setup instructions below to build and run the Dockerized application.