provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = var.assume_role_arn
  }
}

variable "assume_role_arn" {}
variable "admin_password" {}
variable "app_password" {}


                                                            # the EC2 instance
resource "aws_instance" "ubuntu_ec2" {
  ami           = "ami-084568db4383264d4"                   # Ubuntu 20.04 AMI for us-east-1
  instance_type = "t2.micro"                             

  key_name = "ec2-keyPair"                                
  
  
                                                            # User data script to install Nginx, MongoDB, and configure permissions
  user_data = <<-EOF
              #!/bin/bash

              exec > /var/log/user-data.log 2>&1

                                                            # Update and install Nginx and MongoDB
              apt-get update -y
              apt-get install -y nginx

                                                            # Adding MongoDB official repo and installing same.
              sudo apt-get install gnupg curl
              curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
              echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
              apt-get update -y
              apt-get install -y mongodb-org

                                                            # Start and enable Nginx and MongoDB services
              systemctl start nginx
              systemctl enable nginx
              systemctl start mongod
              systemctl enable mongod

                                                            # Wait for MongoDB to be ready
              echo "Waiting for MongoDB to start..."
              until nc -z localhost 27017; do
                sleep 2
              done

                                                            # Creating an admin user for admin database in MONGODB
              mongosh <<EOF2
              use admin
              db.createUser({
                user: 'adminUser',
                pwd: "${var.admin_password}",
                roles: [
                  { role: 'userAdminAnyDatabase', db: 'admin' },
                  { role: 'dbAdminAnyDatabase', db: 'admin' },
                  { role: 'readWriteAnyDatabase', db: 'admin' }
                ],
                mechanisms: ['SCRAM-SHA-1', 'SCRAM-SHA-256']
              })
              EOF2

                                                            # Creatong the 'ubuntu' user in the PoolsApp database
              mongosh <<EOF3
              use PoolsApp
              db.createUser({
                user: 'ubuntu',
                pwd: "${var.app_password}",
                roles: [
                  { role: 'dbAdmin', db: 'PoolsApp' },
                  { role: 'readWrite', db: 'PoolsApp' },
                  { role: 'userAdmin', db: 'PoolsApp' }
                ],
                mechanisms: ['SCRAM-SHA-1', 'SCRAM-SHA-256']
              })
              EOF3
            EOF

                                                            # Using existing security group
  security_groups = ["nginx-server-security-group"]

                                                            
  tags = {
    Name = "Ubuntu-EC2-Instance"
  }

                                                            # NO Elastic IP but dynamic public
  associate_public_ip_address = true
}

# Output EC2 Instance Public IP
output "ec2_public_ip" {
  value = aws_instance.ubuntu_ec2.public_ip
}
