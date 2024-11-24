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
                    def versionFile = 'version.txt'
                    if (fileExists(versionFile)) {
                        def currentVersion = sh(script: "cat ${versionFile}", returnStdout: true).trim()
                        try {
                            def numericPart = currentVersion.replaceFirst("^v", "").toInteger()
                            VERSION = "v${numericPart + 1}"
                        } catch (Exception e) {
                            error "Invalid version format in version.txt: ${currentVersion}"
                        }
                    } else {
                        VERSION = "v1"
                    }
                    sh "echo ${VERSION} > ${versionFile}"
                    echo "New main branch version: ${VERSION}"
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
                    docker rm -f devops-react-app || true
                    docker run -d -p 80:80 --name devops-react-app ${DOCKER_REPO}:${VERSION}
                    '''
                }
            }
        }
        stage('Cleanup Docker Images') {
            steps {
                script {
                    sh 'docker image prune -f'
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
