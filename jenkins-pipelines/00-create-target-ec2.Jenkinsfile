pipeline {
  agent any

  environment {
    REPO_URL = "git@github.com:kakarot404/jenkins_pipeline_for_terraform.git"
    GIT_BRANCH = "dev"
    AWS_REGION = "us-east-1"
    MONGO_SECRET = sh(script: "aws secretsmanager get-secret-value --secret-id mongo-app-creds --query SecretString --output text", returnStdout: true).trim()
    ARN_ROLE_TERRAFORM = sh(script: "aws secretsmanager get-secret-value --secret-id role-arn-terrafomRM --query SecretString --output text", returnStdout: true).trim()
  }

  stages {
    stage('Checkout') {
      steps {
        script {
          // Clone the repository using SSH and the Deploy Key
            checkout([
              $class: 'GitSCM',
              branches: [[name: "refs/heads/${GIT_BRANCH}"]],
              userRemoteConfigs: [
                [
                  credentialsId: 'SSH-general-Key-git-CopywithJenkins', 
                  url: "${REPO_URL}"
                ]
              ],
              doGenerateSubmoduleConfigurations: false,
              extensions: [
                [$class: 'CloneOption', depth: 1, noTags: true, shallow: true],
                [$class: 'SparseCheckoutPaths', sparseCheckoutPaths: [
                  [$class: 'SparseCheckoutPath', path: 'ec2-instance-creation-mongo.tf'],
                  [$class: 'SparseCheckoutPath', path: 'README.md']
                ]]
              ]
            ])
          }
        }
      }

    stage('Fetch Secrets') {
      steps {
        script {
          def creds = readJSON text: env.MONGO_SECRET
          env.ADMIN_PASSWORD = creds.adminPassword
          env.APP_PASSWORD = creds.appPassword
          def roleArn = readJSON text: env.ARN_ROLE_TERRAFORM
          env.ROLE_ARN = roleArn.roleARN                    
        }
      }
    }

    stage('Terraform init & apply') {
      steps {
        sh '''
          terraform init
          terraform validate \
          terraform plan -auto-approve \
          terraform apply -auto-approve \
          -var="admin_password=${ADMIN_PASSWORD}" \
          -var="app_password=${APP_PASSWORD}" \
          -var="assume_role_arn=${ROLE_ARN}"
        ''' 
      }
    }
  }
}