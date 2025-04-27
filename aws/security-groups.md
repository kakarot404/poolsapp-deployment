# Security Groups Overview

## Jenkins EC2 Instance SG

- Port 22 (SSH): [MY IP] and Nginx-Mongo EC2 Instance SG
- Port 8080 (Jenkins Web UI): Open to specific IP [MY IP]
- Port 443 (Access to S3 bucket and AWS Secrets Manager)

## Nginx-Mongo EC2 Instance SG

- Port 80 (Nginx): Public
- Port 27017 (MongoDB): Restricted to Jenkins EC2 IP
- Port 22 (SSH): [MY IP] and Jenkins EC2 Instance SG

## Notes

- Principle of least privilege followed.
- All outbound traffic allowed (default) for the updates and initial phase of setup.