pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('credentials') // Update with your actual credentials ID
        DOCKER_REPO = 'kishorekannan23/prod'
        VERSION_FILE = 'version.txt'
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
                    def currentVersion = fileExists(VERSION_FILE) ? readFile(VERSION_FILE).trim() : "v0"
                    def numericPart = currentVersion.replace("v", "").toInteger()
                    VERSION = "v${numericPart + 1}"
                    writeFile file: VERSION_FILE, text: VERSION
                    echo "Determined Version: ${VERSION}"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker buildx create --use || true
                    docker buildx build --platform linux/amd64 -t ${DOCKER_REPO}:${VERSION} .
                    """
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    sh """
                    echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin
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
