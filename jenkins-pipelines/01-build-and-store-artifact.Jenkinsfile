pipeline {
    agent any

    environment {
        DEPLOY_DIR = "/var/www/html"
        EC2_USER = "ubuntu"
        REPO_URL = "git@github.com:kakarot404/MrPoolApp.git"
        GIT_BRANCH = "master"
        NVM_DIR = "$HOME/.nvm"
        FRONTEND_DIR = "${workspace}/new-project/Pools-App-Frontend"
        BACKEND_DIR = "${workspace}/new-project/Pools-App-Backend"
        S3_BUCKET = "pools.app-bucket-by-terraform"  // Add your S3 bucket name
        S3_PATH = "terraform-zipped-store"  // Path inside the S3 bucket
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Clean up any existing directory if present
                    sh 'pwd'
                    sh 'ls -la'
                    sh 'echo $0'
                    sh 'rm -rf new-project'

                    // Clone the repository using SSH and the Deploy Key
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "refs/heads/${GIT_BRANCH}"]],
                        userRemoteConfigs: [
                            [
                                credentialsId: 'SSH-general-Key-git-CopywithJenkins', 
                                url: "${REPO_URL}"
                            ]
                        ]
                    ])
                }
            }
        }

        stage('Install Node.js 14.15.0') {
            steps {
                script {
                    // Install NVM if it isn't already installed
                    sh '''
                    if [ ! -d "$HOME/.nvm" ]; then
                        echo "Installing NVM"
                        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
                    fi

                    # Load nvm
                    export NVM_DIR="$HOME/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # Loading nvm

                    nvm install 14.15.0
                    nvm use 14.15.0
                    nvm alias default 14.15.0
                    '''
                }
            }
        }

        stage('Install Angular CLI 10.1.4') {
            steps {
                script {
                    // Explicitly load nvm and npm in this step
                    // Now npm should be available, proceed to install Angular CLI globally
                    sh '''
                    export NVM_DIR="$HOME/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # Loading nvm
                    npm install -g npm@6.14.8
                    npm install -g @angular/cli@10.1.4
                    '''
                }
            }
        }

        stage('Install Frontend Dependencies') {
            steps {
                script {
                    // Install frontend dependencies
                    sh '''
                        export NVM_DIR="$HOME/.nvm"
                        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # Loading nvm
                        cd ${FRONTEND_DIR} && npm install
                    '''
                }
            }
        }

        stage('Install Backend Dependencies') {
            steps {
                script {
                    // Install backend dependencies
                    sh '''
                        export NVM_DIR="$HOME/.nvm" 
                        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # Loading nvm 
                        cd ${BACKEND_DIR} && npm install"
                    '''
                }
            }
        }

        stage('Build Angular App') {
            steps {
                script {
                    // Build the Angular app (production mode)
                    sh '''
                        export NVM_DIR="$HOME/.nvm"
                        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # Loading nvm
                        cd ${FRONTEND_DIR} && npm run build
                    '''
                }
            }
        }

        stage('Zip Angular Build') {
            steps {
                script {
                    sh 'tar -czf zipped-file.tar.gz -C new-project .'
                }
            }
        }

        stage('Deploy to S3') {
            steps {
                script {
                    // Deploy the zip file to an S3 bucket
                    sh """
                    aws --version
                    aws s3 cp zipped-file.tar.gz s3://${S3_BUCKET}/${S3_PATH}/zipped-file.tar.gz --region us-east-1
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Deployment in S3 Finished'
        }
    }
}