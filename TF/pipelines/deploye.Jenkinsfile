pipeline {
    agent any
    
    parameters { 
    }

    stages {
        stage('install terraform') {
            steps {
                sh '''
                    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
                    wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

                    gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
                    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
                    sudo apt update
                    sudo apt-get install terraform
                '''
            }
        }

        stage('Run terraform') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'GitHub', usernameVariable: 'USERNAME', passwordVariable: 'GIT_TOKEN')]) {
                    sh '''
                        terraform init
                        terraform apply -var-file region.us-east-1.tfvars
                    '''
                }
            }
        }
    }
    post {
        cleanup {
            cleanWs()
        }
    }
}