# Cronjob Setup for Jenkins Location Update

This document explains how a cron job is used to automatically update the Jenkins URL based on the EC2 instance's public IP, using AWS IMDSv2. This setup ensures Jenkins is always reachable after instance reboots, especially when using dynamic public IPs.

---

## 🛠️ Crontab Entry

The following crontab entry has been added using `crontab -e`:

```cron
@reboot /home/ubuntu/update_jenkins_url.sh >> /home/ubuntu/jenkins_update.log 2>&1

---
## PLEASE REFER TO EXAMPLE FILE "update-jenkins-url.sh" FOR UNDERSTANDING HOW TO HANDLE LOCATION IN SCRIPT

---

**Note: To edit the crontab, use: crontab -e ; To view existing crontab entries: crontab -l**

