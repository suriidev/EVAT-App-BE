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
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
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

        stage('Code Quality') {
            steps {
                withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                    sh '''
                        docker run --rm \
                            -v jenkins_home:/var/jenkins_home \
                            -w /var/jenkins_home/workspace/EVAT-App-BE-Pipeline \
                            --network evat-net \
                            sonarsource/sonar-scanner-cli \
                            -Dsonar.projectKey=evat-app-be \
                            -Dsonar.sources=src \
                            -Dsonar.host.url=http://sonarqube:9000 \
                            -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }
    }
}