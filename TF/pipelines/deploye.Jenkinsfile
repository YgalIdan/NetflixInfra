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
                withCredentials([usernamePassword(credentialsId: 'AWS_cred', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        terraform init
                        terraform apply -var-file TF/region.us-east-1.tfvars
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