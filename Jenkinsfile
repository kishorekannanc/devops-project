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
            def versionFile = 'version.txt' // File containing the version
            if (fileExists(versionFile)) {
                // Read the current version and trim whitespace
                def currentVersion = sh(script: "cat ${versionFile}", returnStdout: true).trim()
                
                // Extract numeric part by removing the "v" prefix and converting to integer
                def numericPart = currentVersion.replaceFirst("^v", "").toInteger()
                
                // Increment the version number
                VERSION = "v${numericPart + 1}"
            } else {
                // Default to "v1" if no version file exists
                VERSION = "v1"
            }

            // Save the new version to the version file
            sh "echo ${VERSION} > ${versionFile}"
            echo "New main branch version: ${VERSION}"
        }
    }
}

        stage('Build Docker Image') {
            steps {
                script {
                    // Pass the development-specific image tag to build.sh
                    sh "./build.sh ${DOCKER_REPO}:${VERSION} ."
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh '''
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    docker push ${DOCKER_REPO}:${VERSION}
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
                    docker run -d -p 80:80 --name devops-react-app ${DOCKER_REPO}:${VERSION}
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
