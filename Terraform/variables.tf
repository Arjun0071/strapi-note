variable "aws_region" {
  description = "AWS region to deploy Strapi"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "image_name" {
  description = "Full Docker image URI (ECR or Docker Hub)"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "image_registry" {
  description = "ECR registry host (e.g., 123456789012.dkr.ecr.ap-south-1.amazonaws.com)"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  default     = "strapi-key"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  default     = "ap-south-1a"
}
