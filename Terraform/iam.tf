resource "aws_iam_role" "ec2_ecr_role" {
  name = "strapi-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach AmazonEC2ContainerRegistryReadOnly policy
resource "aws_iam_role_policy_attachment" "ec2_ecr_policy" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create an instance profile to attach to EC2
resource "aws_iam_instance_profile" "ec2_ecr_profile" {
  name = "strapi-ec2-ecr-profile"
  role = aws_iam_role.ec2_ecr_role.name
}
