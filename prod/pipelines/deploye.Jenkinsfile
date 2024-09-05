pipeline {
    agent any
    
    parameters { 
        string(name: 'SERVICE_NAME', defaultValue: '', description: '')
        string(name: 'IMAGE_FULL_NAME_PARAM', defaultValue: '', description: '')
    }

    stages {
        stage('Deploy') {
            steps {
                sh '''
                    git checkout -b main || git checkout main
                    cd prod/$SERVICE_NAME
                    sed -i "s|image:.*|image: $IMAGE_FULL_NAME_PARAM|" $(echo $SERVICE_NAME)_deployment.yml
                '''
            }
        }

        stage('Git commit and push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'GitHub', usernameVariable: 'USERNAME', passwordVariable: 'GIT_TOKEN')]) {
                    sh '''
                        git add prod/$(echo $SERVICE_NAME)/$(echo $SERVICE_NAME)_deployment.yml
                        git commit -m "Update image: $IMAGE_FULL_NAME_PARAM"
                        git push https://$GIT_TOKEN@github.com/YgalIdan/NetflixInfra.git main
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