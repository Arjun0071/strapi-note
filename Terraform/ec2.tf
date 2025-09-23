resource "aws_instance" "strapi_ec2" {
  ami           = "ami-03a2446aa1d3f50cd"  # Ubuntu 22.04 LTS in ap-south-1
  instance_type = var.instance_type
  key_name      = aws_key_pair.strapi_key.key_name
  subnet_id     = aws_subnet.strapi_subnet.id
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  root_block_device {
    volume_size = 20 
    volume_type = "gp3" # or gp2
    delete_on_termination = true
  }


 # Attach IAM instance profile for private ECR access
  iam_instance_profile = aws_iam_instance_profile.ec2_ecr_profile.name

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    apt-get update -y
    apt-get upgrade -y

    # Install required dependencies
    apt-get install -y curl
    apt-get install -y docker.io
    apt-get install -y unzip curl

    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install

    # Install Node.js (for generating secrets)
    curl -fsSL https://deb.nodesource.com/setup_20.x | -E bash -
    apt-get install -y nodejs

    # Start and enable Docker service
    systemctl start docker
    systemctl enable docker

    # Authenticate Docker to private ECR
    aws ecr get-login-password --region ${var.aws_region} | \
    docker login --username AWS --password-stdin ${var.image_registry}

    # Pull the new Strapi image from ECR
    docker pull ${var.image_name}:${var.image_tag}

    # Stop & remove any existing container (if exists)
    docker stop strapi || true
    docker rm strapi || true

    # Generate Strapi secrets
    APP_KEYS=$(for i in {1..4}; do openssl rand -base64 32; done | paste -sd, -)
    JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('base64'))")
    ADMIN_JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('base64'))")
    API_TOKEN_SALT=$(node -e "console.log(require('crypto').randomBytes(32).toString('base64'))")
    TRANSFER_TOKEN_SALT=$(node -e "console.log(require('crypto').randomBytes(32).toString('base64'))")
    ENCRYPTION_KEY=$(node -e "console.log(require('crypto').randomBytes(32).toString('base64'))")

    # Run the Strapi container in production mode with all secrets
    docker run -d -p 1337:1337 \
      --restart unless-stopped \
      -e NODE_ENV=production \
      -e STRAPI_ADMIN_BACKEND_URL=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):1337 \
      -e APP_KEYS="$APP_KEYS" \
      -e JWT_SECRET="$JWT_SECRET" \
      -e ADMIN_JWT_SECRET="$ADMIN_JWT_SECRET" \
      -e API_TOKEN_SALT="$API_TOKEN_SALT" \
      -e TRANSFER_TOKEN_SALT="$TRANSFER_TOKEN_SALT" \
      -e ENCRYPTION_KEY="$ENCRYPTION_KEY" \
      --name strapi \
      ${var.image_name}:${var.image_tag}
EOF

  tags = {
    Name = "Strapi-EC2-Ubuntu"
  }
}


