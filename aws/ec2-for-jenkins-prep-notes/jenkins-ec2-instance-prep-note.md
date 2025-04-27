# Jenkins EC2 Instance AMI Preparation Notes

This document outlines the steps followed to create a custom AMI with Jenkins pre-installed and configured on an EC2 instance. It includes Jenkins installation, dependency setup, service enablement, and a cron job to dynamically update the Jenkins URL based on the instance's current public IP.

---

## 🛠️ 1. EC2 Instance Setup

- **Base AMI Used**: Ubuntu 20.04 LTS 
- **Instance Type**: t2.micro 
- **User**: `ubuntu`

---

## 📦 2. Jenkins and Dependencies Installation

```bash
# Update package list and install dependencies
sudo apt update

# Add Jenkins repository and key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Then add a Jenkins apt repository entry: 
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update your local package index, then finally install Jenkins: 
sudo apt-get update
sudo apt-get install fontconfig openjdk-17-jre
sudo apt-get install jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
'''

**Note: Jenkins and dependencies insatllation can be checked on link below for latest update -**
https://pkg.jenkins.io/         #I did preffer debian/stable :)