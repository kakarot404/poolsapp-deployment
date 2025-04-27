## Secrets Manager Integration

Jenkins uses AWS Secrets Manager to retrieve credentials at runtime. The following secrets are used:

- `mongo-db-credentials`: Used in backend deployment steps to configure MongoDB.
- `terraform-assume-role-arn`: Required for assuming Terraform provisioning role during infrastructure setup.

Secrets are injected into Jenkins pipelines using environment variables and AWS CLI/SDK.

Example usage in Jenkinsfile:
```groovy
environment {
    MONGO_SECRET = sh(script: "aws secretsmanager get-secret-value --secret-id mongo-app-creds --query \ SecretString --output text", returnStdout: true).trim()
    ARN_ROLE_TERRAFORM = sh(script: "aws secretsmanager get-secret-value --secret-id \ role-arn-terrafomRM --query SecretString --output text", returnStdout: true).trim()
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
```