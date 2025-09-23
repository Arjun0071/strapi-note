# Task #5: Automate Strapi Deployment with GitHub Actions + Terraform

## Overview

This task automates the deployment of a **Strapi CMS application** using a CI/CD pipeline:

- **CI:** Builds and pushes the Docker image of Strapi on code changes.
- **CD:** Deploys the Docker image to an EC2 instance using Terraform.
- **Goal:** Ensure Strapi is accessible via the EC2 public IP.

This document provides a step-by-step guide, learnings, and troubleshooting notes for the setup.

---

## 1. Prerequisites

Before starting:

- AWS account with proper IAM permissions (EC2, ECR, IAM, VPC).
- Terraform installed locally (v1.6.6 used here).
- GitHub repository for storing code and GitHub Actions workflows.
- AWS CLI installed (v2 recommended).
- Docker installed locally (for testing the build pipeline).

---

## 2. CI/CD Workflow Overview

### CI Pipeline (`.github/workflows/ci.yml`)

**Purpose:** Automatically build and push the Strapi Docker image on push to the main branch.

**Key Steps:**

1. **Trigger:** `on: push` to `main`.
2. **Checkout repo:** Pull code from GitHub.
3. **Set up Node.js & Docker:** Required to build Strapi image.
4. **Build Docker image:** Tag with commit SHA or custom tag.
5. **Push image to registry:** Docker Hub or AWS ECR.
6. **Output image tag:** Used in the CD pipeline.

**Notes:**

- Ensure Docker login credentials are stored as GitHub secrets (`DOCKER_USERNAME`, `DOCKER_PASSWORD`) if using Docker Hub.
- For ECR, store `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `ECR_REGISTRY`, and `ECR_REPO` as GitHub secrets.

---

### CD Pipeline (`.github/workflows/terraform.yml`)

**Purpose:** Deploy the Docker image to EC2 using Terraform.

**Trigger:** Manual (`workflow_dispatch`) with input parameter `image_tag`.

**Key Steps:**

1. **Set environment variables** from GitHub Secrets:
```
AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
ECR_REGISTRY, ECR_REPO
```

2. **Checkout repository.**

3.**Configure AWS credentials for Terraform.**

4.**Setup Terraform.**

5.**Terraform Init in the /Terraform directory.**

6.**Terraform Plan & Apply: Pass variables:**
```
-var="image_name=${{ env.ECR_REGISTRY }}/${{ env.ECR_REPO }}"
-var="image_registry=${{ env.ECR_REGISTRY }}"
-var="image_tag=${{ env.IMAGE_TAG }}"
-var="aws_region=${{ env.AWS_REGION }}"
```

**Notes:**

image_registry is required separately for aws ecr get-login-password in user_data.

All sensitive values should be GitHub secrets, not hardcoded.

Terraform variables (.tfvars) can be used for local testing.

**3. EC2 User Data**

1.The EC2 instance launches with a user_data script that:

2.Updates the system.

3.Installs required packages: curl, docker.io, unzip, nodejs.

4.Installs AWS CLI v2.

5.Starts and enables Docker service.

6.Authenticates Docker to ECR:
```
aws ecr get-login-password --region ${var.aws_region} | \
docker login --username AWS --password-stdin ${var.image_registry}
```

7.Pulls and runs the Strapi container with environment secrets:

APP_KEYS, JWT_SECRET, ADMIN_JWT_SECRET, API_TOKEN_SALT, TRANSFER_TOKEN_SALT, ENCRYPTION_KEY

8.Exposes Strapi on port 1337.

**Watch out:**

sudo is not needed in user_data for most commands as cloud-init runs as root, but some install scripts may suggest it.

Ensure ${var.image_registry} and ${var.image_name} are passed correctly from GitHub Actions.

**4. Key Learnings**

1.Passing variables from GitHub Actions to Terraform:

Terraform only sees variables explicitly passed using -var or .tfvars.
Environment variables in GitHub Actions are not automatically available to Terraform.

2.ECR login requires registry URL separately:
Even if image_name includes the registry, aws ecr get-login-password needs the registry URL.

3.Debugging user_data:

Logs are available via EC2 instance:
```
sudo cloud-init status
sudo cloud-init logs
```

Useful for checking why Docker image wasn’t pulled or container didn’t start.

4.Manual Terraform testing:
Always test Terraform scripts locally before GitHub Actions.

Ensures variables and IAM roles are configured correctly.

**6. Best Practices**

Use GitHub Secrets for AWS keys and ECR credentials.

Separate image_name and image_registry to avoid user_data issues.

Test locally before CD to catch issues in user_data.

Cloud-init logs are your first debugging resource.

**7. Workflow Diagram**
```text
[GitHub Push] ---> [CI: Build & Push Docker Image] ---> [ECR/Docker Registry]
                               |
                               v
                   [CD: Manual Trigger Terraform]
                               |
                               v
                         [EC2 Instance]
                               |
                               v
                        [Strapi Container]

```

Always test Terraform scripts locally before GitHub Actions.

Ensures variables and IAM roles are configured correctly.
