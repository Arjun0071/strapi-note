resource "aws_instance" "strapi_ec2" {
  ami           = "ami-03a2446aa1d3f50cd"  # Ubuntu 22.04 LTS in ap-south-1
  instance_type = var.instance_type
  key_name      = aws_key_pair.strapi_key.key_name
  subnet_id     = aws_subnet.strapi_subnet.id
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

 # Attach IAM instance profile for private ECR access
  iam_instance_profile = aws_iam_instance_profile.ec2_ecr_profile.name

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    apt-get update -y
    apt-get upgrade -y

    # Install required dependencies
    apt-get install -y docker.io awscli curl

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

    # Run the Strapi container in production mode
    docker run -d -p 1337:1337 \
      --restart unless-stopped \
      -e NODE_ENV=production \
      -e STRAPI_ADMIN_BACKEND_URL=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):1337 \
      --name strapi \
      ${var.image_name}:${var.image_tag}
EOF

  tags = {
    Name = "Strapi-EC2-Ubuntu"
  }
}
