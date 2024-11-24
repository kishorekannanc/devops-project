pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('credentials')
        DOCKER_REPO = 'kishorekannan23/prod'
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/kishorekannanc/thulasi.git'
            }
        }
        stage('Validate Version File') {
            steps {
                script {
                    if (!fileExists('VERSION')) {
                        error "VERSION file is missing. Please add a VERSION file to the repository."
                    }
                }
            }
        }
        stage('Increment Version') {
            steps {
                sh './build.sh'
            }
        }
        stage('Read Version') {
            steps {
                script {
                    VERSION = readFile('VERSION').trim()
                    echo "Building version: ${VERSION}"
                }
            }
        }
        stage('Remove Old Image') {
            steps {
                script {
                    sh """
                    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
                    if docker images | grep -q ${DOCKER_REPO}; then
                        docker rmi -f ${DOCKER_REPO}:${VERSION}
                    fi
                    """
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_REPO}:${VERSION} ."
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    sh """
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    docker push ${DOCKER_REPO}:${VERSION}
                    """
                }
            }
        }
        stage('Deploy Container') {
            steps {
                script {
                    sh """
                    docker stop prod-container || true
                    docker rm prod-container || true
                    docker run -d --name prod-container -p 80:80 ${DOCKER_REPO}:${VERSION}
                    """
                }
            }
        }
    }
    post {
        success {
            echo 'Build, push, and deployment successful.'
        }
        failure {
            echo 'Build failed.'
        }
    }
}
