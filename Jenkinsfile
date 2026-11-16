
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out Maven project from GitHub'
                checkout scm
                sh 'pwd'
                sh 'ls -la'
            }
        }

        stage('Check Tools') {
            steps {
                echo 'Checking Java and Maven versions'
                sh 'java -version'
                sh 'mvn -version'
            }
        }

        stage('Compile') {
            steps {
                echo 'Compiling Java application'
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo 'Running unit tests'
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                echo 'Creating executable JAR'
                sh 'mvn package -DskipTests'
            }
        }

        stage('Archive Artifact') {
            steps {
                echo 'Archiving generated JAR'
                archiveArtifacts artifacts: 'target/*.jar',
                                 fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'Maven CI Pipeline completed successfully!'
        }

        failure {
            echo 'Maven CI Pipeline failed. Check Console Output.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}

