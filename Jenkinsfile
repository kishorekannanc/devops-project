pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('credentials')
        DOCKER_REPO = 'kishorekannan23/prod'
        VERSION_FILE = 'version.txt' // Define the version file name here
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
                    if (!fileExists(VERSION_FILE)) {
                        error "${VERSION_FILE} file is missing. Please add ${VERSION_FILE} to the repository."
                    }
                }
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
        stage('Read Version') {
            steps {
                script {
                    VERSION = readFile(VERSION_FILE).trim()
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

}
