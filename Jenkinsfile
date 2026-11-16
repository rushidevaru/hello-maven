
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out Maven project'
                checkout scm
            }
        }

        stage('Check Tools') {
            steps {
                sh 'java -version'
                sh 'mvn -version'
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar',
                                 fingerprint: true
            }
        }

        stage('Deploy to Multiple Servers') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'maven-deploy-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        set -e

                        JAR_FILE="target/hello-maven-1.0-SNAPSHOT.jar"

                        if [ ! -f "$JAR_FILE" ]; then
                            echo "ERROR: JAR file not found"
                            exit 1
                        fi

                        for SERVER in 13.203.219.8 13.232.230.72
                        do
                            echo "Deploying to $SERVER"

                            scp -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$JAR_FILE" "$SSH_USER@$SERVER:/opt/hello-maven/"

                            echo "Executing application on $SERVER"

                            ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$SSH_USER@$SERVER" "cd /opt/hello-maven && java -jar hello-maven-1.0-SNAPSHOT.jar"

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

