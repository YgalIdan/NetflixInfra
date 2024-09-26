pipeline {
    agent {
        label 'general'
    }
    
    parameters { 
        choice(name: "ENV", choices: ['Dev', 'Prod'], description: '')
        choice(name: "Region", choices: ['eu-north-1', 'us-east-1'], description: '')
    }

    stages {
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