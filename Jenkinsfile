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

        stage('Security') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '''
                        docker run --rm \
                            -v jenkins_home:/var/jenkins_home \
                            -w /var/jenkins_home/workspace/EVAT-App-BE-Pipeline \
                            node:18-alpine \
                            sh -c "npm install && npm audit"
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([string(credentialsId: 'jwt-secret', variable: 'JWT_SECRET')]) {
                    sh '''
                        docker rm -f evat-staging || true
                        docker run -d --name evat-staging \
                            --network evat-net \
                            -p 8081:8080 \
                            -e MONGODB_URI=mongodb://mongo-evat:27017/EVAT \
                            -e JWT_SECRET=$JWT_SECRET \
                            -e PORT=8080 \
                            ${IMAGE_NAME}:${BUILD_NUMBER}
                        sleep 5
                        docker run --rm --network evat-net curlimages/curl -sf http://evat-staging:8080/api/docs
                    '''
                }
            }
        }

        stage('Release') {
            steps {
                withCredentials([string(credentialsId: 'jwt-secret', variable: 'JWT_SECRET')]) {
                    sh '''
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:release
                        docker rm -f evat-prod || true
                        docker run -d --name evat-prod \
                            --network evat-net \
                            -p 8082:8080 \
                            -e MONGODB_URI=mongodb://mongo-evat:27017/EVAT \
                            -e JWT_SECRET=$JWT_SECRET \
                            -e PORT=8080 \
                            ${IMAGE_NAME}:release
                    '''
                }
            }
        }

        stage('Monitoring') {
            steps {
                sh '''
                    sleep 5
                    docker run --rm --network evat-net curlimages/curl -sf http://evat-prod:8080/api/docs
                '''
            }
        }
    }
}