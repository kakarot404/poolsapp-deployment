#!/bin/bash

                                                        # Wait for a few seconds before fetching the public IP
sleep 10

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")


                                                        # Fetch the public IP of the EC2 instance from the AWS metadata service
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

                                                        # Check if the PUBLIC_IP variable is empty or not
if [ -z "$PUBLIC_IP" ]; then
  echo "Error: Unable to fetch public IP. Exiting..."
  exit 1
fi

                                                        # Echo the fetched IP for verification
echo "The current public IP is: $PUBLIC_IP"

                                                        # Path to the Jenkins configuration file
JENKINS_CONFIG_FILE="/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml"

                                                        # Update the jenkinsUrl in the Jenkins configuration XML file
sudo sed -i "s|<jenkinsUrl>http://.*:8080/</jenkinsUrl>|<jenkinsUrl>http://$PUBLIC_IP:8080/</jenkinsUrl>|g" $JENKINS_CONFIG_FILE 


                                                        # Checking if the sed command was successful
if [ $? -eq 0 ]; then
  echo "Jenkins URL updated to http://$PUBLIC_IP:8080"
else
  echo "Failed to update Jenkins URL"
  exit 1
fi

                                                        # Restart Jenkins to apply the changes
sudo systemctl restart jenkins

                                                        # Check if Jenkins restarted successfully
if [ $? -eq 0 ]; then
  echo "Jenkins successfully restarted."
else
  echo "Failed to restart Jenkins."
  exit 1
fi