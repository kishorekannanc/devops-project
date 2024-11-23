pipeline {
    agent any
    environment {
        DOCKER_REPO = 'kishorekannan23/prod'
    }
    stages {
        stage('Checkout Code') {
            steps {
                // Checkout the main branch for production
                git branch: 'main', url: 'https://github.com/kishorekannanc/thulasi.git'
            }
        }
        stage('Determine Version') {
            steps {
                script {
                    def versionFile = 'version.txt' // Version file for production
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
                    echo "New Production Version: ${VERSION}"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image with port binding
                    sh "docker build -t ${DOCKER_REPO}:${VERSION} ."
                   // sh "docker build --build-arg PORT_BINDING='80:80' -t ${DOCKER_REPO}:${VERSION} ."
                }
            }
        }
        stage('Deploy to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    script {
                        // Push the built image to Docker Hub
                        sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                        sh "docker push ${DOCKER_REPO}:${VERSION}"
                    }
                }
            }
        }
        stage('Cleanup Old Images') {
            steps {
                script {
                    // Remove older versions of the image from the local Docker system
                    sh "docker image prune -a -f --filter label=${DOCKER_REPO}"
                }
            }
        }
        stage('Run Docker Container') {
            steps {
                script {
                    sh "docker run -d -p 80:80 --name ${DOCKER_REPO}:${VERSION}"
                }
            }
        }
    }
     
    post {
        success {
            echo "Build and deployment successful for production. Version: ${VERSION}"
        }
        failure {
            echo "Build or deployment failed for production."
        }
    }
}

