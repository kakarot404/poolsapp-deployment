# Automating OpenSource App Deployment via Jenkins Pipelines & AWS Infrastructure

This repository documents the end-to-end automation of deploying the open-source [PoolsApp](https://github.com/mrpool404/poolsapp) using Jenkins pipelines and various AWS services. It simulates a real-world enterprise deployment setup with multi-stage CI/CD workflows, artifact management, infrastructure provisioning, and secrets handling.

---

## Project Structure

```bash
poolsapp-deployment/
├── src/
│   └── poolsapp/                         # Fork of the original PoolsApp source
│       ├── Pools-App-Backend/
│       ├── Pools-App-Frontend/
│       └── README.md                     # From original app (github/mrpool404)
│
├── jenkins-pipelines/                    # Jenkinsfiles for various CI/CD stages
│   ├── 00-create-target-ec2.Jenkinsfile
│   ├── 01-build-and-store-artifact.Jenkinsfile
│   ├── 02-deploy-artifact-to-target-ec2.Jenkinsfile
│   └── AWS-secrets-manager-integration.md    # How Jenkins uses Secrets Manager
│
├── aws/                                  # AWS infrastructure automation
│   ├── ec2-for-jenkins-prep-notes/       # Manual config & EC2 instructions
│   │   ├── cronjob-setup-for-jenkins-location.md
│   │   ├── jenkins-ec2-instance-prep-note.md
│   │   └── update-jenkins-url.sh
│   ├── ec2-rbac-and-roles.md             # IAM roles and trust relationships
│   ├── security-groups.md                # SG rules and justifications
│   └── terraform/                        # Terraform IaC for EC2, S3 setup
│       ├── s3-bucket-creation.tf
│       └── target-ec2-nginx-mongo.tf
│
├── triggers/                             # Triggering mechanism for pipelines
│   └── webhook-trigger-example.json      # Optional: payload for webhook simulation
│
└── README.md                             # This documentation
```
---


## Objective

The main goals of this project:

- Automate end-to-end deployment of the **PoolsApp**.
- Use **Jenkins** to manage multi-stage CI/CD pipelines.
- Implement **Infrastructure as Code** using **Terraform**.
- Secure sensitive credentials via **AWS Secrets Manager**.
- Simulate a real-world **multi-environment enterprise DevOps workflow**.
- Minimize **human interaction** in the deployment process.

---

## CI/CD Pipelines Overview

### 1. `00-create-target-ec2.Jenkinsfile`

**Purpose:**  
Provision a target EC2 instance using Terraform.

**Actions:**

- Initializes and applies Terraform configuration (`target-ec2-nginx-mongo.tf`).
- Sets up **NGINX** and **MongoDB** on the EC2 instance.

---

### 2. `01-build-and-store-artifact.Jenkinsfile`

**Purpose:**  
Build and package the application, then store the artifact in an S3 bucket.

**Actions:**

- Fetches source code from `src/poolsapp`.
- Builds and zips the backend/frontend components.
- Uploads the zipped artifact to an **S3 bucket**.

---

### 3. `02-deploy-artifact-to-target-ec2.Jenkinsfile`

**Purpose:**  
Deploy the zipped artifact to the EC2 target server.

**Actions:**

- Downloads the artifact from **S3**.
- SSHs into the EC2 instance.
- Unzips and deploys the app.
- Restarts necessary services (e.g., **Node.js**, **NGINX**).

---

## Environment Prep Notes

### Reference setup notes and scripts:

- `jenkins-ec2-instance-prep-note.md` – Jenkins EC2 setup instructions
- `update-jenkins-url.sh` – Script to update Jenkins URL in jobs
- `cronjob-setup-for-jenkins-location.md` – Cron setup for Jenkins persistence or watchdog

---

## Triggering Pipelines

Webhooks or manual triggers are supported.

Recommended setup: GitHub → Jenkins Multibranch Pipeline

---

## Branching Strategy

| Branch | Environment  | Purpose                             |
|--------|--------------|-------------------------------------|
| `main` | Production   | Live deployment                    |
| `dev`  | Development  | Active development and testing     |

Jenkins pipeline logic can be configured to deploy based on the branch that triggers the build.

---

## Security & Access Control

Security is central to this setup, and multiple layers are employed:

- **[Secrets Manager Integration](./jenkins-pipelines/AWS-secrets-manager-integration.md)**: Jenkins pipelines retrieve secrets such as MongoDB credentials and IAM role ARNs securely at runtime.
- **[EC2 Role-Based Access Control](./aws/ec2-rbac-and-roles.md)**: Describes IAM roles, trust policies, and permission boundaries between Jenkins, Terraform, and AWS resources.
- **[Security Groups Overview](./aws/security-groups.md)**: Inbound/outbound traffic rules for Jenkins and app EC2 instances, with justifications for each rule.

---

## Secrets Handling

All credentials (e.g., DB passwords, tokens) are stored securely in AWS Secrets Manager and accessed during Jenkins builds.

### ➡️ See full documentation: [AWS Secrets Integration](./jenkins-pipelines/AWS-secrets-manager-integration.md)

### Example usage within pipeline:

```groovy
environment {
    MONGO_SECRET = sh(script: "aws secretsmanager get-secret-value --secret-id mongo-app-creds --query 'SecretString' --output text", returnStdout: true).trim()
```
