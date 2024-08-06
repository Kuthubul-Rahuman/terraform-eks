provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "instance_sg" {
  name        = "eks-setup-sg"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust for more secure access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "eks_instance" {
  ami           = "ami-0a0e5d9c7acc336f1"  # Using the specified AMI
  instance_type = "t2.micro"
  key_name      = "admin_test_key_pair"  # Use your existing key pair
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  # User data script to install necessary tools using apt with logging
  user_data = <<-EOF
    #!/bin/bash
    exec > /tmp/user_data.log 2>&1
    set -x

    # Update package lists
    apt-get update -y

    # Install necessary dependencies
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up the Docker repository
    echo \
      "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      \$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the package lists to include Docker packages
    sudo apt-get update

    # Install Docker and its components
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Start Docker service and add the ubuntu user to the Docker group
    sudo systemctl start docker
    sudo usermod -aG docker ubuntu

    # Install Terraform
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com \$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update && sudo apt-get install -y terraform

    # Install AWS CLI
    sudo apt-get install -y awscli

    # Update PATH
    echo "export PATH=\$PATH:/usr/local/bin" >> /home/ubuntu/.bashrc
  EOF

  tags = {
    Name = "eks-setup-instance"
  }
}

resource "null_resource" "run_eks_setup" {
  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu",
      "git clone https://github.com/la-belle-femme/terraform-eks eks-setup",
      "cd eks-setup",
      "terraform init",
      "terraform apply -auto-approve",
      "echo 'EKS Cluster setup complete' >> /home/ubuntu/eks-setup.log"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("C:/Users/13477/Downloads/admin_test_key_pair.pem")  # Use the Windows path
      host        = aws_instance.eks_instance.public_ip
    }
  }

  depends_on = [aws_instance.eks_instance]
}

output "instance_public_ip" {
  value = aws_instance.eks_instance.public_ip
}
