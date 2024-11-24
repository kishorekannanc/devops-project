pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('credentials') // Ensure this is the correct credentials ID
        DOCKER_REPO = 'kishorekannan23/prod'
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/kishorekannanc/thulasi.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    docker build -t $DOCKER_REPO:latest .
                    '''
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh '''
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    docker push $DOCKER_REPO:latest
                    '''
                }
            }
        }
        stage('Run Docker Container') {
            steps {
                script {
                    sh '''
                    # Stop and remove the old container if it exists
                    if [ $(docker ps -aq -f name=devops-react-app) ]; then
                        docker stop devops-react-app || true
                        docker rm devops-react-app || true
                    fi

                    # Run the new container with port binding
                    docker run -d -p 80:80 --name devops-react-app $DOCKER_REPO:latest
                    '''
                }
            }
        }
    }
    post {
        success {
            echo 'Build, push, and container deployment successful.'
        }
        failure {
            echo 'Build failed.'
        }
    }
}
