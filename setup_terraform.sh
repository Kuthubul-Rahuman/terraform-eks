#!/bin/bash

# Remove the existing Docker list file
sudo rm /etc/apt/sources.list.d/docker.list

# Recreate the Docker list file with the correct entry
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Update the package list
sudo apt-get update

# Re-import Docker’s GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Update the package list again
sudo apt-get update

# Verify the Docker GPG key exists and set the correct permissions
ls -l /etc/apt/keyrings/docker.gpg
sudo chmod 644 /etc/apt/keyrings/docker.gpg

# Update the package list once more
sudo apt-get update

# Install gnupg and software-properties-common
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

# Add HashiCorp’s GPG key and repository
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint

# Add HashiCorp’s repository to your system
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update the package list
sudo apt update

# Install Terraform
sudo apt-get install -y terraform

# Verify Terraform installation
terraform -help
terraform -help plan

# Setup Terraform autocomplete
touch ~/.bashrc
terraform -install-autocomplete

# Verify Terraform version
terraform -v

