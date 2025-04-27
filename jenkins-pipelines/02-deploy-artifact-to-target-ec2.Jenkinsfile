pipeline {
    agent any

    environment {
        DEPLOY_DIR = "/var/www/html"
        EC2_USER = "ubuntu"
        EC2_HOST = "44.201.143.246"
        NVM_DIR = "$HOME/.nvm"
        S3_BUCKET = "pools.app-bucket-by-terraform"  // Add your S3 bucket name
        S3_PATH = "terraform-zipped-store"  // Path inside the S3 bucket
    }

    stages {
        stage('Fetching from Bucket (#S3)') {
            steps {
                script {
                    sh """
                    aws s3 cp s3://${S3_BUCKET}/${S3_PATH}/zipped-file.tar.gz ./zipped-file.tar.gz --region us-east-1
                    """
                }
            }
        }

        stage('Deploying the zip on Targeted Server') {
            steps {
                script {
                    // Use SSH credentials to deploy the file to the EC2 instance
                    sshagent(['SSH-cred-jenkins-nginx']) {
                        sh """
                        scp -o StrictHostKeyChecking=no zipped-file.tar.gz $EC2_USER@$EC2_HOST:$DEPLOY_DIR
                        """
                    }
                }
            }
        }

        stage('Unzip on EC2') {
            steps {
                script {
                    sshagent(['SSH-cred-jenkins-nginx']) {
                        sh """
                        ssh $EC2_USER@$EC2_HOST '
                        sudo chown -R ubuntu:ubuntu $DEPLOY_DIR &&
                        sudo chmod -R 755 $DEPLOY_DIR &&
                        tar -tzf zipped-file.tar.gz
                        tar --no-same-owner --no-same-permissions -xzf $DEPLOY_DIR/zipped-file.tar.gz -C $DEPLOY_DIR &&
                        rm $DEPLOY_DIR/zipped-file.tar.gz'
                        """
                    }
                }
            }
        }

    }

    post {
        always {
            echo 'Deployment in Nginx Finished'
        }
    }
}