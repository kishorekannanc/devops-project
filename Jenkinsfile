pipeline {
    agent any
    environment {
        DOCKER_REPO = 'kishorekannan23/dev'
    }
    stages {
        stage('Checkout Code') {
            steps {
                // Check out the development branch
                git branch: 'development', url: 'https://github.com/kishorekannanc/devops-project.git'
            }
        }
        stage('Determine Version') {
            steps {
                script {
                    def versionFile = 'development-version.txt' // Use a separate version file for the dev branch
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
                    // Pass the development-specific image tag to build.sh
                    sh "./build.sh ${DOCKER_REPO}:${VERSION}"
                }
            }
        }
        stage('Deploy to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    script {
                        // Use the deploy.sh script to push the development-specific image
                        sh "./deploy.sh ${DOCKER_REPO}:${VERSION} $DOCKER_USERNAME $DOCKER_PASSWORD"
                    }
                }
            }
        }
    }
    post {
        success {
            echo "Build and deployment successful for development branch. Version: ${VERSION}"
        }
        failure {
            echo "Build or deployment failed for development branch.."
        }
    }
}

