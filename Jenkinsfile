pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'Java17' 
    }

    environment {
        SONAR_PROJECT_KEY = 'Management-Carpooling-Services'
        SONAR_PROJECT_NAME = 'Management-Carpooling-Services'
        DOCKER_IMAGE = 'yassiramraoui/management-carpooling-services'
        DOCKER_TAG = 'latest'
        // Assure-toi que Docker Desktop a l'option "Expose daemon on tcp://localhost:2375" cochée
        DOCKER_HOST = 'tcp://127.0.0.1:2375'
    }

    stages {
        stage('Clone') {
            steps {
                echo "📥 Cloning repository..."
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo "🏗️ Build..."
                bat 'call mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo "🧪 Testing..."
                // Ajoute CALL ici
                bat 'call mvn test -DforkCount=0'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                echo "📦 Packaging..."
                // Ajoute CALL ici
                bat 'call mvn package -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.war'
                }
            }
        }

        stage('SonarQube') {
            steps {
                echo "🔍 SonarQube Analysis..."
                withSonarQubeEnv('sonar_integration') {
                    // Ajoute CALL ici
                    bat "call mvn sonar:sonar -Dsonar.projectKey=${SONAR_PROJECT_KEY} -Dsonar.projectName=${SONAR_PROJECT_NAME}"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo "🐳 Docker Build..."
                bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Docker Push') {
            steps {
                echo "🚀 Docker Push..."
                withCredentials([
                    usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'USER', passwordVariable: 'PASS')
                ]) {
                    bat """
                    @echo off
                    echo %PASS% | docker login -u %USER% --password-stdin
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success { echo "✅ SUCCESS" }
        failure { echo "❌ FAILED" }
    }
}