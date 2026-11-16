
pipeline {
    agent any

    stages {

        // Stage 1: Fetch application source code from GitHub
        stage('Checkout') {
            steps {
                echo 'Checking out Maven project from GitHub'

                checkout scm

                sh 'pwd'
                sh 'ls -la'
            }
        }

        // Stage 2: Verify Java and Maven
        stage('Check Tools') {
            steps {
                echo 'Checking Java and Maven versions'

                sh 'java -version'
                sh 'mvn -version'
            }
        }

        // Stage 3: Compile Java source code
        stage('Compile') {
            steps {
                echo 'Compiling Java application'

                sh 'mvn clean compile'
            }
        }

        // Stage 4: Execute unit tests
        stage('Test') {
            steps {
                echo 'Running unit tests'

                sh 'mvn test'
            }
        }

        // Stage 5: Generate executable JAR
        stage('Package') {
            steps {
                echo 'Creating executable JAR'

                sh 'mvn package -DskipTests'
            }
        }

        // Stage 6: Store JAR inside Jenkins build artifacts
        stage('Archive Artifact') {
            steps {
                echo 'Archiving generated JAR'

                archiveArtifacts artifacts: 'target/*.jar',
                                 fingerprint: true
            }
        }

        // Stage 7: Deploy the same JAR to managed EC2
        stage('Deploy to EC2') {
            steps {
                echo 'Deploying Maven JAR to managed EC2'

                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'maven-deploy-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "Transferring JAR to managed EC2"

                        scp -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=accept-new \
                            target/hello-maven-1.0-SNAPSHOT.jar \
                            "$SSH_USER@13.203.219.8:/opt/hello-maven/"

                        echo "Executing JAR on managed EC2"

                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=accept-new \
                            "$SSH_USER@13.203.219.8" \
                            'cd /opt/hello-maven && java -jar hello-maven-1.0-SNAPSHOT.jar'

                        echo "JAR deployment completed"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Maven CI and EC2 deployment completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check Console Output.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}

