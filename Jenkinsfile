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
                sh 'npm install'
                sh 'npm run test:scoped'
            }
        }
    }
}