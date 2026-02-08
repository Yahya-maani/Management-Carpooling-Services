pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'Java17' // Jenkins utilise Java 17 ici
    }

    environment {
        SONAR_PROJECT_KEY = 'Management-Carpooling-Services'
        SONAR_PROJECT_NAME = 'Management-Carpooling-Services'
        DOCKER_IMAGE = 'yassiramraoui/management-carpooling-services'
        DOCKER_TAG = 'latest'
        // On force Docker à utiliser le port TCP puisque Jenkins est en "Système Local"
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
                bat 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo "🧪 Testing..."
                bat 'mvn test'
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
                bat 'mvn package -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar, target/*.war'
                }
            }
        }

        stage('SonarQube') {
            steps {
                echo "🔍 SonarQube Analysis..."
                withSonarQubeEnv('sonar_integration') {
                    bat "mvn sonar:sonar -Dsonar.projectKey=${SONAR_PROJECT_KEY}"
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
                // Utilisation de variables d'environnement Jenkins pour plus de clarté
                bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Docker Push') {
            steps {
                echo "🚀 Docker Push..."
                withCredentials([
                    usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'USER', passwordVariable: 'PASS')
                ]) {
                    // @echo off évite d'afficher le mot de passe dans les logs Jenkins
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