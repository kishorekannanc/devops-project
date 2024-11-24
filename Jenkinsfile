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
        stage('Determine Version') {
            steps {
                script {
                    def versionFile = 'main-version.txt' // Use a separate version file for the dev branch
                    if (fileExists(versionFile)) {
                        // Read and increment the version
                        def currentVersion = sh(script: "cat ${versionFile}", returnStdout: true).trim()
                        def numericPart = currentVersion.replace("v", "").toInteger()
                        VERSION = "v${numericPart + 1}"
                    } else {
                        VERSION = "v1" // Default version if no version file exists
                    }
                    // Save the new version to the file
                    sh "echo ${VERSION} > ${versionFile}"
                    echo "New Development Version: ${VERSION}"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image with the determined version
                    sh "docker build -t ${DOCKER_REPO}:${VERSION} ."
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh '''
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    docker push $DOCKER_REPO:$VERSION
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
                    docker run -d -p 80:80 --name devops-react-app $DOCKER_REPO:$VERSION
                    '''
                }
            }
        }
    }
    post {
        success {
            echo "Build, push, and deployment successful. Version: ${VERSION}"
        }
        failure {
            echo "Build or deployment failed."
        }
    }
}
