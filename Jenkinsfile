
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out Maven project'
                checkout scm
                sh 'pwd'
                sh 'ls -la'
            }
        }

        stage('Check Tools') {
            steps {
                echo 'Checking Java and Maven'
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
                echo 'Archiving JAR in Jenkins'
                archiveArtifacts artifacts: 'target/*.jar',
                                 fingerprint: true
            }
        }

        stage('Deploy to Multiple Servers') {
            steps {
                echo 'Deploying JAR to both EC2 servers'

                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'maven-deploy-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        set -e

                        SERVERS="13.203.219.8 13.232.230.72"

                        for SERVER in $SERVERS
                        do
                            echo "Deploying to $SERVER"

                            scp -i "$SSH_KEY" \
                                -o StrictHostKeyChecking=accept-new \
OBOBOB                                target/hello-maven-1.0-SNAPSHOT.jar \
                                "$SSH_USER@$SERVER:/opt/hello-maven/"

OBOBOB                            echo "Running application on $SERVER"

                            ssh -i "$SSH_KEY" \
                                -o StrictHostKeyChecking=accept-new \
                                "$SSH_USER@$SERVER" \
                                'cd /opt/hello-maven && java -jar hello-maven-1.0-SNAPSHOT.jar'

                            echo "Deployment successful on $SERVER"
                        done
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Multi-server deployment completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check Console Output.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}

