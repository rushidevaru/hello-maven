
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'rushikesh6022/hello-maven:v1'
    }

    stages {

        // Step 1: Download source code from GitHub
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // Step 2: Build Java application using Maven
        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        // Step 3: Save the generated JAR in Jenkins
        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar',
                                 fingerprint: true
            }
        }

        // Step 4: Create Docker image
        stage('Docker Build') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        // Step 5: Push Docker image to Docker Hub
        stage('Docker Hub Login and Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "$DOCKER_TOKEN" | docker login \
                            -u "$DOCKER_USER" --password-stdin

                        docker push "$DOCKER_IMAGE"

                        docker logout
                    '''
                }
            }
        }

        // Step 6: Deploy Docker image to both EC2 servers
        stage('Deploy Using Ansible') {
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

                        export ANSIBLE_HOST_KEY_CHECKING=False

                        ansible-playbook \
                            -i inventory.ini \
                            -u "$SSH_USER" \
                            --private-key "$SSH_KEY" \
                            deploy-docker.yml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Docker image built, pushed and deployed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check Console Output.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}

