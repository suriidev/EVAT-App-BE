pipeline {
    agent any

    environment {
        IMAGE_NAME = "evat-app-be"
    }

    stages {
        stage('Build') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .'
            }
        }

        stage('Test') {
            steps {
                sh '''
                    docker run --rm \
                        -v jenkins_home:/var/jenkins_home \
                        -w /var/jenkins_home/workspace/EVAT-App-BE-Pipeline \
                        node:18-alpine \
                        sh -c "npm install && npm run test:scoped"
                '''
            }
        }
    }
}