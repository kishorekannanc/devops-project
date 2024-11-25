pipeline {
    agent any
    environment {
        DOCKER_REPO = 'kishorekannan23/prod'
        VERSION = '' // To store the dynamically determined version
        CONTAINER_NAME = 'main_app_container' // Name of the container to ensure we can stop/remove it if it exists
        HOST_PORT = '80' // The host port to bind to
        CONTAINER_PORT = '80' // The container port exposed by the app
    }
    stages {
        stage('Checkout Code') {
            steps {
                // Check out the main branch
                git branch: 'main', url: 'https://github.com/kishorekannanc/devops-project.git'
            }
        }
        stage('Determine Version') {
            steps {
                script {
                    def versionFile = 'development-version.txt' // Version file for the main branch
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
                    echo "New Main Branch Version: ${VERSION}"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -t ${DOCKER_REPO}:${VERSION} ."
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    script {
                        // Call the deploy.sh script to handle Docker login and image push
                        sh "./deploy.sh ${DOCKER_REPO}:${VERSION} $DOCKER_USERNAME $DOCKER_PASSWORD"
                    }
                }
            }
        }
        stage('Run Docker Container') {
            steps {
                script {
                    // Remove the existing container if it exists
                    sh """
                    if [ \$(docker ps -aq -f name=${CONTAINER_NAME}) ]; then
                        echo "Stopping and removing existing container: ${CONTAINER_NAME}"
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                    fi
                    """
                    // Run a new container with port binding
                    sh """
                    echo "Starting new container: ${CONTAINER_NAME}"
                    docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${DOCKER_REPO}:${VERSION}
                    """
                }
            }
        }
    }
    post {
        success {
            echo "Build, push, and deployment successful for main branch. Version: ${VERSION}"
        }
        failure {
            echo "Build, push, or deployment failed for main branch."
        }
    }
}
