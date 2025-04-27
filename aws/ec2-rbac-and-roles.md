# EC2 Role-Based Access Control (RBAC)

## Jenkins EC2 Instance Role: `jenkins-access-to-S3-role`

Permissions:
- Read/Write access to S3
- Assume role: `Terraform-RM`
- Read access to AWS Secrets Manager (selective resources)

## Terraform Role: `Terraform-RM`

Permissions:
- Provision EC2
- Create and manage Security Groups
- Modify IAM Roles and Policies

## Trust Relationships

- Jenkins EC2 → can assume → `Terraform-RM`
- Jenkins EC2 → can access → SecretsManager