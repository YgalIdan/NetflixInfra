pipeline {
    agent any
    
    parameters { 
        choice(name: "ENV", choices: ['Dev', 'Prod'], description: '')
        choice(name: "Region", choices: ['eu-north-1', 'us-east-1'], description: '')
    }

    stages {
        stage('install terraform') {
            steps {
                sh '''
                    apt install -y wget
                    apt-get update && sudo apt-get install -y gnupg software-properties-common
                    wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

                    gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
                    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
                    apt update
                    apt-get install -y terraform
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